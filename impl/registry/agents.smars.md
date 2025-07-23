# Agent Promotion Registry

@role(nucleus)

Self-describing symbolic registry of promoted agents - fully parsable and queryable via SMARS.

## Registry Types

### Domain Classification
```
(∷ Domain {
  primary: STRING,
  secondary: STRING
})
```

### Agent Capabilities
```
(∷ AgentCapabilities {
  decision_making: BOOLEAN,
  learning: BOOLEAN,
  communication: BOOLEAN,
  memory_management: BOOLEAN,
  validation_requesting: BOOLEAN,
  shell_execution: BOOLEAN,
  llm_completion: BOOLEAN,
  plan_execution: BOOLEAN,
  trace_logging: BOOLEAN,
  rpc_server: BOOLEAN
})
```

### Capability Constants
```
(• ⟦shell_execution⟧ ∷ Capability = "shell_execution")
(• ⟦llm_completion⟧ ∷ Capability = "llm_completion") 
(• ⟦plan_execution⟧ ∷ Capability = "plan_execution")
(• ⟦trace_logging⟧ ∷ Capability = "trace_logging")
(• ⟦rpc_server⟧ ∷ Capability = "rpc_server")
(• ⟦decision_making⟧ ∷ Capability = "decision_making")
(• ⟦learning⟧ ∷ Capability = "learning")
(• ⟦communication⟧ ∷ Capability = "communication")
(• ⟦memory_management⟧ ∷ Capability = "memory_management")
(• ⟦validation_requesting⟧ ∷ Capability = "validation_requesting")
```

### Agent Type Definitions
```
(kind agent_capabilities ∷ {
  capabilities: [Capability],
  runtime_info: RuntimeInfo,
  host_address: STRING,
  version: STRING,
  status: AgentStatus
})

(kind agent_info ∷ {
  agent_id: STRING,
  capabilities: agent_capabilities,
  health_status: STRING,
  last_ping: INT
})

(∷ RuntimeInfo {
  runtime_type: STRING,
  platform: STRING,
  memory_usage_mb: INT,
  uptime_seconds: INT
})

(∷ AgentStatus {
  ready: BOOLEAN,
  busy: BOOLEAN,
  error_count: INT,
  last_error: STRING
})
```

### Promoted Agent Record
```
(∷ PromotedAgentRecord {
  uuid: STRING,
  agent_name: STRING,
  source_file: STRING,
  source_line: INT,
  promoted_timestamp: INT,
  artifact_path: STRING,
  artifact_hash: STRING,
  promotion_score: FLOAT,
  domain_classification: Domain,
  validation_status: STRING,
  original_agent_definition: STRING,
  capabilities: AgentCapabilities,
  provenance: AgentProvenance,
  tags: [STRING],
  related_agents: [STRING],
  memory_requirements: [STRING]
})

(∷ AgentProvenance {
  source_author: STRING,
  source_session: STRING
})

(∷ AgentRegistryMetadata {
  registry_version: STRING,
  last_updated: INT,
  last_modified_by: STRING,
  last_modified_at: INT,
  total_promoted_agents: INT,
  registry_hash: STRING,
  capability_distribution: {STRING: INT}
})
```

## Registry Data

### Registry Metadata
```
(• ⟦registry_metadata⟧ ∷ AgentRegistryMetadata = {
  registry_version: "1.0.0",
  last_updated: 1721594700,
  last_modified_by: "system",
  last_modified_at: 1721594700,
  total_promoted_agents: 0,
  registry_hash: "sha256:pending",
  capability_distribution: {}
})
```

### Promoted Agent Records
```
(• ⟦promoted_agents⟧ ∷ [PromotedAgentRecord] = [
  // Records will be appended here by agent promotion process
])
```

## Registry Operations

### Lookup Functions
```
(ƒ lookup_agent_by_uuid ∷ STRING → PromotedAgentRecord)
(ƒ lookup_agents_by_domain ∷ Domain → [PromotedAgentRecord])
(ƒ lookup_agents_by_capabilities ∷ AgentCapabilities → [PromotedAgentRecord])
(ƒ lookup_agents_by_tags ∷ [STRING] → [PromotedAgentRecord])
(ƒ lookup_related_agents ∷ STRING → [PromotedAgentRecord])
```

### Agent Discovery Functions
```
(ƒ discover_agents ∷ [AgentHost] → [agent_info])
(ƒ describe_agent ∷ AgentHost → agent_capabilities)
(ƒ filter_capable_agents ∷ [agent_info] × [Capability] → [agent_info])
(ƒ delegate_plan_to_agent ∷ agent_info × PlanName → ExecutionResult)
```

### Multi-Agent Orchestration Plans
```
(§ orchestrate_multi_agent
  steps:
    - apply discover_agents ▸ agent_host_list
    - apply filter_capable_agents ▸ discovered_agents ▸ required_capabilities  
    - apply delegate_plan_to_agent ▸ selected_agent ▸ target_plan
)

(§ agent_capability_audit
  steps:
    - apply discover_agents ▸ all_known_hosts
    - apply describe_agent ▸ each_discovered_agent
    - apply validate_agent_capabilities ▸ capability_reports
)
```

## Registry Contracts

### Registry Population Contract
```
(⊨ agent_registry_minimum_population
  requires: total_promoted_agents ≥ 1
  ensures: nonempty_agent_registry
)
```

### Agent Capability Requirements
```
(⊨ agent_must_declare_capabilities
  requires: capability_set_present ∧ capabilities.length ≥ 1
  ensures: agent_is_discoverable ∧ orchestration_ready
)

(⊨ agent_health_check_responsive
  requires: agent_status.ready = true
  ensures: agent_can_execute_plans
)

(⊨ capability_validation_contract
  requires: declared_capabilities ⊆ supported_capabilities
  ensures: no_capability_mismatch_errors
)
```