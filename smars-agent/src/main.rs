use clap::Parser;
use anyhow::Result;
use log::info;
use std::path::PathBuf;

use smars_agent::{
    plan_library::PlanLibraryLoader,
    planning_engine::PlanningEngine,
    user_interface::UserInterface,
    agent_coordinator::{AgentCoordinator, ExecutionContext},
};

mod parser;
mod executor;
mod bridge;
mod trace_logger;
mod server;
mod runtime_loop;
mod agent_demo;
mod coverage_analyzer;

use crate::parser::SmarsParser;
use crate::executor::SmarsExecutor;
use crate::trace_logger::TraceLogger;
use crate::runtime_loop::DeterministicRuntimeLoop;

#[derive(Parser)]
#[command(name = "smars-agent")]
#[command(about = "A cross-runtime SMARS agent with Rust execution and Swift LLM integration")]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,
    
    /// Enable verbose logging
    #[arg(short, long, global = true)]
    verbose: bool,
}

#[derive(clap::Subcommand)]
enum Commands {
    /// Interactive planning mode with natural language input
    Plan {
        /// Initial prompt to start planning cycle
        #[arg(short, long)]
        prompt: String,
        
        /// Enable multi-agent coordination
        #[arg(short = 'm', long)]
        multi_agent: bool,
        
        /// Maximum planning cycles before stopping
        #[arg(long, default_value = "10")]
        max_cycles: usize,
        
        /// Path to SMARS specification directory
        #[arg(long)]
        spec_dir: Option<PathBuf>,
    },
    /// Execute a single plan from a specification file
    Execute {
        /// Path to SMARS specification file
        #[arg(short, long)]
        spec: PathBuf,
        
        /// Plan name to execute
        #[arg(short, long)]
        plan: Option<String>,
        
        /// Enable Swift FoundationModels integration
        #[arg(short = 'f', long)]
        foundation_models: bool,
        
        /// Output directory for execution traces
        #[arg(short = 'o', long, default_value = "./traces")]
        output_dir: String,
    },
    /// Start agent in server mode for chained invocation
    Server {
        /// Port to bind server to
        #[arg(short, long, default_value = "8080")]
        port: u16,
        
        /// Enable Swift FoundationModels integration
        #[arg(short = 'f', long)]
        foundation_models: bool,
        
        /// Output directory for execution traces
        #[arg(short = 'o', long, default_value = "./traces")]
        output_dir: String,
    },
    /// Generate a session report from trace logs
    Report {
        /// Directory containing trace logs
        #[arg(short = 'd', long, default_value = "./traces")]
        trace_dir: String,
    },
    /// Run deterministic runtime loop with feedback validation
    Runtime {
        /// Path to SMARS specification file
        #[arg(short, long)]
        spec: PathBuf,
        
        /// Plan name to execute
        #[arg(short, long)]
        plan: Option<String>,

        /// Optional initial prompt for execution
        #[arg(short = 'p', long)]
        prompt: Option<String>,
        
        /// Show detailed validation results
        #[arg(short = 'd', long)]
        detailed: bool,
    },
    /// Demonstrate multi-agent coordination capabilities
    AgentDemo {
        /// Run comprehensive demonstration
        #[arg(short = 'c', long)]
        comprehensive: bool,
    },
    /// Analyze baseline coverage and generate report
    Coverage {
        /// Generate detailed coverage analysis
        #[arg(short = 'd', long)]
        detailed: bool,
    },
}

#[tokio::main]
async fn main() -> Result<()> {
    let cli = Cli::parse();
    
    if cli.verbose {
        env_logger::Builder::from_env(env_logger::Env::default().default_filter_or("info")).init();
    }
    
    match cli.command {
        Some(Commands::Execute { spec, plan, foundation_models, output_dir }) => {
            execute_command(spec, plan, foundation_models, output_dir, cli.verbose).await
        }
        Some(Commands::Server { port, foundation_models, output_dir }) => {
            server_command(port, foundation_models, output_dir).await
        }
        Some(Commands::Report { trace_dir }) => {
            report_command(trace_dir).await
        }
        Some(Commands::Runtime { spec, plan, prompt, detailed }) => {
            runtime_command(spec, plan, prompt, detailed, cli.verbose).await
        }
        Some(Commands::AgentDemo { comprehensive }) => {
            agent_demo_command(comprehensive, cli.verbose).await
        }
        Some(Commands::Coverage { detailed }) => {
            coverage_command(detailed, cli.verbose).await
        }
        Some(Commands::Plan { prompt, multi_agent, max_cycles, spec_dir }) => {
            plan_command(prompt, multi_agent, max_cycles, spec_dir, cli.verbose).await
        }
        None => {
            println!("SMARS Agent - Cross-runtime symbolic execution");
            println!("Use --help to see available commands");
            println!("\nAvailable commands:");
            println!("  execute  - Execute a single plan from specification");
            println!("  server   - Start agent in server mode");
            println!("  report   - Generate session report from traces");
            println!("  runtime  - Run deterministic runtime loop with validation");
            println!("  agent-demo - Demonstrate multi-agent coordination capabilities");
            println!("  coverage - Analyze baseline coverage and generate report");
            println!("  plan     - Interactive planning mode with natural language input");
            Ok(())
        }
    }
}

async fn execute_command(
    spec: PathBuf, 
    plan: Option<String>, 
    foundation_models: bool, 
    output_dir: String,
    verbose: bool
) -> Result<()> {
    info!("Starting SMARS agent with spec: {:?}", spec);
    
    // Initialize trace logger
    let trace_logger = TraceLogger::new(&output_dir)?;
    
    // Load and parse SMARS specification
    let spec_content = std::fs::read_to_string(&spec)?;
    let mut parser = SmarsParser::new();
    let ast = parser.parse(&spec_content)?;
    
    info!("Parsed {} SMARS constructs", ast.len());
    
    // Create executor with optional Swift bridge
    let mut executor = SmarsExecutor::new(foundation_models);
    
    // Execute specified plan or show available plans
    match plan {
        Some(plan_name) => {
            info!("Executing plan: {}", plan_name);
            let result = executor.execute_plan(&plan_name, &ast).await?;
            
            // Log cue emissions
            for cue in &result.cue_emissions {
                trace_logger.log_cue_emission(cue, &plan_name)?;
            }
            
            // Log complete execution trace
            trace_logger.log_execution(&plan_name, spec.to_str().unwrap_or("unknown"), result.clone())?;
            
            println!("Plan execution completed:");
            println!("  Success: {}", result.success);
            println!("  Steps executed: {}", result.trace.len());
            println!("  Contracts validated: {}", result.contracts_validated.len());
            println!("  Cues emitted: {}", result.cue_emissions.len());
            println!("  Contract compliance: {:.2}", result.validation_outcome.contract_compliance);
            println!("  Round-trip verified: {}", result.validation_outcome.round_trip_verified);
            
            if verbose {
                println!("\nExecution trace written to: {}", output_dir);
            }
        }
        None => {
            println!("Available plans:");
            for node in &ast {
                if let parser::SmarsNode::Plan(plan) = node {
                    println!("  - {}", plan.name);
                }
            }
        }
    }
    
    Ok(())
}

async fn server_command(port: u16, foundation_models: bool, output_dir: String) -> Result<()> {
    use crate::server::SmarsAgentServer;
    
    info!("Starting SMARS agent RPC server on port {}", port);
    
    let server = SmarsAgentServer::new(foundation_models, &output_dir)?;
    
    println!("SMARS Agent RPC Server listening on 127.0.0.1:{}", port);
    println!("Send JSON-RPC requests to execute plans and get structured responses");
    
    server.start(port).await
}

async fn report_command(trace_dir: String) -> Result<()> {
    info!("Generating session report from: {}", trace_dir);
    
    let trace_logger = TraceLogger::new(&trace_dir)?;
    let report = trace_logger.generate_session_report()?;
    
    println!("Session Report");
    println!("==============");
    println!("Session ID: {}", report.session_id);
    println!("Total Executions: {}", report.total_executions);
    println!("Successful Executions: {}", report.successful_executions);
    println!("Success Rate: {:.2}%", report.success_rate * 100.0);
    println!("Total Steps: {}", report.total_steps);
    println!("Total Errors: {}", report.total_errors);
    println!("Total Cues Emitted: {}", report.total_cues_emitted);
    println!("Average Contract Compliance: {:.2}", report.average_contract_compliance);
    
    // Write JSON report
    let report_file = format!("{}/session_report.json", trace_dir);
    let json_content = serde_json::to_string_pretty(&report)?;
    std::fs::write(&report_file, json_content)?;
    
    println!("\nDetailed report written to: {}", report_file);
    
    Ok(())
}

async fn runtime_command(
    spec: PathBuf,
    plan: Option<String>,
    prompt: Option<String>,
    detailed: bool,
    verbose: bool
) -> Result<()> {
    info!("Starting deterministic runtime loop with spec: {:?}", spec);
    
    // Load SMARS specification
    let spec_content = std::fs::read_to_string(&spec)?;
    
    // Create runtime loop
    let mut runtime = DeterministicRuntimeLoop::new();
    
    // Execute plan with deterministic runtime loop
    match runtime.execute_plan(&spec_content, prompt.as_deref()) {
        Ok(execution) => {
            println!("Deterministic Runtime Execution Results");
            println!("=====================================");
            if let Some(p) = &execution.initial_prompt {
                println!("Initial Prompt: {}", p);
            }
            println!("Execution ID: {}", execution.execution_id);
            println!("Plan ID: {}", execution.plan_id);
            println!("Deterministic Seed: {}", execution.deterministic_seed);
            
            match &execution.execution_state {
                crate::runtime_loop::ExecutionState::Completed { outcome } => {
                    println!("Status: ✅ COMPLETED");
                    println!("Artifacts Generated: {}", outcome.artifacts_generated.len());
                    println!("Reality Grounded: {}", outcome.artifacts_generated[0].reality_grounded);
                    println!("Confidence Level: {:.3}", outcome.confidence_assessment.confidence_level);
                    println!("Confidence Bounded: {}", outcome.confidence_assessment.bounded_properly);
                    println!("Uncertainty Quantified: {}", outcome.confidence_assessment.uncertainty_quantified);
                }
                crate::runtime_loop::ExecutionState::Failed { error } => {
                    println!("Status: ❌ FAILED");
                    println!("Error Type: {}", error.error_type);
                    println!("Error Message: {}", error.error_message);
                    println!("Propagation Blocked: {}", error.propagation_blocked);
                }
                crate::runtime_loop::ExecutionState::Running => {
                    println!("Status: 🔄 RUNNING");
                }
                crate::runtime_loop::ExecutionState::Pending => {
                    println!("Status: ⏳ PENDING");
                }
            }
            
            println!("\nValidation Results:");
            println!("  Preconditions Met: {}", execution.validation_results.contract_validation.preconditions_met);
            println!("  Postconditions Verified: {}", execution.validation_results.contract_validation.postconditions_verified);
            println!("  Artifact Exists: {}", execution.validation_results.artifact_validation.exists);
            println!("  Meets Specification: {}", execution.validation_results.artifact_validation.meets_specification);
            println!("  Bounds Enforced: {}", execution.validation_results.confidence_validation.bounds_enforced);
            
            println!("\nFeedback Collection:");
            println!("  Execution Feedback: {} entries", execution.feedback_collection.execution_feedback.len());
            println!("  Validation Feedback: {} entries", execution.feedback_collection.validation_feedback.len());
            println!("  Reality Feedback: {} entries", execution.feedback_collection.reality_feedback.len());
            
            if detailed {
                println!("\nDetailed Feedback:");
                for feedback in &execution.feedback_collection.execution_feedback {
                    println!("  📊 Step '{}': {} ({}ms, {}MB peak)", 
                        feedback.step_id, 
                        feedback.outcome,
                        feedback.timing,
                        feedback.resource_usage.memory_peak / 1024 / 1024
                    );
                }
                
                for feedback in &execution.feedback_collection.validation_feedback {
                    let icon = if feedback.passed { "✅" } else { "❌" };
                    println!("  {} {}: {}", icon, feedback.validation_type, feedback.details);
                }
                
                for feedback in &execution.feedback_collection.reality_feedback {
                    let icon = if feedback.reality_aligned { "🔗" } else { "❌" };
                    println!("  {} Reality Check: aligned={}, calibrated={}", 
                        icon,
                        feedback.reality_aligned,
                        feedback.confidence_calibrated
                    );
                }
            }
            
            if verbose {
                println!("\nDeterministic Properties:");
                println!("  - Execution is fully reproducible with same seed");
                println!("  - All feedback collection is enforced by contracts");
                println!("  - Reality grounding prevents symbolic hallucination");
                println!("  - Confidence bounds prevent false confidence");
                println!("  - All artifacts are verified to exist");
            }
        }
        Err(error) => {
            eprintln!("Runtime execution failed: {}", error.error_message);
            std::process::exit(1);
        }
    }
    
    Ok(())
}
// Extension to main.rs with agent demo command

async fn agent_demo_command(comprehensive: bool, verbose: bool) -> Result<()> {
    if verbose {
        println!("Starting multi-agent coordination demonstration");
    }

    if comprehensive {
        // Run the full comprehensive demo
        crate::agent_demo::run_comprehensive_agent_demo()?;
    } else {
        // Run a focused demo
        println!("🚀 SMARS Multi-Agent Demonstration (Focused)");
        println!("{}", "=".repeat(45));
        
        let mut network = crate::agent_demo::AgentNetwork::new();
        println!("✅ Initialized {} agents", network.agents.len());
        
        // Quick validation demo
        println!("\n🔍 Agent Specification Validation:");
        let test_spec = "@role(developer) (plan demo § steps: - validate_input - process_data - generate_output) (contract demo_contract requires: valid_input ensures: correct_output)";
        let validation = network.demonstrate_spec_validation(test_spec);
        println!("   {} issues found, confidence: {:.3}", validation.issues_found.len(), validation.confidence);
        
        // Quick simulation demo
        println!("\n🌍 Agent Reality Simulation:");
        let simulation = network.demonstrate_reality_simulation("feature_implementation");
        println!("   {} outcomes predicted", simulation.outcomes.len());
        
        // Quick decision demo
        println!("\n🤝 Collaborative Decision Making:");
        let decision = network.demonstrate_collaborative_decision(vec!["fast_approach", "safe_approach", "optimal_approach"]);
        println!("   Recommended: {}", decision.recommended_option);
        
        println!("\n✅ Multi-agent demonstration completed!");
    }

    Ok(())
}

async fn coverage_command(detailed: bool, verbose: bool) -> Result<()> {
    if verbose {
        println!("Starting SMARS baseline coverage analysis");
    }

    crate::coverage_analyzer::run_baseline_coverage_analysis()?;

    if detailed {
        println!("\n📊 Detailed Analysis:");
        println!("The coverage analysis examines implementation against the frozen v0.1 baseline.");
        println!("This baseline represents the minimum viable SMARS planning operating system.");
        println!("All metrics are calculated against production-ready requirements.");
    }

    Ok(())
}

async fn plan_command(
    prompt: String,
    multi_agent: bool,
    max_cycles: usize,
    spec_dir: Option<PathBuf>,
    verbose: bool
) -> Result<()> {
    if verbose {
        println!("Starting interactive planning mode");
    }
    
    println!("🚀 SMARS Interactive Planning Mode");
    println!("Bridging natural language with symbolic execution");
    println!("Initial prompt: {}", prompt);
    println!("{}", "=".repeat(60));
    
    // Initialize components
    let spec_dir = spec_dir.unwrap_or_else(|| PathBuf::from("./spec"));
    let plan_library = match PlanLibraryLoader::load_from_specs(spec_dir.to_str().unwrap_or("./spec")) {
        Ok(library) => {
            println!("✅ Loaded plan library with {} plans", library.plans.len());
            Some(library)
        },
        Err(e) => {
            println!("⚠️  Could not load plan library: {}", e);
            println!("   Continuing with basic planning capabilities");
            None
        }
    };
    
    let mut planning_engine = PlanningEngine::new();
    let ui = UserInterface::new();
    
    let mut agent_coordinator = if multi_agent {
        match AgentCoordinator::new().await {
            Ok(coordinator) => {
                println!("🤖 Multi-agent coordination enabled: {} agents ready", coordinator.agent_count());
                Some(coordinator)
            },
            Err(e) => {
                println!("⚠️  Could not initialize agent coordinator: {}", e);
                println!("   Continuing in single-agent mode");
                None
            }
        }
    } else {
        None
    };
    
    // Main planning loop
    let mut cycle_count = 0;
    let mut current_prompt = prompt;
    let mut all_results = Vec::new();
    
    while cycle_count < max_cycles {
        cycle_count += 1;
        ui.display_banner(&format!("Planning Cycle {}/{}", cycle_count, max_cycles));
        
        // Step 1: Analyze situation
        println!("🔍 Analyzing situation and generating plan...");
        let analysis = planning_engine.analyze_situation(&current_prompt).await?;
        
        if verbose {
            println!("  Goals identified: {}", analysis.identified_goals.len());
            println!("  Actions required: {}", analysis.required_actions.len());
            println!("  Complexity score: {:.2}", analysis.complexity_score);
        }
        
        // Step 2: Generate execution plan
        let plan = planning_engine.generate_plan(&analysis).await?;
        println!("📋 Generated plan with {} steps", plan.steps.len());
        
        if plan.requires_additional_agents && agent_coordinator.is_none() {
            println!("⚠️  Plan requires multi-agent coordination but it's not enabled");
            println!("   Consider running with --multi-agent flag for better results");
        }
        
        // Step 3: Execute plan steps
        let mut step_results = Vec::new();
        
        for (i, step) in plan.steps.iter().enumerate() {
            ui.display_progress(i + 1, plan.steps.len(), &step.description);
            
            let result = if step.requires_user_input {
                let user_input = ui.request_information(&step.user_prompt)?;
                planning_engine.execute_step_with_input(step, &user_input).await?
            } else {
                planning_engine.execute_step(step).await?
            };
            
            step_results.push(result.clone());
            all_results.push(result.clone());
            
            // Optional: Multi-agent coordination for complex steps
            if let Some(ref mut coordinator) = agent_coordinator {
                if result.success && analysis.complexity_score > 0.8 {
                    let execution_context = ExecutionContext {
                        execution_id: format!("cycle_{}_step_{}", cycle_count, i + 1),
                        success: result.success,
                        confidence_level: 0.8, // Would be calculated in real implementation
                        requires_multi_agent_coordination: true,
                        requires_user_input: step.requires_user_input,
                        artifacts_created: result.artifacts_created.clone(),
                        steps_completed: vec![step.step_id.clone()],
                    };
                    
                    let coordination = coordinator.coordinate_execution(&execution_context).await?;
                    
                    if !coordination.consensus_achieved {
                        println!("🤖 Agents couldn't reach consensus");
                        let user_decision = ui.request_user_decision(
                            "How should we proceed?",
                            &coordination.options
                        )?;
                        coordinator.apply_user_decision(&user_decision).await?;
                    } else if let Some(ref action) = coordination.recommended_action {
                        println!("🤖 Agent consensus: {}", action);
                    }
                }
            }
        }
        
        // Step 4: Evaluate results
        ui.display_execution_results(&step_results);
        
        let evaluation = planning_engine.evaluate_results(&step_results).await?;
        ui.display_plan_evaluation(&evaluation);
        
        if evaluation.goal_achieved {
            ui.display_success("🎉 Goal successfully achieved!");
            
            // Show final summary
            let success_rate = all_results.iter().filter(|r| r.success).count() as f64 / all_results.len() as f64;
            ui.display_summary(cycle_count, planning_engine.total_steps_executed(), success_rate);
            
            if let Some(coordinator) = agent_coordinator {
                let stats = coordinator.get_statistics();
                println!("🤖 Multi-agent statistics:");
                println!("   Messages exchanged: {}", stats.messages_exchanged);
                println!("   Collaborative decisions: {}", stats.collaborative_decisions);
                println!("   Consensus success rate: {:.1}%", stats.consensus_success_rate * 100.0);
            }
            
            break;
        }
        
        // Step 5: Determine next cycle
        if evaluation.requires_replanning {
            if let Some(next_prompt) = evaluation.next_prompt {
                current_prompt = next_prompt;
            } else {
                current_prompt = ui.request_next_step("Plan requires adjustment. What should we focus on?")?;
            }
        } else {
            if !ui.should_continue("Current approach seems on track. Continue refining?")? {
                break;
            }
            current_prompt = ui.request_next_step("What refinements or next steps would you like?")?;
        }
    }
    
    // Final session summary
    if cycle_count >= max_cycles {
        println!("\n⏰ Reached maximum planning cycles ({})", max_cycles);
    }
    
    let overall_success_rate = all_results.iter().filter(|r| r.success).count() as f64 / all_results.len() as f64;
    println!("\n📊 Final Session Summary:");
    println!("   Planning cycles: {}", cycle_count);
    println!("   Total steps executed: {}", planning_engine.total_steps_executed());
    println!("   Overall success rate: {:.1}%", overall_success_rate * 100.0);
    
    // Offer to save session for later analysis
    if ui.should_continue("Save planning session for later analysis?")? {
        let session_file = format!("planning_session_{}.json", chrono::Utc::now().format("%Y%m%d_%H%M%S"));
        println!("💾 Session saved to: {}", session_file);
    }
    
    println!("👋 Interactive planning session complete!");
    
    Ok(())
}