use clap::Parser;
use anyhow::Result;
use log::info;
use std::path::PathBuf;

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