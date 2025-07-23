use anyhow::Result;
use std::io::{self, Write};
use crate::smars_integration::ExecutionResult;

pub struct UserInterface {
    // State for managing user interactions
}

impl UserInterface {
    pub fn new() -> Self {
        Self {}
    }
    
    pub fn request_information(&self, prompt: &str) -> Result<String> {
        self.get_user_input(&format!("💬 {}", prompt))
    }
    
    pub fn request_clarification(&self, message: &str) -> Result<String> {
        self.get_user_input(&format!("❓ {}", message))
    }
    
    pub fn request_user_decision(&self, message: &str, options: &[String]) -> Result<String> {
        println!("🤔 {}", message);
        println!("Available options:");
        for (i, option) in options.iter().enumerate() {
            println!("  {}: {}", i + 1, option);
        }
        
        loop {
            let input = self.get_user_input("Enter your choice (number or option name):")?;
            
            // Try to parse as number
            if let Ok(num) = input.parse::<usize>() {
                if num > 0 && num <= options.len() {
                    return Ok(options[num - 1].clone());
                }
            }
            
            // Try to match option name
            for option in options {
                if option.to_lowercase().contains(&input.to_lowercase()) {
                    return Ok(option.clone());
                }
            }
            
            println!("❌ Invalid choice. Please try again.");
        }
    }
    
    pub fn request_next_step(&self, prompt: &str) -> Result<String> {
        self.get_user_input(&format!("🔄 {}", prompt))
    }
    
    pub fn should_continue(&self, prompt: &str) -> Result<bool> {
        let response = self.get_user_input(&format!("❓ {} (y/n)", prompt))?;
        Ok(response.to_lowercase().starts_with('y'))
    }
    
    pub fn display_execution_results(&self, result: &ExecutionResult) {
        println!("\n📊 Execution Results:");
        println!("  🆔 ID: {}", result.execution_id);
        println!("  ✅ Success: {}", result.success);
        println!("  📈 Confidence: {:.2}", result.confidence_level);
        println!("  🔗 Reality Grounded: {}", result.reality_grounded);
        
        if !result.artifacts_created.is_empty() {
            println!("  📁 Artifacts Created:");
            for artifact in &result.artifacts_created {
                println!("    • {}", artifact);
            }
        }
        
        if !result.steps_completed.is_empty() {
            println!("  📋 Steps Completed:");
            for step in &result.steps_completed {
                let status = if step.success { "✅" } else { "❌" };
                println!("    {} {} ({}ms)", status, step.description, step.duration_ms);
                if !step.output.is_empty() {
                    println!("      Output: {}", step.output);
                }
            }
        }
        
        if result.requires_user_input {
            println!("  💬 User input required for {} requests", result.user_input_requests.len());
        }
        
        if result.requires_multi_agent_coordination {
            println!("  🤖 Multi-agent coordination required");
        }
    }
    
    pub fn display_banner(&self, title: &str) {
        println!("\n{}", "=".repeat(60));
        println!("🎯 {}", title);
        println!("{}", "=".repeat(60));
    }
    
    pub fn display_progress(&self, current: usize, total: usize, message: &str) {
        let percentage = if total > 0 {
            (current * 100) / total
        } else {
            0
        };
        
        let bar_length = 30;
        let filled = (percentage * bar_length) / 100;
        let bar = "█".repeat(filled) + &"░".repeat(bar_length - filled);
        
        println!("📊 Progress: [{}] {}% - {}", bar, percentage, message);
    }
    
    pub fn display_error(&self, error: &str) {
        println!("❌ Error: {}", error);
    }
    
    pub fn display_warning(&self, warning: &str) {
        println!("⚠️  Warning: {}", warning);
    }
    
    pub fn display_info(&self, info: &str) {
        println!("ℹ️  {}", info);
    }
    
    pub fn display_success(&self, message: &str) {
        println!("✅ {}", message);
    }
    
    fn get_user_input(&self, prompt: &str) -> Result<String> {
        print!("{}: ", prompt);
        io::stdout().flush()?;
        
        let mut input = String::new();
        io::stdin().read_line(&mut input)?;
        
        Ok(input.trim().to_string())
    }
}