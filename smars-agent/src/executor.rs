use anyhow::{Result, anyhow};
use serde_json::{Value, json};
use std::collections::HashMap;
use std::collections::hash_map::DefaultHasher;
use std::hash::{Hash, Hasher};
use log::{info, debug, warn};
use uuid::Uuid;

use crate::parser::{SmarsNode, PlanDef, MapletDef, ContractDef, ApplyCall};
use crate::bridge::foundation_bridge::FoundationBridge;

pub struct SmarsExecutor {
    maplet_registry: MapletRegistry,
    foundation_bridge: Option<FoundationBridge>,
    execution_context: ExecutionContext,
}

#[derive(Debug, Clone)]
pub struct ExecutionContext {
    pub variables: HashMap<String, Value>,
    pub execution_id: String,
    pub trace: Vec<ExecutionStep>,
}

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct ExecutionStep {
    pub step_name: String,
    pub step_type: String,
    pub result: Option<Value>,
    pub error: Option<String>,
    pub timestamp: u64,
}

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct ValidationDelta {
    pub aspect: String,
    pub expected: Value,
    pub actual: Value,
    pub variance_score: f64,
}

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct ExecutionResult {
    pub success: bool,
    pub result: Option<Value>,
    pub trace: Vec<ExecutionStep>,
    pub contracts_validated: Vec<String>,
    pub plan_spec_hash: String,
    pub execution_timestamp: u64,
    pub cue_emissions: Vec<CueEmission>,
    pub validation_outcome: ValidationOutcome,
}

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct CueEmission {
    pub cue_id: String,
    pub emission_context: String,
    pub suggested_improvement: String,
    pub confidence_score: f64,
    pub emitted_at: u64,
}

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct ValidationOutcome {
    pub contract_compliance: f64,
    pub round_trip_verified: bool,
    pub validation_deltas: Vec<ValidationDelta>,
}

pub struct MapletRegistry {
    local_maplets: HashMap<String, Box<dyn LocalMaplet>>,
    remote_maplets: HashMap<String, RemoteMapletDef>,
}

#[derive(Debug, Clone)]
pub struct RemoteMapletDef {
    pub name: String,
    pub signature: String,
    pub requires_llm: bool,
}

pub trait LocalMaplet: Send + Sync {
    fn execute(&self, args: Vec<Value>, context: &mut ExecutionContext) -> Result<Value>;
    fn signature(&self) -> &str;
}

impl SmarsExecutor {
    pub fn new(enable_foundation_models: bool) -> Self {
        let foundation_bridge = if enable_foundation_models {
            Some(FoundationBridge::new())
        } else {
            None
        };
        
        let mut executor = Self {
            maplet_registry: MapletRegistry::new(),
            foundation_bridge,
            execution_context: ExecutionContext {
                variables: HashMap::new(),
                execution_id: Uuid::new_v4().to_string(),
                trace: Vec::new(),
            },
        };
        
        // Register built-in maplets
        executor.register_builtin_maplets();
        
        executor
    }
    
    pub async fn execute_plan(&mut self, plan_name: &str, ast: &[SmarsNode]) -> Result<ExecutionResult> {
        info!("Executing plan: {}", plan_name);
        
        // Find the plan in the AST and clone steps to avoid borrow issues
        let plan_steps = {
            let plan = self.find_plan(plan_name, ast)?;
            plan.steps.clone()
        };
        
        // Reset execution context
        self.execution_context.execution_id = Uuid::new_v4().to_string();
        self.execution_context.trace.clear();
        
        let mut contracts_validated = Vec::new();
        
        // Execute each step in the plan
        for (i, step) in plan_steps.iter().enumerate() {
            debug!("Executing step {}: {}", i + 1, step);
            
            let step_result = self.execute_step(step, ast).await;
            
            let execution_step = ExecutionStep {
                step_name: step.clone(),
                step_type: "plan_step".to_string(),
                result: step_result.as_ref().ok().cloned(),
                error: step_result.as_ref().err().map(|e| e.to_string()),
                timestamp: std::time::SystemTime::now()
                    .duration_since(std::time::UNIX_EPOCH)
                    .unwrap()
                    .as_secs(),
            };
            
            self.execution_context.trace.push(execution_step);
            
            if let Err(e) = step_result {
                warn!("Step failed: {}", e);
                return Ok(ExecutionResult {
                    success: false,
                    result: None,
                    trace: self.execution_context.trace.clone(),
                    contracts_validated,
                    plan_spec_hash: String::new(),
                    execution_timestamp: std::time::SystemTime::now()
                        .duration_since(std::time::UNIX_EPOCH)
                        .unwrap()
                        .as_secs(),
                    cue_emissions: Vec::new(),
                    validation_outcome: ValidationOutcome {
                        contract_compliance: 0.0,
                        round_trip_verified: false,
                        validation_deltas: Vec::new(),
                    },
                });
            }
        }
        
        // Validate any contracts associated with this plan
        for node in ast {
            if let SmarsNode::Contract(contract) = node {
                if self.should_validate_contract(contract, plan_name) {
                    match self.validate_contract(contract).await {
                        Ok(_) => {
                            contracts_validated.push(contract.name.clone());
                        }
                        Err(e) => {
                            warn!("Contract validation failed for {}: {}", contract.name, e);
                        }
                    }
                }
            }
        }
        
        // Perform round-trip validation
        let plan_spec_hash = self.compute_plan_hash(plan_name, &plan_steps);
        let validation_outcome = self.validate_execution_against_spec(plan_name, &plan_steps, &self.execution_context.trace).await?;
        let cue_emissions = self.emit_runtime_cues(&self.execution_context.trace, &validation_outcome).await?;
        
        Ok(ExecutionResult {
            success: true,
            result: Some(json!({"plan": plan_name, "steps_executed": plan_steps.len()})),
            trace: self.execution_context.trace.clone(),
            contracts_validated,
            plan_spec_hash,
            execution_timestamp: std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs(),
            cue_emissions,
            validation_outcome,
        })
    }
    
    async fn execute_step(&mut self, step: &str, ast: &[SmarsNode]) -> Result<Value> {
        debug!("Processing step: {}", step);
        
        // Check if step is an apply expression
        if step.trim().starts_with("apply") {
            return self.execute_apply_step(step, ast).await;
        }
        
        // Check if step calls a maplet directly
        if let Some(maplet_name) = self.extract_maplet_call(step) {
            return self.execute_maplet(&maplet_name, vec![], ast).await;
        }
        
        // Default: treat as a simple action
        info!("Executing simple step: {}", step);
        Ok(json!({"step": step, "executed": true}))
    }
    
    async fn execute_apply_step(&mut self, step: &str, ast: &[SmarsNode]) -> Result<Value> {
        // Parse apply expression from step
        let apply_call = self.parse_apply_from_step(step)?;
        self.execute_apply(&apply_call, ast).await
    }
    
    async fn execute_apply(&mut self, apply: &ApplyCall, ast: &[SmarsNode]) -> Result<Value> {
        info!("Executing apply: {} ▸ {:?}", apply.target, apply.args);
        
        let args: Vec<Value> = apply.args.iter()
            .map(|arg| self.resolve_argument(arg))
            .collect();
        
        self.execute_maplet(&apply.target, args, ast).await
    }
    
    async fn execute_maplet(&mut self, name: &str, args: Vec<Value>, ast: &[SmarsNode]) -> Result<Value> {
        // Try local maplet first
        if let Some(local_maplet) = self.maplet_registry.local_maplets.get(name) {
            info!("Executing local maplet: {}", name);
            return local_maplet.execute(args, &mut self.execution_context);
        }
        
        // Try remote maplet via Swift bridge
        if let Some(remote_maplet) = self.maplet_registry.remote_maplets.get(name) {
            if remote_maplet.requires_llm {
                if let Some(ref bridge) = self.foundation_bridge {
                    info!("Executing remote LLM maplet: {}", name);
                    return bridge.execute_llm_maplet(name, &args, &self.execution_context).await;
                } else {
                    return Err(anyhow!("LLM maplet {} requires FoundationModels bridge", name));
                }
            }
        }
        
        // Check if maplet is defined in AST
        for node in ast {
            if let SmarsNode::Maplet(maplet_def) = node {
                if maplet_def.name == name {
                    if maplet_def.remote_llm {
                        if let Some(ref bridge) = self.foundation_bridge {
                            return bridge.execute_llm_maplet(name, &args, &self.execution_context).await;
                        }
                    }
                    // For now, return a placeholder result for AST-defined maplets
                    return Ok(json!({"maplet": name, "args": args, "result": "executed"}));
                }
            }
        }
        
        Err(anyhow!("Maplet not found: {}", name))
    }
    
    async fn validate_contract(&self, contract: &ContractDef) -> Result<bool> {
        info!("Validating contract: {}", contract.name);
        
        // Basic contract validation logic
        for requirement in &contract.requires {
            if !self.check_requirement(requirement) {
                return Err(anyhow!("Contract requirement not met: {}", requirement));
            }
        }
        
        // If we have Foundation Models available, we could use it for complex contract validation
        if let Some(ref bridge) = self.foundation_bridge {
            return bridge.validate_contract_with_llm(contract, &self.execution_context).await;
        }
        
        Ok(true)
    }
    
    fn find_plan<'a>(&self, name: &str, ast: &'a [SmarsNode]) -> Result<&'a PlanDef> {
        for node in ast {
            if let SmarsNode::Plan(plan) = node {
                if plan.name == name {
                    return Ok(plan);
                }
            }
        }
        Err(anyhow!("Plan not found: {}", name))
    }
    
    fn extract_maplet_call(&self, step: &str) -> Option<String> {
        // Simple heuristic to detect maplet calls
        if step.contains("apply") {
            None
        } else if step.chars().any(|c| "ƒ▸".contains(c)) {
            // Extract maplet name from symbolic notation
            step.split_whitespace()
                .find(|word| !word.starts_with("(") && !word.starts_with("-"))
                .map(|s| s.to_string())
        } else {
            None
        }
    }
    
    fn parse_apply_from_step(&self, step: &str) -> Result<ApplyCall> {
        // Simple parsing of apply expressions from step text
        if let Some(start) = step.find("apply") {
            let remaining = &step[start + 5..].trim();
            
            if let Some(arrow_pos) = remaining.find("▸") {
                let target = remaining[..arrow_pos].trim().to_string();
                let args_str = remaining[arrow_pos + 1..].trim();
                
                let args: Vec<String> = if args_str.is_empty() {
                    Vec::new()
                } else {
                    args_str.split(',').map(|s| s.trim().to_string()).collect()
                };
                
                return Ok(ApplyCall { target, args });
            }
        }
        
        Err(anyhow!("Failed to parse apply expression from: {}", step))
    }
    
    fn resolve_argument(&self, arg: &str) -> Value {
        // Try to resolve argument from context variables
        if let Some(value) = self.execution_context.variables.get(arg) {
            value.clone()
        } else {
            // Try to parse as JSON, otherwise treat as string
            serde_json::from_str(arg).unwrap_or_else(|_| Value::String(arg.to_string()))
        }
    }
    
    fn should_validate_contract(&self, contract: &ContractDef, plan_name: &str) -> bool {
        // Simple heuristic: validate contracts that mention the plan name
        contract.name.contains(plan_name) || 
        contract.requires.iter().any(|req| req.contains(plan_name)) ||
        contract.ensures.iter().any(|ens| ens.contains(plan_name))
    }
    
    fn check_requirement(&self, requirement: &str) -> bool {
        // Basic requirement checking
        // In a real implementation, this would be more sophisticated
        debug!("Checking requirement: {}", requirement);
        
        // For now, assume all requirements are met unless they explicitly fail
        !requirement.contains("false") && !requirement.contains("invalid")
    }
    
    fn register_builtin_maplets(&mut self) {
        // Register some basic built-in maplets
        self.maplet_registry.register_local("log", Box::new(LogMaplet));
        self.maplet_registry.register_local("concat", Box::new(ConcatMaplet));
        self.maplet_registry.register_local("get_timestamp", Box::new(TimestampMaplet));
        
        // Register some remote LLM maplets
        self.maplet_registry.register_remote("complete_cue", "Cue → Context → CompletedCue", true);
        self.maplet_registry.register_remote("generate_plan", "Goal → Context → Plan", true);
        self.maplet_registry.register_remote("analyze_pattern", "Data → Pattern → Analysis", true);
    }
    
    // Round-trip validation methods
    
    fn compute_plan_hash(&self, plan_name: &str, steps: &[String]) -> String {
        let mut hasher = DefaultHasher::new();
        plan_name.hash(&mut hasher);
        for step in steps {
            step.hash(&mut hasher);
        }
        format!("{:x}", hasher.finish())
    }
    
    async fn validate_execution_against_spec(
        &self,
        plan_name: &str,
        expected_steps: &[String],
        actual_trace: &[ExecutionStep],
    ) -> Result<ValidationOutcome> {
        let mut validation_deltas = Vec::new();
        let mut total_compliance = 0.0;
        let mut compliance_checks = 0;
        
        // Compare expected vs actual step count
        let step_count_variance = if expected_steps.len() == actual_trace.len() {
            1.0
        } else {
            1.0 - ((expected_steps.len() as f64 - actual_trace.len() as f64).abs() / expected_steps.len() as f64)
        };
        
        validation_deltas.push(ValidationDelta {
            aspect: "step_count".to_string(),
            expected: json!(expected_steps.len()),
            actual: json!(actual_trace.len()),
            variance_score: step_count_variance,
        });
        
        total_compliance += step_count_variance;
        compliance_checks += 1;
        
        // Compare step execution success rate
        let successful_steps = actual_trace.iter().filter(|step| step.error.is_none()).count();
        let success_rate = successful_steps as f64 / actual_trace.len().max(1) as f64;
        
        validation_deltas.push(ValidationDelta {
            aspect: "success_rate".to_string(),
            expected: json!(1.0),
            actual: json!(success_rate),
            variance_score: success_rate,
        });
        
        total_compliance += success_rate;
        compliance_checks += 1;
        
        // Check if execution order matches specification
        let order_compliance = self.validate_execution_order(expected_steps, actual_trace);
        validation_deltas.push(ValidationDelta {
            aspect: "execution_order".to_string(),
            expected: json!(expected_steps),
            actual: json!(actual_trace.iter().map(|s| &s.step_name).collect::<Vec<_>>()),
            variance_score: order_compliance,
        });
        
        total_compliance += order_compliance;
        compliance_checks += 1;
        
        let final_compliance = total_compliance / compliance_checks as f64;
        
        Ok(ValidationOutcome {
            contract_compliance: final_compliance,
            validation_deltas,
            round_trip_verified: true,
        })
    }
    
    fn validate_execution_order(&self, expected: &[String], actual: &[ExecutionStep]) -> f64 {
        if expected.len() != actual.len() {
            return 0.5; // Partial credit for count mismatch
        }
        
        let matches = expected.iter()
            .zip(actual.iter())
            .filter(|(expected_step, actual_step)| {
                actual_step.step_name.contains(expected_step.as_str()) || 
                expected_step.contains(&actual_step.step_name)
            })
            .count();
            
        matches as f64 / expected.len().max(1) as f64
    }
    
    async fn emit_runtime_cues(
        &self,
        trace: &[ExecutionStep],
        validation: &ValidationOutcome,
    ) -> Result<Vec<CueEmission>> {
        let mut cues = Vec::new();
        let current_time = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs();
        
        // Emit cue for low contract compliance
        if validation.contract_compliance < 0.7 {
            cues.push(CueEmission {
                cue_id: Uuid::new_v4().to_string(),
                emission_context: "low_contract_compliance".to_string(),
                suggested_improvement: format!(
                    "Contract compliance is {:.2}. Consider adding validation steps or refining contract requirements.",
                    validation.contract_compliance
                ),
                confidence_score: 0.8,
                emitted_at: current_time,
            });
        }
        
        // Emit cue for execution errors
        let error_count = trace.iter().filter(|step| step.error.is_some()).count();
        if error_count > 0 {
            cues.push(CueEmission {
                cue_id: Uuid::new_v4().to_string(),
                emission_context: "execution_errors".to_string(),
                suggested_improvement: format!(
                    "Found {} execution errors. Consider adding error handling or input validation.",
                    error_count
                ),
                confidence_score: 0.9,
                emitted_at: current_time,
            });
        }
        
        // Emit cue for performance optimization if execution took too long
        if let (Some(first), Some(last)) = (trace.first(), trace.last()) {
            let execution_duration = last.timestamp.saturating_sub(first.timestamp);
            if execution_duration > 10 { // 10 seconds threshold
                cues.push(CueEmission {
                    cue_id: Uuid::new_v4().to_string(),
                    emission_context: "performance_optimization".to_string(),
                    suggested_improvement: format!(
                        "Execution took {} seconds. Consider optimizing slow steps or adding parallel execution.",
                        execution_duration
                    ),
                    confidence_score: 0.7,
                    emitted_at: current_time,
                });
            }
        }
        
        Ok(cues)
    }
}

impl MapletRegistry {
    fn new() -> Self {
        Self {
            local_maplets: HashMap::new(),
            remote_maplets: HashMap::new(),
        }
    }
    
    fn register_local(&mut self, name: &str, maplet: Box<dyn LocalMaplet>) {
        self.local_maplets.insert(name.to_string(), maplet);
    }
    
    fn register_remote(&mut self, name: &str, signature: &str, requires_llm: bool) {
        self.remote_maplets.insert(name.to_string(), RemoteMapletDef {
            name: name.to_string(),
            signature: signature.to_string(),
            requires_llm,
        });
    }
}

// Built-in maplet implementations

struct LogMaplet;
impl LocalMaplet for LogMaplet {
    fn execute(&self, args: Vec<Value>, _context: &mut ExecutionContext) -> Result<Value> {
        let message = args.get(0)
            .and_then(|v| v.as_str())
            .unwrap_or("(no message)");
        info!("Log maplet: {}", message);
        Ok(json!({"logged": message}))
    }
    
    fn signature(&self) -> &str {
        "STRING → LogResult"
    }
}

struct ConcatMaplet;
impl LocalMaplet for ConcatMaplet {
    fn execute(&self, args: Vec<Value>, _context: &mut ExecutionContext) -> Result<Value> {
        let result = args.iter()
            .filter_map(|v| v.as_str())
            .collect::<Vec<_>>()
            .join("");
        Ok(Value::String(result))
    }
    
    fn signature(&self) -> &str {
        "[STRING] → STRING"
    }
}

struct TimestampMaplet;
impl LocalMaplet for TimestampMaplet {
    fn execute(&self, _args: Vec<Value>, _context: &mut ExecutionContext) -> Result<Value> {
        let timestamp = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs();
        Ok(json!(timestamp))
    }
    
    fn signature(&self) -> &str {
        "() → INT"
    }
}