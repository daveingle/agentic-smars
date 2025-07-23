use anyhow::Result;
use std::io::{self, Write};
use crate::planning_engine::{StepResult, PlanEvaluation};

pub struct UserInterface {
    pub interactive: bool,
}

impl UserInterface {
    pub fn new() -> Self {
        Self {
            interactive: true,
        }
    }
    
    pub fn new_non_interactive() -> Self {
        Self {
            interactive: false,
        }
    }
    
    pub fn request_clarification(&self, message: &str) -> Result<String> {
        if !self.interactive {
            return Ok("Proceed with best effort approach".to_string());
        }
        
        println!("\n❓ {}", message);
        print!("> ");
        io::stdout().flush()?;
        
        let mut input = String::new();
        io::stdin().read_line(&mut input)?;
        
        Ok(input.trim().to_string())
    }
    
    pub fn request_information(&self, prompt: &str) -> Result<String> {
        if !self.interactive {
            return Ok("Default response".to_string());
        }
        
        println!("\n📝 {}", prompt);
        print!("> ");
        io::stdout().flush()?;
        
        let mut input = String::new();
        io::stdin().read_line(&mut input)?;
        
        Ok(input.trim().to_string())
    }
    
    pub fn request_user_decision(&self, prompt: &str, options: &[String]) -> Result<String> {
        if !self.interactive {
            return Ok(options.first().unwrap_or(&String::new()).clone());
        }
        
        println!("\n🤔 {}", prompt);
        for (i, option) in options.iter().enumerate() {
            println!("  {}. {}", i + 1, option);
        }
        print!("Choose option (1-{}): ", options.len());
        io::stdout().flush()?;
        
        let mut input = String::new();
        io::stdin().read_line(&mut input)?;
        
        if let Ok(choice) = input.trim().parse::<usize>() {
            if choice > 0 && choice <= options.len() {
                return Ok(options[choice - 1].clone());
            }
        }
        
        // Default to first option if invalid input
        Ok(options.first().unwrap_or(&String::new()).clone())
    }
    
    pub fn request_next_step(&self, message: &str) -> Result<String> {
        if !self.interactive {
            return Ok("Continue with current approach".to_string());
        }
        
        println!("\n🔄 {}", message);
        print!("> ");
        io::stdout().flush()?;
        
        let mut input = String::new();
        io::stdin().read_line(&mut input)?;
        
        Ok(input.trim().to_string())
    }
    
    pub fn should_continue(&self, message: &str) -> Result<bool> {
        if !self.interactive {
            return Ok(true);
        }
        
        println!("\n🤖 {}", message);
        print!("Continue? (y/n): ");
        io::stdout().flush()?;
        
        let mut input = String::new();
        io::stdin().read_line(&mut input)?;
        
        let response = input.trim().to_lowercase();
        Ok(response == "y" || response == "yes" || response == "")
    }
    
    pub fn display_execution_results(&self, results: &[StepResult]) {
        println!("\n📊 Execution Results:");
        println!("{}", "=".repeat(50));
        
        for result in results {
            let status = if result.success { "✅" } else { "❌" };
            println!("{} Step {}: {}", status, result.step_id, result.output);
            
            if !result.artifacts_created.is_empty() {
                println!("   📁 Artifacts: {}", result.artifacts_created.join(", "));
            }
            
            if !result.errors.is_empty() {
                println!("   ⚠️  Errors: {}", result.errors.join(", "));
            }
        }
    }
    
    pub fn display_plan_evaluation(&self, evaluation: &PlanEvaluation) {
        println!("\n📈 Plan Evaluation:");
        println!("{}", "=".repeat(50));
        
        println!("✅ Successful steps: {}", evaluation.successful_steps);
        println!("❌ Failed steps: {}", evaluation.failed_steps);
        println!("🎯 Goal achieved: {}", if evaluation.goal_achieved { "Yes" } else { "No" });
        println!("🔧 Requires replanning: {}", if evaluation.requires_replanning { "Yes" } else { "No" });
        println!("📊 Confidence: {:.1}%", evaluation.confidence * 100.0);
        
        if let Some(next_prompt) = &evaluation.next_prompt {
            println!("➡️  Next: {}", next_prompt);
        }
    }
    
    pub fn display_progress(&self, current_step: usize, total_steps: usize, description: &str) {
        let progress = (current_step as f64 / total_steps as f64) * 100.0;
        let bar_length = 20;
        let filled = ((progress / 100.0) * bar_length as f64) as usize;
        let bar = "█".repeat(filled) + &"░".repeat(bar_length - filled);
        
        println!("📊 Progress: [{bar}] {progress:.1}% - Step {current_step}/{total_steps}");
        println!("   📝 {description}");
    }
    
    pub fn display_banner(&self, title: &str) {
        let width = 60;
        let title_len = title.len();
        let padding = (width - title_len - 2) / 2;
        
        println!("\n{}", "=".repeat(width));
        println!("{}{} {}", " ".repeat(padding), title, " ".repeat(width - padding - title_len - 1));
        println!("{}", "=".repeat(width));
    }
    
    pub fn display_summary(&self, cycles: usize, total_steps: u32, success_rate: f64) {
        println!("\n📋 Session Summary:");
        println!("{}", "=".repeat(50));
        println!("🔄 Planning cycles: {}", cycles);
        println!("⚡ Total steps executed: {}", total_steps);
        println!("📊 Overall success rate: {:.1}%", success_rate * 100.0);
    }
    
    pub fn display_error(&self, error: &str) {
        println!("\n❌ Error: {}", error);
    }
    
    pub fn display_warning(&self, warning: &str) {
        println!("\n⚠️  Warning: {}", warning);
    }
    
    pub fn display_info(&self, info: &str) {
        println!("\nℹ️  {}", info);
    }
    
    pub fn display_success(&self, success: &str) {
        println!("\n✅ {}", success);
    }
}

impl Default for UserInterface {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::planning_engine::StepResult;
    
    #[test]
    fn test_non_interactive_interface() {
        let ui = UserInterface::new_non_interactive();
        assert!(!ui.interactive);
        
        let result = ui.request_clarification("Test question");
        assert!(result.is_ok());
        assert_eq!(result.unwrap(), "Proceed with best effort approach");
    }
    
    #[test]
    fn test_display_results() {
        let ui = UserInterface::new_non_interactive();
        let results = vec![
            StepResult {
                step_id: "step_1".to_string(),
                success: true,
                output: "Completed successfully".to_string(),
                artifacts_created: vec!["artifact1".to_string()],
                errors: Vec::new(),
            }
        ];
        
        // This should not panic
        ui.display_execution_results(&results);
    }
}