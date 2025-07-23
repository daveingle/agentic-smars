use clap::Parser;
use anyhow::Result;
use std::io;
use std::path::PathBuf;

mod smars_integration;
mod user_interface;
mod agent_coordinator;
mod plan_library;

use smars_integration::SMARSIntegration;
use user_interface::UserInterface;
use agent_coordinator::AgentCoordinator;

#[derive(Parser)]
#[command(name = "smars-standalone-agent")]
#[command(about = "Self-contained SMARS agent leveraging existing specs and implementations")]
struct Cli {
    /// Initial prompt to start planning cycle
    #[arg(short, long)]
    prompt: String,
    
    /// Enable verbose logging
    #[arg(short, long)]
    verbose: bool,
    
    /// Path to SMARS specification directory (defaults to bundled specs)
    #[arg(long)]
    spec_dir: Option<PathBuf>,
    
    /// Maximum planning cycles before stopping
    #[arg(long, default_value = "10")]
    max_cycles: usize,
    
    /// Enable multi-agent spawning
    #[arg(long)]
    multi_agent: bool,
}

#[tokio::main]
async fn main() -> Result<()> {
    let cli = Cli::parse();
    
    if cli.verbose {
        env_logger::Builder::from_env(env_logger::Env::default().default_filter_or("info")).init();
    }
    
    println!("🚀 SMARS Standalone Agent");
    println!("Leveraging existing specifications and implementations");
    println!("Initial prompt: {}", cli.prompt);
    println!("{}", "=".repeat(60));
    
    // Initialize SMARS integration
    let spec_dir = cli.spec_dir.unwrap_or_else(|| PathBuf::from("./specs"));
    let mut smars = SMARSIntegration::new(spec_dir, cli.verbose).await?;
    
    // Initialize user interface
    let ui = UserInterface::new();
    
    // Initialize agent coordinator if multi-agent mode enabled
    let mut agent_coordinator = if cli.multi_agent {
        Some(AgentCoordinator::new().await?)
    } else {
        None
    };
    
    println!("✅ System initialized");
    println!("  📚 SMARS specs loaded: {}", smars.loaded_specs_count());
    if let Some(ref coordinator) = agent_coordinator {
        println!("  🤖 Agent network ready: {} agents", coordinator.agent_count());
    }
    
    // Main planning loop
    let mut cycle_count = 0;
    let mut current_prompt = cli.prompt.clone();
    
    while cycle_count < cli.max_cycles {
        cycle_count += 1;
        println!("\n🔄 Planning Cycle {}/{}", cycle_count, cli.max_cycles);
        println!("{}", "-".repeat(40));
        
        // Step 1: Parse prompt into SMARS specification
        println!("🔍 Analyzing prompt and generating SMARS plan...");
        let plan_spec = smars.generate_plan_from_prompt(&current_prompt).await?;
        
        // Step 2: Validate generated plan against baseline
        println!("✅ Validating plan against SMARS baseline...");
        let validation_result = smars.validate_plan(&plan_spec).await?;
        
        if !validation_result.is_valid {
            println!("❌ Plan validation failed:");
            for issue in &validation_result.issues {
                println!("  • {}", issue);
            }
            
            // Ask user for clarification
            let clarification = ui.request_clarification("Plan validation failed. Please provide more details or adjust your request:")?;
            current_prompt = format!("{} - {}", current_prompt, clarification);
            continue;
        }
        
        // Step 3: Execute plan using existing runtime
        println!("⚡ Executing plan using deterministic runtime...");
        let execution_result = smars.execute_plan(&plan_spec).await?;
        
        // Step 4: Handle multi-agent coordination if enabled
        if let Some(ref mut coordinator) = agent_coordinator {
            if execution_result.requires_multi_agent_coordination {
                println!("🤖 Initiating multi-agent coordination...");
                let coordination_result = coordinator.coordinate_execution(&execution_result).await?;
                
                // Display coordination results
                println!("  Agents involved: {}", coordination_result.participating_agents.len());
                println!("  Consensus reached: {}", coordination_result.consensus_achieved);
                
                if !coordination_result.consensus_achieved {
                    let user_decision = ui.request_user_decision(
                        "Agents couldn't reach consensus. How should we proceed?",
                        &coordination_result.options
                    )?;
                    
                    coordinator.apply_user_decision(&user_decision).await?;
                }
            }
        }
        
        // Step 5: Handle user interaction requests
        if execution_result.requires_user_input {
            for request in &execution_result.user_input_requests {
                let user_response = ui.request_information(&request.prompt)?;
                smars.provide_user_input(&request.id, &user_response).await?;
            }
            
            // Re-execute with user input
            println!("🔄 Re-executing with user input...");
            let final_result = smars.continue_execution().await?;
            
            // Display final results
            ui.display_execution_results(&final_result);
        } else {
            ui.display_execution_results(&execution_result);
        }
        
        // Step 6: Evaluate completion and next steps
        let evaluation = smars.evaluate_completion(&execution_result).await?;
        
        println!("\n📊 Cycle {} Results:", cycle_count);
        println!("  ✅ Success: {}", evaluation.success);
        println!("  🎯 Goal achieved: {}", evaluation.goal_achieved);
        println!("  📈 Confidence: {:.2}", evaluation.confidence);
        
        if evaluation.goal_achieved {
            println!("\n🎉 Goal successfully achieved!");
            
            // Show artifacts created
            if !evaluation.artifacts_created.is_empty() {
                println!("📁 Artifacts created:");
                for artifact in &evaluation.artifacts_created {
                    println!("  • {}", artifact);
                }
            }
            break;
        }
        
        // Step 7: Determine next cycle or stop
        if evaluation.requires_continuation {
            current_prompt = if let Some(next_prompt) = evaluation.suggested_next_prompt {
                next_prompt
            } else {
                ui.request_next_step("What should we focus on next?")?
            };
        } else {
            if !ui.should_continue("Current approach seems complete. Continue with refinements?")? {
                break;
            }
            current_prompt = ui.request_next_step("What refinements or next steps would you like?")?;
        }
    }
    
    // Final summary
    println!("\n{}", "=".repeat(60));
    println!("📊 Session Summary:");
    println!("  Cycles completed: {}", cycle_count);
    println!("  Total steps executed: {}", smars.total_steps_executed());
    
    if let Some(coordinator) = agent_coordinator {
        let stats = coordinator.get_statistics();
        println!("  Agent messages exchanged: {}", stats.messages_exchanged);
        println!("  Collaborative decisions: {}", stats.collaborative_decisions);
    }
    
    // Offer to save session
    if ui.should_continue("Save this session for later analysis?")? {
        let session_file = format!("smars_session_{}.json", chrono::Utc::now().format("%Y%m%d_%H%M%S"));
        smars.save_session(&session_file).await?;
        println!("💾 Session saved to: {}", session_file);
    }
    
    println!("👋 SMARS planning session complete!");
    
    Ok(())
}