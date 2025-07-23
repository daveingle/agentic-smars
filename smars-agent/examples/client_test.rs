use anyhow::Result;
use smars_agent::server::SmarsAgentClient;

#[tokio::main]
async fn main() -> Result<()> {
    env_logger::init();
    
    let client = SmarsAgentClient::new("127.0.0.1:8080");
    
    // Test health check
    println!("Testing health check...");
    match client.health_check().await {
        Ok(health) => {
            println!("Health check successful:");
            println!("  Status: {}", health.status);
            println!("  Agent ready: {}", health.agent_ready);
            println!("  Foundation models: {}", health.foundation_models_available);
        }
        Err(e) => {
            eprintln!("Health check failed: {}", e);
            return Ok(());
        }
    }
    
    // Test plan execution
    println!("\nTesting plan execution...");
    
    let spec_content = r#"
# Test SMARS Plan

```smars
(• ⟦test_message⟧ message ∷ STRING = "Hello from RPC client")

(ƒ log_message ∷ STRING → Result)

(§ test_rpc_plan
  steps:
    - apply log_message ▸ "Starting RPC test"
    - apply get_timestamp
    - apply log_message ▸ "RPC test completed successfully"
)
```
"#;
    
    match client.execute_plan(spec_content, "test_rpc_plan", false).await {
        Ok(response) => {
            println!("Plan execution response:");
            println!("  Success: {}", response.success);
            println!("  Request ID: {}", response.request_id);
            
            if let Some(result) = &response.execution_result {
                println!("  Steps executed: {}", result.trace.len());
                println!("  Contracts validated: {}", result.contracts_validated.len());
                println!("  Cues emitted: {}", result.cue_emissions.len());
                println!("  Contract compliance: {:.2}", result.validation_outcome.contract_compliance);
                println!("  Round-trip verified: {}", result.validation_outcome.round_trip_verified);
                
                if !result.cue_emissions.is_empty() {
                    println!("  Emitted cues:");
                    for cue in &result.cue_emissions {
                        println!("    - {}: {} (confidence: {:.2})", 
                            cue.emission_context, 
                            cue.suggested_improvement,
                            cue.confidence_score);
                    }
                }
            }
            
            if let Some(trace_path) = &response.trace_log_path {
                println!("  Trace logged to: {}", trace_path);
            }
            
            if let Some(error) = &response.error_message {
                println!("  Error: {}", error);
            }
        }
        Err(e) => {
            eprintln!("Plan execution failed: {}", e);
        }
    }
    
    Ok(())
}