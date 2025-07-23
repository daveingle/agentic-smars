use anyhow::Result;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use uuid::Uuid;
use crate::smars_integration::ExecutionResult;

// Re-use agent types from the main implementation
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Agent {
    pub agent_id: String,
    pub agent_type: AgentType,
    pub capabilities: Vec<String>,
    pub confidence_level: f64,
    pub active: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum AgentType {
    ValidationAgent,
    SimulationAgent,
    DecisionAgent,
    ExecutionAgent,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CoordinationResult {
    pub coordination_id: String,
    pub participating_agents: Vec<String>,
    pub consensus_achieved: bool,
    pub options: Vec<String>,
    pub recommended_action: Option<String>,
    pub confidence: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CoordinationStatistics {
    pub messages_exchanged: u64,
    pub collaborative_decisions: u64,
    pub consensus_success_rate: f64,
    pub average_response_time_ms: f64,
}

pub struct AgentCoordinator {
    agents: HashMap<String, Agent>,
    coordination_history: Vec<CoordinationResult>,
    statistics: CoordinationStatistics,
}

impl AgentCoordinator {
    pub async fn new() -> Result<Self> {
        let mut coordinator = Self {
            agents: HashMap::new(),
            coordination_history: Vec::new(),
            statistics: CoordinationStatistics {
                messages_exchanged: 0,
                collaborative_decisions: 0,
                consensus_success_rate: 0.0,
                average_response_time_ms: 0.0,
            },
        };
        
        // Initialize core agents
        coordinator.initialize_core_agents().await?;
        
        Ok(coordinator)
    }
    
    async fn initialize_core_agents(&mut self) -> Result<()> {
        // Validation Agent
        let validation_agent = Agent {
            agent_id: "validator-001".to_string(),
            agent_type: AgentType::ValidationAgent,
            capabilities: vec![
                "contract_validation".to_string(),
                "artifact_validation".to_string(),
                "reality_grounding".to_string(),
                "specification_analysis".to_string(),
            ],
            confidence_level: 0.85,
            active: true,
        };
        
        // Simulation Agent
        let simulation_agent = Agent {
            agent_id: "simulator-001".to_string(),
            agent_type: AgentType::SimulationAgent,
            capabilities: vec![
                "reality_simulation".to_string(),
                "timeline_prediction".to_string(),
                "risk_assessment".to_string(),
                "scenario_modeling".to_string(),
            ],
            confidence_level: 0.89,
            active: true,
        };
        
        // Decision Agent
        let decision_agent = Agent {
            agent_id: "decision-001".to_string(),
            agent_type: AgentType::DecisionAgent,
            capabilities: vec![
                "strategic_decision_making".to_string(),
                "risk_balancing".to_string(),
                "option_evaluation".to_string(),
                "consensus_building".to_string(),
            ],
            confidence_level: 0.78,
            active: true,
        };
        
        self.agents.insert(validation_agent.agent_id.clone(), validation_agent);
        self.agents.insert(simulation_agent.agent_id.clone(), simulation_agent);
        self.agents.insert(decision_agent.agent_id.clone(), decision_agent);
        
        Ok(())
    }
    
    pub fn agent_count(&self) -> usize {
        self.agents.len()
    }
    
    pub async fn coordinate_execution(&mut self, execution_result: &ExecutionResult) -> Result<CoordinationResult> {
        let coordination_id = Uuid::new_v4().to_string();
        
        println!("🤖 Starting multi-agent coordination for execution: {}", execution_result.execution_id);
        
        // Step 1: Identify required capabilities
        let required_capabilities = self.identify_required_capabilities(execution_result);
        
        // Step 2: Select participating agents
        let participating_agents = self.select_agents_by_capabilities(&required_capabilities);
        
        if participating_agents.is_empty() {
            return Ok(CoordinationResult {
                coordination_id,
                participating_agents: Vec::new(),
                consensus_achieved: false,
                options: vec!["No suitable agents available".to_string()],
                recommended_action: None,
                confidence: 0.0,
            });
        }
        
        println!("  Selected {} agents: {:?}", participating_agents.len(), participating_agents);
        
        // Step 3: Coordinate agent responses
        let mut agent_recommendations = Vec::new();
        
        for agent_id in &participating_agents {
            if let Some(agent) = self.agents.get(agent_id) {
                let recommendation = self.get_agent_recommendation(agent, execution_result).await?;
                agent_recommendations.push(recommendation);
                self.statistics.messages_exchanged += 1;
            }
        }
        
        // Step 4: Attempt to reach consensus
        let consensus_result = self.attempt_consensus(&agent_recommendations);
        
        let coordination_result = CoordinationResult {
            coordination_id,
            participating_agents,
            consensus_achieved: consensus_result.achieved,
            options: agent_recommendations,
            recommended_action: consensus_result.recommendation,
            confidence: consensus_result.confidence,
        };
        
        // Update statistics
        self.statistics.collaborative_decisions += 1;
        if consensus_result.achieved {
            self.statistics.consensus_success_rate = 
                (self.statistics.consensus_success_rate * (self.statistics.collaborative_decisions - 1) as f64 + 1.0) / 
                self.statistics.collaborative_decisions as f64;
        }
        
        self.coordination_history.push(coordination_result.clone());
        
        Ok(coordination_result)
    }
    
    pub async fn apply_user_decision(&mut self, decision: &str) -> Result<()> {
        println!("👤 Applying user decision: {}", decision);
        
        // Update agent states based on user decision
        for agent in self.agents.values_mut() {
            // Adjust agent confidence based on alignment with user decision
            if decision.to_lowercase().contains("validation") && matches!(agent.agent_type, AgentType::ValidationAgent) {
                agent.confidence_level = (agent.confidence_level + 0.1).min(1.0);
            } else if decision.to_lowercase().contains("simulation") && matches!(agent.agent_type, AgentType::SimulationAgent) {
                agent.confidence_level = (agent.confidence_level + 0.1).min(1.0);
            } else if decision.to_lowercase().contains("decision") && matches!(agent.agent_type, AgentType::DecisionAgent) {
                agent.confidence_level = (agent.confidence_level + 0.1).min(1.0);
            }
        }
        
        Ok(())
    }
    
    pub fn get_statistics(&self) -> CoordinationStatistics {
        self.statistics.clone()
    }
    
    // Helper methods
    
    fn identify_required_capabilities(&self, execution_result: &ExecutionResult) -> Vec<String> {
        let mut capabilities = Vec::new();
        
        // Analyze execution result to determine needed capabilities
        if !execution_result.success || execution_result.confidence_level < 0.7 {
            capabilities.push("validation".to_string());
        }
        
        if execution_result.requires_multi_agent_coordination {
            capabilities.push("coordination".to_string());
            capabilities.push("decision_making".to_string());
        }
        
        if execution_result.artifacts_created.is_empty() {
            capabilities.push("execution".to_string());
        }
        
        // Always include simulation for complex scenarios
        if execution_result.steps_completed.len() > 3 {
            capabilities.push("simulation".to_string());
        }
        
        capabilities
    }
    
    fn select_agents_by_capabilities(&self, required_capabilities: &[String]) -> Vec<String> {
        let mut selected_agents = Vec::new();
        
        for (agent_id, agent) in &self.agents {
            if !agent.active {
                continue;
            }
            
            // Check if agent has any of the required capabilities
            let has_required_capability = required_capabilities.iter().any(|req_cap| {
                agent.capabilities.iter().any(|agent_cap| {
                    agent_cap.contains(req_cap) || req_cap.contains(agent_cap)
                })
            });
            
            if has_required_capability {
                selected_agents.push(agent_id.clone());
            }
        }
        
        selected_agents
    }
    
    async fn get_agent_recommendation(&self, agent: &Agent, execution_result: &ExecutionResult) -> Result<String> {
        // Simulate agent-specific recommendations based on agent type and capabilities
        let recommendation = match agent.agent_type {
            AgentType::ValidationAgent => {
                if execution_result.success {
                    "Execution appears successful, recommend proceeding with validation checks".to_string()
                } else {
                    "Execution failed, recommend thorough validation and error analysis".to_string()
                }
            },
            AgentType::SimulationAgent => {
                if execution_result.confidence_level < 0.6 {
                    "Low confidence detected, recommend scenario simulation before proceeding".to_string()
                } else {
                    "Confidence acceptable, simulation suggests proceeding with monitoring".to_string()
                }
            },
            AgentType::DecisionAgent => {
                if execution_result.requires_user_input {
                    "User input required, recommend structured decision framework".to_string()
                } else {
                    "Recommend autonomous execution with periodic checkpoints".to_string()
                }
            },
            AgentType::ExecutionAgent => {
                "Ready to execute next phase of plan with current parameters".to_string()
            },
        };
        
        Ok(recommendation)
    }
    
    fn attempt_consensus(&self, recommendations: &[String]) -> ConsensusResult {
        // Intelligent consensus mechanism that tries to resolve conflicts automatically
        let total_recommendations = recommendations.len();
        
        if total_recommendations == 0 {
            return ConsensusResult {
                achieved: false,
                recommendation: None,
                confidence: 0.0,
            };
        }
        
        // Analyze recommendation types
        let proceed_count = recommendations.iter()
            .filter(|r| r.to_lowercase().contains("proceed") || r.to_lowercase().contains("continue") || r.to_lowercase().contains("autonomous"))
            .count();
        
        let validate_count = recommendations.iter()
            .filter(|r| r.to_lowercase().contains("validation") || r.to_lowercase().contains("check") || r.to_lowercase().contains("failed"))
            .count();
        
        let simulate_count = recommendations.iter()
            .filter(|r| r.to_lowercase().contains("simulation") || r.to_lowercase().contains("model") || r.to_lowercase().contains("confidence"))
            .count();
        
        let user_input_count = recommendations.iter()
            .filter(|r| r.to_lowercase().contains("user input") || r.to_lowercase().contains("structured decision"))
            .count();
        
        // Intelligent conflict resolution
        let max_count = proceed_count.max(validate_count).max(simulate_count).max(user_input_count);
        let consensus_score = max_count as f64 / total_recommendations as f64;
        
        // Try to achieve consensus automatically for most cases
        let achieved = if consensus_score >= 0.6 {
            true // Clear majority
        } else if proceed_count > 0 && validate_count == 0 && simulate_count == 0 {
            true // No conflicts, can proceed
        } else if validate_count > 0 && total_recommendations <= 2 {
            true // Simple validation needed
        } else {
            false // True conflict requiring user input
        };
        
        let recommendation = if achieved {
            if proceed_count == max_count || (proceed_count > 0 && validate_count == 0 && simulate_count == 0) {
                Some("Agents reached consensus: Continue with autonomous execution".to_string())
            } else if validate_count == max_count {
                Some("Agents reached consensus: Perform additional validation before proceeding".to_string())
            } else if simulate_count == max_count {
                Some("Agents reached consensus: Run scenario simulation to reduce uncertainty".to_string())
            } else if user_input_count == max_count {
                None // This will escalate to user
            } else {
                Some("Agents reached consensus: Proceed with enhanced monitoring".to_string())
            }
        } else {
            None // No consensus, escalate to user
        };
        
        ConsensusResult {
            achieved,
            recommendation,
            confidence: consensus_score,
        }
    }
}

#[derive(Debug)]
struct ConsensusResult {
    achieved: bool,
    recommendation: Option<String>,
    confidence: f64,
}