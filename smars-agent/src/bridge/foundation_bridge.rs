use anyhow::{Result, anyhow};
use serde_json::{Value, json};
use std::process::{Command, Stdio};
use std::io::Write;
use log::{info, debug, warn};

use crate::executor::ExecutionContext;
use crate::parser::ContractDef;

pub struct FoundationBridge {
    swift_binary_path: String,
}

#[derive(serde::Serialize)]
struct LLMRequest {
    task_type: String,
    maplet_name: String,
    args: Vec<Value>,
    context: LLMContext,
}

#[derive(serde::Serialize)]
struct LLMContext {
    execution_id: String,
    variables: std::collections::HashMap<String, Value>,
    trace: Vec<String>,
}

#[derive(Debug, serde::Deserialize)]
struct LLMResponse {
    success: bool,
    result: Option<Value>,
    error: Option<String>,
    #[allow(dead_code)] // planned for LLM reasoning transparency in v0.2
    reasoning: Option<String>,
}

impl FoundationBridge {
    pub fn new() -> Self {
        Self {
            swift_binary_path: "swift-foundationmodels-agent".to_string(),
        }
    }
    
    #[allow(dead_code)] // planned for custom LLM binary integration in v0.3
    pub fn with_binary_path(path: &str) -> Self {
        Self {
            swift_binary_path: path.to_string(),
        }
    }
    
    pub async fn execute_llm_maplet(
        &self,
        maplet_name: &str,
        args: &[Value],
        context: &ExecutionContext,
    ) -> Result<Value> {
        info!("Executing LLM maplet via Swift: {}", maplet_name);
        
        let request = LLMRequest {
            task_type: "execute_maplet".to_string(),
            maplet_name: maplet_name.to_string(),
            args: args.to_vec(),
            context: LLMContext {
                execution_id: context.execution_id.clone(),
                variables: context.variables.clone(),
                trace: context.trace.iter().map(|step| step.step_name.clone()).collect(),
            },
        };
        
        let response = self.call_swift_subprocess(&request).await?;
        
        if response.success {
            Ok(response.result.unwrap_or(json!(null)))
        } else {
            Err(anyhow!(
                "LLM maplet execution failed: {}",
                response.error.unwrap_or_else(|| "Unknown error".to_string())
            ))
        }
    }
    
    pub async fn validate_contract_with_llm(
        &self,
        contract: &ContractDef,
        context: &ExecutionContext,
    ) -> Result<bool> {
        info!("Validating contract with LLM: {}", contract.name);
        
        let contract_data = json!({
            "name": contract.name,
            "requires": contract.requires,
            "ensures": contract.ensures
        });
        
        let request = LLMRequest {
            task_type: "validate_contract".to_string(),
            maplet_name: contract.name.clone(),
            args: vec![contract_data],
            context: LLMContext {
                execution_id: context.execution_id.clone(),
                variables: context.variables.clone(),
                trace: context.trace.iter().map(|step| step.step_name.clone()).collect(),
            },
        };
        
        let response = self.call_swift_subprocess(&request).await?;
        
        if response.success {
            Ok(response.result
                .and_then(|v| v.as_bool())
                .unwrap_or(false))
        } else {
            warn!("Contract validation failed: {:?}", response.error);
            Ok(false)
        }
    }
    
    #[allow(dead_code)] // planned for cue completion workflow in v0.2
    pub async fn complete_cue(
        &self,
        cue_context: &Value,
        missing_parts: &[String],
        context: &ExecutionContext,
    ) -> Result<Value> {
        info!("Completing cue via LLM");
        
        let request = LLMRequest {
            task_type: "complete_cue".to_string(),
            maplet_name: "complete_cue".to_string(),
            args: vec![
                cue_context.clone(),
                json!(missing_parts),
            ],
            context: LLMContext {
                execution_id: context.execution_id.clone(),
                variables: context.variables.clone(),
                trace: context.trace.iter().map(|step| step.step_name.clone()).collect(),
            },
        };
        
        let response = self.call_swift_subprocess(&request).await?;
        
        if response.success {
            Ok(response.result.unwrap_or(json!(null)))
        } else {
            Err(anyhow!(
                "Cue completion failed: {}",
                response.error.unwrap_or_else(|| "Unknown error".to_string())
            ))
        }
    }
    
    async fn call_swift_subprocess(&self, request: &LLMRequest) -> Result<LLMResponse> {
        debug!("Calling Swift subprocess: {}", self.swift_binary_path);
        
        let request_json = serde_json::to_string(request)?;
        debug!("Request payload: {}", request_json);
        
        let mut child = Command::new(&self.swift_binary_path)
            .arg("--json-input")
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .stderr(Stdio::piped())
            .spawn()
            .map_err(|e| anyhow!("Failed to spawn Swift subprocess: {}", e))?;
        
        // Write request to stdin
        if let Some(stdin) = child.stdin.take() {
            let mut stdin = stdin;
            stdin.write_all(request_json.as_bytes())?;
        } else {
            return Err(anyhow!("Failed to get stdin for Swift subprocess"));
        }
        
        // Wait for completion and read output
        let output = child.wait_with_output()?;
        
        if !output.status.success() {
            let stderr = String::from_utf8_lossy(&output.stderr);
            return Err(anyhow!("Swift subprocess failed: {}", stderr));
        }
        
        let stdout = String::from_utf8_lossy(&output.stdout);
        debug!("Swift subprocess response: {}", stdout);
        
        let response: LLMResponse = serde_json::from_str(&stdout)
            .map_err(|e| anyhow!("Failed to parse Swift response: {}", e))?;
        
        Ok(response)
    }
    
    #[allow(dead_code)] // planned for health monitoring in v0.2
    pub async fn test_connection(&self) -> Result<bool> {
        info!("Testing connection to Swift subprocess");
        
        let test_request = LLMRequest {
            task_type: "test".to_string(),
            maplet_name: "test".to_string(),
            args: vec![],
            context: LLMContext {
                execution_id: "test".to_string(),
                variables: std::collections::HashMap::new(),
                trace: vec![],
            },
        };
        
        match self.call_swift_subprocess(&test_request).await {
            Ok(response) => {
                info!("Swift subprocess test successful: {:?}", response);
                Ok(response.success)
            }
            Err(e) => {
                warn!("Swift subprocess test failed: {}", e);
                Ok(false)
            }
        }
    }
}