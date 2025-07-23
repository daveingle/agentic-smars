use anyhow::Result;
use serde_json::{Value, json};
use std::fs::{OpenOptions, create_dir_all};
use std::io::Write;
use std::path::Path;
use log::{info, warn};

use crate::executor::{ExecutionResult, ExecutionStep, CueEmission};

#[derive(Debug, serde::Serialize)]
pub struct UnifiedExecutionTrace {
    pub session_id: String,
    pub execution_id: String,
    pub plan_name: String,
    pub spec_file: String,
    pub execution_result: ExecutionResult,
    pub machine_readable_summary: MachineReadableSummary,
    pub logged_at: u64,
}

#[derive(Debug, serde::Serialize)]
pub struct MachineReadableSummary {
    pub success: bool,
    pub step_count: usize,
    pub error_count: usize,
    pub contract_compliance_score: f64,
    pub cue_emission_count: usize,
    pub execution_duration_seconds: u64,
    pub validation_passed: bool,
    pub key_metrics: std::collections::HashMap<String, Value>,
}

pub struct TraceLogger {
    log_directory: String,
    session_id: String,
}

impl TraceLogger {
    pub fn new(log_directory: &str) -> Result<Self> {
        let session_id = uuid::Uuid::new_v4().to_string();
        
        // Create log directory if it doesn't exist
        create_dir_all(log_directory)?;
        
        info!("Initialized trace logger with session: {}", session_id);
        
        Ok(Self {
            log_directory: log_directory.to_string(),
            session_id,
        })
    }
    
    pub fn log_execution(
        &self,
        plan_name: &str,
        spec_file: &str,
        execution_result: ExecutionResult,
    ) -> Result<()> {
        let execution_duration = self.calculate_execution_duration(&execution_result.trace);
        let error_count = execution_result.trace.iter()
            .filter(|step| step.error.is_some())
            .count();
        
        let mut key_metrics = std::collections::HashMap::new();
        key_metrics.insert("plan_spec_hash".to_string(), json!(execution_result.plan_spec_hash));
        key_metrics.insert("contracts_validated_count".to_string(), json!(execution_result.contracts_validated.len()));
        key_metrics.insert("round_trip_verified".to_string(), json!(execution_result.validation_outcome.round_trip_verified));
        
        let machine_summary = MachineReadableSummary {
            success: execution_result.success,
            step_count: execution_result.trace.len(),
            error_count,
            contract_compliance_score: execution_result.validation_outcome.contract_compliance,
            cue_emission_count: execution_result.cue_emissions.len(),
            execution_duration_seconds: execution_duration,
            validation_passed: execution_result.validation_outcome.round_trip_verified,
            key_metrics,
        };
        
        let trace = UnifiedExecutionTrace {
            session_id: self.session_id.clone(),
            execution_id: uuid::Uuid::new_v4().to_string(),
            plan_name: plan_name.to_string(),
            spec_file: spec_file.to_string(),
            execution_result,
            machine_readable_summary: machine_summary,
            logged_at: std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs(),
        };
        
        self.write_trace_to_file(&trace)?;
        self.append_to_session_log(&trace)?;
        
        info!("Logged execution trace for plan: {} (success: {})", plan_name, trace.machine_readable_summary.success);
        
        Ok(())
    }
    
    fn calculate_execution_duration(&self, trace: &[ExecutionStep]) -> u64 {
        if let (Some(first), Some(last)) = (trace.first(), trace.last()) {
            last.timestamp.saturating_sub(first.timestamp)
        } else {
            0
        }
    }
    
    fn write_trace_to_file(&self, trace: &UnifiedExecutionTrace) -> Result<()> {
        let filename = format!(
            "{}/execution_{}_{}.json",
            self.log_directory,
            trace.plan_name.replace(" ", "_"),
            trace.execution_id[..8].to_string()
        );
        
        let json_content = serde_json::to_string_pretty(trace)?;
        
        let mut file = OpenOptions::new()
            .create(true)
            .write(true)
            .truncate(true)
            .open(&filename)?;
            
        file.write_all(json_content.as_bytes())?;
        file.flush()?;
        
        info!("Wrote detailed trace to: {}", filename);
        Ok(())
    }
    
    fn append_to_session_log(&self, trace: &UnifiedExecutionTrace) -> Result<()> {
        let session_log_file = format!("{}/session_{}.jsonl", self.log_directory, self.session_id[..8].to_string());
        
        let log_entry = json!({
            "timestamp": trace.logged_at,
            "plan": trace.plan_name,
            "spec_file": trace.spec_file,
            "execution_id": trace.execution_id,
            "summary": trace.machine_readable_summary
        });
        
        let mut file = OpenOptions::new()
            .create(true)
            .append(true)
            .open(&session_log_file)?;
            
        writeln!(file, "{}", serde_json::to_string(&log_entry)?)?;
        file.flush()?;
        
        Ok(())
    }
    
    pub fn log_cue_emission(&self, cue: &CueEmission, context: &str) -> Result<()> {
        let cue_log_file = format!("{}/cue_emissions.jsonl", self.log_directory);
        
        let log_entry = json!({
            "session_id": self.session_id,
            "timestamp": cue.emitted_at,
            "cue_id": cue.cue_id,
            "context": context,
            "emission_context": cue.emission_context,
            "suggested_improvement": cue.suggested_improvement,
            "confidence_score": cue.confidence_score
        });
        
        let mut file = OpenOptions::new()
            .create(true)
            .append(true)
            .open(&cue_log_file)?;
            
        writeln!(file, "{}", serde_json::to_string(&log_entry)?)?;
        file.flush()?;
        
        info!("Logged cue emission: {} (confidence: {:.2})", cue.cue_id, cue.confidence_score);
        Ok(())
    }
    
    pub fn generate_session_report(&self) -> Result<SessionReport> {
        let session_log_file = format!("{}/session_{}.jsonl", self.log_directory, self.session_id[..8].to_string());
        
        if !Path::new(&session_log_file).exists() {
            warn!("No session log found for session: {}", self.session_id);
            return Ok(SessionReport::empty(self.session_id.clone()));
        }
        
        let content = std::fs::read_to_string(&session_log_file)?;
        let mut total_executions = 0;
        let mut successful_executions = 0;
        let mut total_steps = 0;
        let mut total_errors = 0;
        let mut total_cues = 0;
        let mut compliance_scores = Vec::new();
        
        for line in content.lines() {
            if let Ok(entry) = serde_json::from_str::<Value>(line) {
                if let Some(summary) = entry.get("summary") {
                    total_executions += 1;
                    
                    if summary.get("success").and_then(|v| v.as_bool()).unwrap_or(false) {
                        successful_executions += 1;
                    }
                    
                    total_steps += summary.get("step_count").and_then(|v| v.as_u64()).unwrap_or(0);
                    total_errors += summary.get("error_count").and_then(|v| v.as_u64()).unwrap_or(0);
                    total_cues += summary.get("cue_emission_count").and_then(|v| v.as_u64()).unwrap_or(0);
                    
                    if let Some(compliance) = summary.get("contract_compliance_score").and_then(|v| v.as_f64()) {
                        compliance_scores.push(compliance);
                    }
                }
            }
        }
        
        let avg_compliance = if compliance_scores.is_empty() {
            0.0
        } else {
            compliance_scores.iter().sum::<f64>() / compliance_scores.len() as f64
        };
        
        Ok(SessionReport {
            session_id: self.session_id.clone(),
            total_executions,
            successful_executions,
            success_rate: if total_executions > 0 { 
                successful_executions as f64 / total_executions as f64 
            } else { 0.0 },
            total_steps,
            total_errors,
            total_cues_emitted: total_cues,
            average_contract_compliance: avg_compliance,
            generated_at: std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs(),
        })
    }
}

#[derive(Debug, serde::Serialize)]
pub struct SessionReport {
    pub session_id: String,
    pub total_executions: u64,
    pub successful_executions: u64,
    pub success_rate: f64,
    pub total_steps: u64,
    pub total_errors: u64,
    pub total_cues_emitted: u64,
    pub average_contract_compliance: f64,
    pub generated_at: u64,
}

impl SessionReport {
    fn empty(session_id: String) -> Self {
        Self {
            session_id,
            total_executions: 0,
            successful_executions: 0,
            success_rate: 0.0,
            total_steps: 0,
            total_errors: 0,
            total_cues_emitted: 0,
            average_contract_compliance: 0.0,
            generated_at: std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs(),
        }
    }
}