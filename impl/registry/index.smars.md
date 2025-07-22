# Registry Index

@role(nucleus)

Central registry digest providing CLI and system summaries across all promotion registries.

## Registry Digest Types

### Registry Summary
```
(∷ RegistryDigest {
  total_cues: INT,
  total_kinds: INT,
  total_agents: INT,
  total_plans: INT,
  domains: [STRING],
  top_tags: [STRING],
  hash: STRING
})

(∷ RegistryHealth {
  cues_status: STRING,
  kinds_status: STRING,
  agents_status: STRING,
  plans_status: STRING,
  overall_health: STRING,
  last_check: INT
})
```

## Current Registry State

### Registry Digest
```
(• ⟦registry_digest⟧ ∷ RegistryDigest = {
  total_cues: 0,
  total_kinds: 0,
  total_agents: 0,
  total_plans: 0,
  domains: [],
  top_tags: [],
  hash: "sha256:pending"
})
```

### Registry Health Status
```
(• ⟦registry_health⟧ ∷ RegistryHealth = {
  cues_status: "empty",
  kinds_status: "empty", 
  agents_status: "not_implemented",
  plans_status: "not_implemented",
  overall_health: "bootstrapping",
  last_check: 1721594700
})
```

## Registry Management Functions

### Digest Computation
```
(ƒ compute_registry_digest ∷ [RegistryFile] → RegistryDigest)
(ƒ update_registry_health ∷ [RegistryStatus] → RegistryHealth)
(ƒ validate_registry_integrity ∷ RegistryDigest → BOOLEAN)
```

### Cross-Registry Queries
```
(ƒ search_all_registries ∷ SearchCriteria → [SearchResult])
(ƒ find_cross_references ∷ UUID → [CrossReference])
(ƒ analyze_tag_distribution ∷ [RegistryFile] → TagAnalysis)
```

## Registry Update Plans

### Update Registry Digest
```
(§ update_registry_digest
  steps:
    - scan_all_registry_files
    - compute_individual_summaries
    - aggregate_cross_registry_statistics
    - update_digest_data
    - compute_digest_hash
)
```

### Registry Health Check
```
(§ registry_health_check
  steps:
    - validate_all_registry_files
    - check_cross_reference_integrity
    - verify_hash_consistency
    - update_health_status
    - report_health_issues
)
```

## Registry Contracts

### Digest Consistency Contract
```
(⊨ digest_consistency_contract
  requires: accessible_registry_files(files)
  ensures: digest_reflects_current_state(digest)
  ensures: cross_references_valid(cross_refs)
)
```

This registry index enables:
- **CLI Summaries**: Quick overview of all promotion activity
- **System Health**: Monitor registry integrity across all types
- **Cross-Registry Queries**: Search across cues, kinds, agents, plans
- **Tag Analysis**: Understand system evolution patterns