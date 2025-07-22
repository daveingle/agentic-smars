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
  validation_requesting: BOOLEAN
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

## Registry Contracts

### Registry Population Contract
```
(⊨ agent_registry_minimum_population
  requires: total_promoted_agents ≥ 1
  ensures: nonempty_agent_registry
)
```