use crate::{PlanAnalysis, ExecutionPlan, PlanStep, StepResult, PlanEvaluation};
use anyhow::Result;
use uuid::Uuid;
use std::collections::HashMap;

pub struct PlanningEngine {
    pub execution_history: Vec<StepResult>,
    pub knowledge_base: HashMap<String, String>,
    pub total_steps: u32,
}

impl PlanningEngine {
    pub fn new() -> Self {
        Self {
            execution_history: Vec::new(),
            knowledge_base: HashMap::new(),
            total_steps: 0,
        }
    }
    
    pub async fn analyze_situation(&mut self, prompt: &str) -> Result<PlanAnalysis> {
        // Simulate analysis - in production this would use LLM
        let goals = self.extract_goals_from_prompt(prompt);
        let actions = self.identify_required_actions(&goals);
        let complexity = self.calculate_complexity(&goals, &actions);
        
        let analysis = PlanAnalysis {
            situation_summary: format!("Analyzing: {}", prompt),
            identified_goals: goals,
            required_actions: actions,
            complexity_score: complexity,
        };
        
        // Store in knowledge base
        self.knowledge_base.insert("last_analysis".to_string(), serde_json::to_string(&analysis)?);
        
        Ok(analysis)
    }
    
    pub async fn generate_plan(&mut self, analysis: &PlanAnalysis) -> Result<ExecutionPlan> {
        let plan_id = Uuid::new_v4().to_string();
        let mut steps = Vec::new();
        
        // Generate steps based on analysis
        for (i, action) in analysis.required_actions.iter().enumerate() {
            let requires_input = self.action_requires_user_input(action);
            
            let step = PlanStep {
                step_id: format!("step_{}", i + 1),
                description: action.clone(),
                requires_user_input: requires_input,
                user_prompt: if requires_input {
                    format!("Please provide information for: {}", action)
                } else {
                    String::new()
                },
                estimated_duration: 30 + (i as u64 * 15), // Rough estimate
                assigned_agent: None,
            };
            
            steps.push(step);
        }
        
        // Determine if additional agents are needed
        let requires_agents = analysis.complexity_score > 0.7;
        let required_capabilities = if requires_agents {
            self.determine_required_capabilities(analysis)
        } else {
            Vec::new()
        };
        
        let plan = ExecutionPlan {
            plan_id,
            steps,
            requires_additional_agents: requires_agents,
            required_capabilities,
            estimated_completion_time: analysis.required_actions.len() as u64 * 45,
        };
        
        Ok(plan)
    }
    
    pub async fn execute_step(&mut self, step: &PlanStep) -> Result<StepResult> {
        self.total_steps += 1;
        
        // Simulate step execution
        let success = self.simulate_step_execution(&step.description);
        let output = if success {
            format!("Successfully completed: {}", step.description)
        } else {
            format!("Failed to complete: {}", step.description)
        };
        
        let result = StepResult {
            step_id: step.step_id.clone(),
            success,
            output,
            artifacts_created: if success {
                vec![format!("artifact_from_{}", step.step_id)]
            } else {
                Vec::new()
            },
            errors: if !success {
                vec!["Simulated execution failure".to_string()]
            } else {
                Vec::new()
            },
        };
        
        self.execution_history.push(result.clone());
        Ok(result)
    }
    
    pub async fn execute_step_with_input(&mut self, step: &PlanStep, user_input: &str) -> Result<StepResult> {
        self.total_steps += 1;
        
        // Incorporate user input into execution
        let enhanced_description = format!("{} (with input: {})", step.description, user_input);
        let success = self.simulate_step_execution(&enhanced_description);
        
        let output = if success {
            format!("Successfully completed: {} using input: {}", step.description, user_input)
        } else {
            format!("Failed to complete: {} even with input: {}", step.description, user_input)
        };
        
        let result = StepResult {
            step_id: step.step_id.clone(),
            success,
            output,
            artifacts_created: if success {
                vec![
                    format!("artifact_from_{}", step.step_id),
                    format!("user_input_artifact_{}", Uuid::new_v4())
                ]
            } else {
                Vec::new()
            },
            errors: if !success {
                vec!["Execution failed despite user input".to_string()]
            } else {
                Vec::new()
            },
        };
        
        self.execution_history.push(result.clone());
        Ok(result)
    }
    
    pub async fn evaluate_results(&mut self, results: &[StepResult]) -> Result<PlanEvaluation> {
        let successful_steps = results.iter().filter(|r| r.success).count() as u32;
        let failed_steps = results.iter().filter(|r| !r.success).count() as u32;
        let total_steps = results.len() as u32;
        
        // Determine if goal is achieved
        let success_rate = if total_steps > 0 {
            successful_steps as f64 / total_steps as f64
        } else {
            0.0
        };
        
        let goal_achieved = success_rate >= 0.8;
        let requires_replanning = failed_steps > 2 || success_rate < 0.5;
        
        let next_prompt = if requires_replanning {
            Some(self.generate_replan_prompt(results))
        } else if !goal_achieved {
            Some("Continue with current approach".to_string())
        } else {
            None
        };
        
        let evaluation = PlanEvaluation {
            successful_steps,
            failed_steps,
            goal_achieved,
            requires_replanning,
            next_prompt,
            confidence: success_rate,
        };
        
        Ok(evaluation)
    }
    
    pub fn total_steps_executed(&self) -> u32 {
        self.total_steps
    }
    
    // Helper methods
    
    fn extract_goals_from_prompt(&self, prompt: &str) -> Vec<String> {
        // Simple goal extraction - in production would use NLP
        if prompt.contains("create") || prompt.contains("build") || prompt.contains("develop") {
            vec!["Create/Build something".to_string()]
        } else if prompt.contains("analyze") || prompt.contains("understand") {
            vec!["Analyze/Research topic".to_string()]
        } else if prompt.contains("optimize") || prompt.contains("improve") {
            vec!["Optimize/Improve system".to_string()]
        } else {
            vec!["General task completion".to_string()]
        }
    }
    
    fn identify_required_actions(&self, goals: &[String]) -> Vec<String> {
        let mut actions = Vec::new();
        
        for goal in goals {
            if goal.contains("Create") || goal.contains("Build") {
                actions.extend(vec![
                    "Gather requirements".to_string(),
                    "Design solution".to_string(),
                    "Implement core functionality".to_string(),
                    "Test implementation".to_string(),
                    "Deploy/Package result".to_string(),
                ]);
            } else if goal.contains("Analyze") || goal.contains("Research") {
                actions.extend(vec![
                    "Collect information".to_string(),
                    "Process and categorize data".to_string(),
                    "Identify patterns and insights".to_string(),
                    "Generate summary report".to_string(),
                ]);
            } else if goal.contains("Optimize") || goal.contains("Improve") {
                actions.extend(vec![
                    "Baseline current performance".to_string(),
                    "Identify bottlenecks".to_string(),
                    "Implement improvements".to_string(),
                    "Measure impact".to_string(),
                ]);
            } else {
                actions.extend(vec![
                    "Break down task into components".to_string(),
                    "Execute each component".to_string(),
                    "Validate results".to_string(),
                ]);
            }
        }
        
        actions
    }
    
    fn calculate_complexity(&self, goals: &[String], actions: &[String]) -> f64 {
        let goal_complexity = goals.len() as f64 * 0.2;
        let action_complexity = actions.len() as f64 * 0.1;
        
        (goal_complexity + action_complexity).min(1.0)
    }
    
    fn action_requires_user_input(&self, action: &str) -> bool {
        action.contains("requirements") || 
        action.contains("information") || 
        action.contains("specify") ||
        action.contains("Gather")
    }
    
    fn determine_required_capabilities(&self, analysis: &PlanAnalysis) -> Vec<String> {
        let mut capabilities = Vec::new();
        
        if analysis.situation_summary.contains("create") || analysis.situation_summary.contains("build") {
            capabilities.push("code_generation".to_string());
            capabilities.push("testing".to_string());
        }
        
        if analysis.situation_summary.contains("analyze") {
            capabilities.push("data_analysis".to_string());
            capabilities.push("research".to_string());
        }
        
        if analysis.complexity_score > 0.8 {
            capabilities.push("project_management".to_string());
        }
        
        capabilities
    }
    
    fn simulate_step_execution(&self, description: &str) -> bool {
        // Simulate variable success rates based on step type
        use std::collections::hash_map::DefaultHasher;
        use std::hash::{Hash, Hasher};
        
        let mut hasher = DefaultHasher::new();
        description.hash(&mut hasher);
        let hash = hasher.finish();
        
        // Base success rate on step complexity
        let base_success_rate = if description.contains("Gather") || description.contains("Collect") {
            0.9 // High success rate for information gathering
        } else if description.contains("Implement") || description.contains("Test") {
            0.7 // Medium success rate for implementation
        } else if description.contains("Deploy") || description.contains("Optimize") {
            0.6 // Lower success rate for complex operations
        } else {
            0.8 // Default success rate
        };
        
        (hash % 100) as f64 / 100.0 < base_success_rate
    }
    
    fn generate_replan_prompt(&self, results: &[StepResult]) -> String {
        let failed_steps: Vec<&str> = results.iter()
            .filter(|r| !r.success)
            .map(|r| r.step_id.as_str())
            .collect();
        
        if failed_steps.len() > 1 {
            format!("Multiple steps failed ({}). Let's simplify the approach.", failed_steps.join(", "))
        } else if !failed_steps.is_empty() {
            format!("Step {} failed. Let's try a different approach.", failed_steps[0])
        } else {
            "Let's refine our strategy based on partial results.".to_string()
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[tokio::test]
    async fn test_planning_engine_creation() {
        let engine = PlanningEngine::new();
        assert_eq!(engine.total_steps, 0);
        assert!(engine.execution_history.is_empty());
    }
    
    #[tokio::test]
    async fn test_situation_analysis() {
        let mut engine = PlanningEngine::new();
        let result = engine.analyze_situation("Create a web application").await;
        assert!(result.is_ok());
        
        let analysis = result.unwrap();
        assert!(!analysis.identified_goals.is_empty());
        assert!(!analysis.required_actions.is_empty());
        assert!(analysis.complexity_score > 0.0);
    }
    
    #[tokio::test]
    async fn test_plan_generation() {
        let mut engine = PlanningEngine::new();
        let analysis = engine.analyze_situation("Build a simple tool").await.unwrap();
        let plan = engine.generate_plan(&analysis).await.unwrap();
        
        assert!(!plan.steps.is_empty());
        assert!(!plan.plan_id.is_empty());
    }
}