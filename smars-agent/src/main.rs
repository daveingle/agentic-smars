use clap::Parser;
use anyhow::Result;
use log::info;
use std::path::PathBuf;

mod parser;
mod executor;
mod bridge;

use crate::parser::SmarsParser;
use crate::executor::SmarsExecutor;

#[derive(Parser)]
#[command(name = "smars-agent")]
#[command(about = "A cross-runtime SMARS agent with Rust execution and Swift LLM integration")]
struct Cli {
    /// Path to SMARS specification file
    #[arg(short, long)]
    spec: PathBuf,
    
    /// Plan name to execute
    #[arg(short, long)]
    plan: Option<String>,
    
    /// Enable Swift FoundationModels integration
    #[arg(short = 'f', long)]
    foundation_models: bool,
    
    /// Enable verbose logging
    #[arg(short, long)]
    verbose: bool,
}

#[tokio::main]
async fn main() -> Result<()> {
    let cli = Cli::parse();
    
    if cli.verbose {
        env_logger::Builder::from_env(env_logger::Env::default().default_filter_or("info")).init();
    }
    
    info!("Starting SMARS agent with spec: {:?}", cli.spec);
    
    // Load and parse SMARS specification
    let spec_content = std::fs::read_to_string(&cli.spec)?;
    let mut parser = SmarsParser::new();
    let ast = parser.parse(&spec_content)?;
    
    info!("Parsed {} SMARS constructs", ast.len());
    
    // Create executor with optional Swift bridge
    let mut executor = SmarsExecutor::new(cli.foundation_models);
    
    // Execute specified plan or show available plans
    match cli.plan {
        Some(plan_name) => {
            info!("Executing plan: {}", plan_name);
            let result = executor.execute_plan(&plan_name, &ast).await?;
            println!("Plan execution result: {:?}", result);
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
