use anyhow::Result;
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use tokio::sync::Mutex;
use tokio::net::{TcpListener, TcpStream};
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use log::{info, warn, error};
use crate::executor::{SmarsExecutor, ExecutionResult};
use crate::parser::SmarsParser;
use crate::trace_logger::TraceLogger;

#[derive(Debug, Serialize, Deserialize)]
pub struct ExecutionRequest {
    pub spec_content: String,
    pub plan_name: String,
    pub foundation_models: bool,
    pub request_id: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ExecutionResponse {
    pub success: bool,
    pub request_id: String,
    pub execution_result: Option<ExecutionResult>,
    pub error_message: Option<String>,
    pub trace_log_path: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct HealthRequest {
    pub request_id: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct HealthResponse {
    pub status: String,
    pub request_id: String,
    pub agent_ready: bool,
    pub foundation_models_available: bool,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct DescribeAgentRequest {
    pub request_id: String,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct AgentCapabilities {
    pub capabilities: Vec<String>,
    pub runtime_info: RuntimeInfo,
    pub host_address: String,
    pub version: String,
    pub status: AgentStatus,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct RuntimeInfo {
    pub runtime_type: String,
    pub platform: String,
    pub memory_usage_mb: u64,
    pub uptime_seconds: u64,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct AgentStatus {
    pub ready: bool,
    pub busy: bool,
    pub error_count: u32,
    pub last_error: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct DescribeAgentResponse {
    pub request_id: String,
    pub agent_capabilities: AgentCapabilities,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct AgentHost {
    pub address: String,
    pub port: u16,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct AgentInfo {
    pub agent_id: String,
    pub capabilities: AgentCapabilities,
    pub health_status: String,
    pub last_ping: u64,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct DiscoverAgentsRequest {
    pub request_id: String,
    pub agent_hosts: Vec<AgentHost>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct DiscoverAgentsResponse {
    pub request_id: String,
    pub discovered_agents: Vec<AgentInfo>,
    pub unreachable_hosts: Vec<String>,
}

pub struct SmarsAgentServer {
    executor: Arc<Mutex<SmarsExecutor>>,
    trace_logger: Arc<Mutex<TraceLogger>>,
    foundation_models_enabled: bool,
    startup_time: std::time::Instant,
    error_count: Arc<std::sync::atomic::AtomicU32>,
    last_error: Arc<Mutex<Option<String>>>,
}

impl SmarsAgentServer {
    pub fn new(foundation_models: bool, output_dir: &str) -> Result<Self> {
        let executor = Arc::new(Mutex::new(SmarsExecutor::new(foundation_models)));
        let trace_logger = Arc::new(Mutex::new(TraceLogger::new(output_dir)?));
        
        Ok(Self {
            executor,
            trace_logger,
            foundation_models_enabled: foundation_models,
            startup_time: std::time::Instant::now(),
            error_count: Arc::new(std::sync::atomic::AtomicU32::new(0)),
            last_error: Arc::new(Mutex::new(None)),
        })
    }
    
    pub async fn start(&self, port: u16) -> Result<()> {
        let listener = TcpListener::bind(format!("127.0.0.1:{}", port)).await?;
        info!("SMARS Agent RPC Server listening on 127.0.0.1:{}", port);
        
        loop {
            match listener.accept().await {
                Ok((stream, addr)) => {
                    info!("Accepted connection from: {}", addr);
                    let executor = self.executor.clone();
                    let trace_logger = self.trace_logger.clone();
                    let foundation_models = self.foundation_models_enabled;
                    let startup_time = self.startup_time;
                    let error_count = self.error_count.clone();
                    let last_error = self.last_error.clone();
                    
                    tokio::spawn(async move {
                        if let Err(e) = Self::handle_connection(stream, executor, trace_logger, foundation_models, startup_time, error_count, last_error).await {
                            error!("Error handling connection from {}: {}", addr, e);
                        }
                    });
                }
                Err(e) => {
                    warn!("Error accepting connection: {}", e);
                }
            }
        }
    }
    
    async fn handle_connection(
        mut stream: TcpStream,
        executor: Arc<Mutex<SmarsExecutor>>,
        trace_logger: Arc<Mutex<TraceLogger>>,
        foundation_models: bool,
        startup_time: std::time::Instant,
        error_count: Arc<std::sync::atomic::AtomicU32>,
        last_error: Arc<Mutex<Option<String>>>,
    ) -> Result<()> {
        let mut buffer = vec![0; 1024 * 16]; // 16KB buffer
        let bytes_read = stream.read(&mut buffer).await?;
        
        if bytes_read == 0 {
            return Ok(());
        }
        
        let request_data = String::from_utf8_lossy(&buffer[..bytes_read]);
        
        // Try to parse as different request types
        let response = if let Ok(health_req) = serde_json::from_str::<HealthRequest>(&request_data) {
            Self::handle_health_request(health_req, foundation_models).await
        } else if let Ok(describe_req) = serde_json::from_str::<DescribeAgentRequest>(&request_data) {
            Self::handle_describe_agent_request(describe_req, foundation_models, startup_time, error_count, last_error).await
        } else if let Ok(exec_req) = serde_json::from_str::<ExecutionRequest>(&request_data) {
            Self::handle_execution_request(exec_req, executor, trace_logger).await
        } else {
            warn!("Received invalid request format");
            serde_json::to_string(&ExecutionResponse {
                success: false,
                request_id: "unknown".to_string(),
                execution_result: None,
                error_message: Some("Invalid request format".to_string()),
                trace_log_path: None,
            })?
        };
        
        stream.write_all(response.as_bytes()).await?;
        stream.flush().await?;
        
        Ok(())
    }
    
    async fn handle_health_request(request: HealthRequest, foundation_models: bool) -> String {
        let response = HealthResponse {
            status: "ok".to_string(),
            request_id: request.request_id,
            agent_ready: true,
            foundation_models_available: foundation_models,
        };
        
        serde_json::to_string(&response).unwrap_or_else(|_| "{}".to_string())
    }
    
    async fn handle_describe_agent_request(
        request: DescribeAgentRequest,
        foundation_models: bool,
        startup_time: std::time::Instant,
        error_count: Arc<std::sync::atomic::AtomicU32>,
        last_error: Arc<Mutex<Option<String>>>,
    ) -> String {
        let uptime_seconds = startup_time.elapsed().as_secs();
        let memory_usage = Self::get_memory_usage_mb();
        let current_error_count = error_count.load(std::sync::atomic::Ordering::Relaxed);
        let last_error_msg = last_error.lock().await.clone();
        
        // Define capabilities based on agent features
        let mut capabilities = vec![
            "plan_execution".to_string(),
            "trace_logging".to_string(),
            "rpc_server".to_string(),
        ];
        
        if foundation_models {
            capabilities.push("llm_completion".to_string());
        }
        
        let runtime_info = RuntimeInfo {
            runtime_type: "smars-rust".to_string(),
            platform: std::env::consts::OS.to_string(),
            memory_usage_mb: memory_usage,
            uptime_seconds,
        };
        
        let status = AgentStatus {
            ready: true,
            busy: false, // Could track active executions
            error_count: current_error_count,
            last_error: last_error_msg,
        };
        
        let agent_capabilities = AgentCapabilities {
            capabilities,
            runtime_info,
            host_address: "127.0.0.1:8080".to_string(), // Could be configurable
            version: "0.5.0".to_string(),
            status,
        };
        
        let response = DescribeAgentResponse {
            request_id: request.request_id,
            agent_capabilities,
        };
        
        serde_json::to_string(&response).unwrap_or_else(|_| "{}".to_string())
    }
    
    fn get_memory_usage_mb() -> u64 {
        // Simple memory usage estimation - could be enhanced with actual memory monitoring
        #[cfg(target_os = "macos")]
        {
            use std::process::Command;
            if let Ok(output) = Command::new("ps")
                .args(&["-o", "rss=", "-p"])
                .arg(std::process::id().to_string())
                .output()
            {
                if let Ok(rss_str) = String::from_utf8(output.stdout) {
                    if let Ok(rss_kb) = rss_str.trim().parse::<u64>() {
                        return rss_kb / 1024; // Convert KB to MB
                    }
                }
            }
        }
        
        // Fallback estimate
        64 // MB
    }
    
    async fn handle_execution_request(
        request: ExecutionRequest,
        executor: Arc<Mutex<SmarsExecutor>>,
        trace_logger: Arc<Mutex<TraceLogger>>,
    ) -> String {
        info!("Handling execution request: {}", request.request_id);
        
        // Parse SMARS specification
        let mut parser = SmarsParser::new();
        let ast = match parser.parse(&request.spec_content) {
            Ok(ast) => ast,
            Err(e) => {
                error!("Failed to parse SMARS spec: {}", e);
                return serde_json::to_string(&ExecutionResponse {
                    success: false,
                    request_id: request.request_id,
                    execution_result: None,
                    error_message: Some(format!("Parse error: {}", e)),
                    trace_log_path: None,
                }).unwrap_or_else(|_| "{}".to_string());
            }
        };
        
        // Execute plan
        let execution_result = {
            let mut executor = executor.lock().await;
            match executor.execute_plan(&request.plan_name, &ast).await {
                Ok(result) => result,
                Err(e) => {
                    error!("Plan execution failed: {}", e);
                    return serde_json::to_string(&ExecutionResponse {
                        success: false,
                        request_id: request.request_id,
                        execution_result: None,
                        error_message: Some(format!("Execution error: {}", e)),
                        trace_log_path: None,
                    }).unwrap_or_else(|_| "{}".to_string());
                }
            }
        };
        
        // Log execution trace
        let trace_log_path = {
            let trace_logger = trace_logger.lock().await;
            
            // Log cue emissions
            for cue in &execution_result.cue_emissions {
                if let Err(e) = trace_logger.log_cue_emission(cue, &request.plan_name) {
                    warn!("Failed to log cue emission: {}", e);
                }
            }
            
            // Log complete execution
            match trace_logger.log_execution(&request.plan_name, "rpc_request", execution_result.clone()) {
                Ok(_) => Some(format!("traces/execution_{}_{}.json", 
                    request.plan_name.replace(" ", "_"), 
                    request.request_id)),
                Err(e) => {
                    warn!("Failed to log execution: {}", e);
                    None
                }
            }
        };
        
        let response = ExecutionResponse {
            success: execution_result.success,
            request_id: request.request_id,
            execution_result: Some(execution_result),
            error_message: None,
            trace_log_path,
        };
        
        serde_json::to_string(&response).unwrap_or_else(|_| "{}".to_string())
    }
}

// Client helper for testing
#[allow(dead_code)] // planned for agent-to-agent communication in v0.2
pub struct SmarsAgentClient {
    address: String,
}

#[allow(dead_code)] // planned for agent-to-agent communication in v0.2
impl SmarsAgentClient {
    pub fn new(address: &str) -> Self {
        Self {
            address: address.to_string(),
        }
    }
    
    pub async fn health_check(&self) -> Result<HealthResponse> {
        let request = HealthRequest {
            request_id: uuid::Uuid::new_v4().to_string(),
        };
        
        let response = self.send_request(&serde_json::to_string(&request)?).await?;
        Ok(serde_json::from_str(&response)?)
    }
    
    pub async fn describe_agent(&self) -> Result<DescribeAgentResponse> {
        let request = DescribeAgentRequest {
            request_id: uuid::Uuid::new_v4().to_string(),
        };
        
        let response = self.send_request(&serde_json::to_string(&request)?).await?;
        Ok(serde_json::from_str(&response)?)
    }
    
    pub async fn execute_plan(
        &self,
        spec_content: &str,
        plan_name: &str,
        foundation_models: bool,
    ) -> Result<ExecutionResponse> {
        let request = ExecutionRequest {
            spec_content: spec_content.to_string(),
            plan_name: plan_name.to_string(),
            foundation_models,
            request_id: uuid::Uuid::new_v4().to_string(),
        };
        
        let response = self.send_request(&serde_json::to_string(&request)?).await?;
        Ok(serde_json::from_str(&response)?)
    }
    
    async fn send_request(&self, request_data: &str) -> Result<String> {
        let mut stream = TcpStream::connect(&self.address).await?;
        
        stream.write_all(request_data.as_bytes()).await?;
        stream.flush().await?;
        
        let mut buffer = vec![0; 1024 * 64]; // 64KB buffer for responses
        let bytes_read = stream.read(&mut buffer).await?;
        
        Ok(String::from_utf8_lossy(&buffer[..bytes_read]).to_string())
    }
}

// Agent Discovery Client for implementing discover_agents functionality
#[allow(dead_code)] // planned for distributed agent discovery in v0.3
pub struct AgentDiscoveryClient;

#[allow(dead_code)] // planned for distributed agent discovery in v0.3
impl AgentDiscoveryClient {
    pub fn new() -> Self {
        Self
    }
    
    pub async fn discover_agents(&self, agent_hosts: Vec<AgentHost>) -> Result<DiscoverAgentsResponse> {
        let request_id = uuid::Uuid::new_v4().to_string();
        let mut discovered_agents = Vec::new();
        let mut unreachable_hosts = Vec::new();
        
        // Attempt to connect to each agent host
        for host in agent_hosts {
            let host_address = format!("{}:{}", host.address, host.port);
            
            match self.probe_agent(&host_address).await {
                Ok(agent_info) => {
                    discovered_agents.push(agent_info);
                    info!("Successfully discovered agent at {}", host_address);
                }
                Err(e) => {
                    warn!("Failed to reach agent at {}: {}", host_address, e);
                    unreachable_hosts.push(host_address);
                }
            }
        }
        
        Ok(DiscoverAgentsResponse {
            request_id,
            discovered_agents,
            unreachable_hosts,
        })
    }
    
    async fn probe_agent(&self, host_address: &str) -> Result<AgentInfo> {
        let client = SmarsAgentClient::new(host_address);
        
        // First, check health
        let health = client.health_check().await?;
        
        // Then get capabilities
        let describe_response = client.describe_agent().await?;
        
        let agent_info = AgentInfo {
            agent_id: format!("agent-{}", host_address),
            capabilities: describe_response.agent_capabilities,
            health_status: health.status,
            last_ping: std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap_or_default()
                .as_secs(),
        };
        
        Ok(agent_info)
    }
    
    pub fn filter_capable_agents(&self, agents: Vec<AgentInfo>, required_capabilities: Vec<String>) -> Vec<AgentInfo> {
        agents.into_iter()
            .filter(|agent| {
                // Check if agent has all required capabilities
                required_capabilities.iter().all(|required_cap| {
                    agent.capabilities.capabilities.contains(required_cap)
                })
            })
            .collect()
    }
    
    pub async fn delegate_plan_to_agent(&self, agent: &AgentInfo, plan_name: &str, spec_content: &str) -> Result<ExecutionResult> {
        let host_address = &agent.capabilities.host_address;
        let client = SmarsAgentClient::new(host_address);
        
        let response = client.execute_plan(spec_content, plan_name, agent.capabilities.capabilities.contains(&"llm_completion".to_string())).await?;
        
        match response.execution_result {
            Some(result) => Ok(result),
            None => Err(anyhow::anyhow!("Plan execution failed: {:?}", response.error_message))
        }
    }
}