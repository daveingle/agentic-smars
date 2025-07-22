use anyhow::{Result, anyhow};
use serde_json::{Value, json};
use std::collections::HashMap;
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

#[derive(Debug, Clone)]
pub struct ExecutionStep {
    pub step_name: String,
    pub step_type: String,
    pub result: Option<Value>,
    pub error: Option<String>,
    pub timestamp: u64,
}

#[derive(Debug, Clone)]
pub struct ExecutionResult {
    pub success: bool,
    pub result: Option<Value>,
    pub trace: Vec<ExecutionStep>,
    pub contracts_validated: Vec<String>,
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

pub trait LocalMaplet {
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
        
        Ok(ExecutionResult {
            success: true,
            result: Some(json!({"plan": plan_name, "steps_executed": plan_steps.len()})),
            trace: self.execution_context.trace.clone(),
            contracts_validated,
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