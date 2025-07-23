use anyhow::Result;
use smars_agent::server::{AgentDiscoveryClient, AgentHost, SmarsAgentClient};

#[tokio::main]
async fn main() -> Result<()> {
    env_logger::init();
    
    println!("SMARS Agent Discovery Tool");
    println!("==========================");
    
    // Define agent hosts to discover
    let agent_hosts = vec![
        AgentHost {
            address: "127.0.0.1".to_string(),
            port: 8080,
        },
        AgentHost {
            address: "127.0.0.1".to_string(),
            port: 8081,
        },
        AgentHost {
            address: "127.0.0.1".to_string(),
            port: 8082,
        },
    ];
    
    let discovery_client = AgentDiscoveryClient::new();
    
    println!("Discovering agents on {} hosts...", agent_hosts.len());
    
    // Discover all available agents
    let discovery_result = discovery_client.discover_agents(agent_hosts).await?;
    
    println!("\nDiscovery Results:");
    println!("================");
    
    // Display discovered agents
    if !discovery_result.discovered_agents.is_empty() {
        println!("✅ Discovered {} agent(s):", discovery_result.discovered_agents.len());
        
        for agent in &discovery_result.discovered_agents {
            println!("\n📍 Agent: {}", agent.agent_id);
            println!("   Status: {}", agent.health_status);
            println!("   Host: {}", agent.capabilities.host_address);
            println!("   Version: {}", agent.capabilities.version);
            println!("   Runtime: {} on {}", 
                agent.capabilities.runtime_info.runtime_type,
                agent.capabilities.runtime_info.platform
            );
            println!("   Uptime: {}s", agent.capabilities.runtime_info.uptime_seconds);
            println!("   Memory: {}MB", agent.capabilities.runtime_info.memory_usage_mb);
            
            println!("   Capabilities:");
            for capability in &agent.capabilities.capabilities {
                println!("     • {}", capability);
            }
            
            println!("   Agent Status:");
            println!("     Ready: {}", agent.capabilities.status.ready);
            println!("     Busy: {}", agent.capabilities.status.busy);
            println!("     Errors: {}", agent.capabilities.status.error_count);
            if let Some(error) = &agent.capabilities.status.last_error {
                println!("     Last Error: {}", error);
            }
        }
    } else {
        println!("❌ No agents discovered");
    }
    
    // Display unreachable hosts
    if !discovery_result.unreachable_hosts.is_empty() {
        println!("\n🔴 Unreachable hosts ({}):", discovery_result.unreachable_hosts.len());
        for host in &discovery_result.unreachable_hosts {
            println!("   • {}", host);
        }
    }
    
    // Demonstrate capability filtering
    if !discovery_result.discovered_agents.is_empty() {
        println!("\n🔍 Capability Filtering Examples:");
        println!("================================");
        
        // Filter for agents with LLM completion
        let llm_agents = discovery_client.filter_capable_agents(
            discovery_result.discovered_agents.clone(), 
            vec!["llm_completion".to_string()]
        );
        
        println!("Agents with LLM completion: {}", llm_agents.len());
        for agent in &llm_agents {
            println!("  • {}", agent.agent_id);
        }
        
        // Filter for agents with plan execution
        let plan_agents = discovery_client.filter_capable_agents(
            discovery_result.discovered_agents.clone(), 
            vec!["plan_execution".to_string()]
        );
        
        println!("Agents with plan execution: {}", plan_agents.len());
        for agent in &plan_agents {
            println!("  • {}", agent.agent_id);
        }
        
        // Filter for agents with both trace logging and RPC server
        let full_agents = discovery_client.filter_capable_agents(
            discovery_result.discovered_agents.clone(), 
            vec!["trace_logging".to_string(), "rpc_server".to_string()]
        );
        
        println!("Agents with trace_logging + rpc_server: {}", full_agents.len());
        for agent in &full_agents {
            println!("  • {}", agent.agent_id);
        }
        
        // Demonstrate multi-agent orchestration readiness
        if !full_agents.is_empty() {
            println!("\n🚀 Multi-Agent Orchestration Ready!");
            println!("Available for orchestrate_multi_agent plan execution:");
            
            for agent in &full_agents {
                println!("  ✅ {} - {} capabilities", 
                    agent.agent_id, 
                    agent.capabilities.capabilities.len()
                );
            }
        }
    }
    
    // Test individual agent describe functionality
    if !discovery_result.discovered_agents.is_empty() {
        println!("\n🔬 Individual Agent Testing:");
        println!("===========================");
        
        let first_agent = &discovery_result.discovered_agents[0];
        let client = SmarsAgentClient::new(&first_agent.capabilities.host_address);
        
        match client.describe_agent().await {
            Ok(describe_response) => {
                println!("✅ Direct describe_agent call successful for {}", first_agent.agent_id);
                println!("   Request ID: {}", describe_response.request_id);
            }
            Err(e) => {
                println!("❌ Direct describe_agent call failed: {}", e);
            }
        }
    }
    
    Ok(())
}