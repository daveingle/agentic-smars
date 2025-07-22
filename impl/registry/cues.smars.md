# Cue Promotion Registry

@role(nucleus)

Self-describing symbolic registry of promoted cues - fully parsable and queryable via SMARS.

## Registry Types

### Domain Classification
```
(∷ Domain {
  primary: STRING,
  secondary: STRING
})
```

### Promoted Cue Record
```
(∷ PromotedCueRecord {
  uuid: STRING,
  source_file: STRING,
  source_line: INT,
  promoted_timestamp: INT,
  artifact_path: STRING,
  artifact_hash: STRING,
  promotion_score: FLOAT,
  domain_classification: Domain,
  validation_status: STRING,
  original_cue_content: STRING,
  provenance: CueProvenance,
  tags: [STRING],
  related_cues: [STRING]
})

(∷ CueProvenance {
  source_author: STRING,
  source_session: STRING
})

(∷ PromotionTrace {
  detection_method: STRING,
  assessment_scores: AssessmentCriteria,
  verification_result: STRING,
  integration_result: STRING
})

(∷ CueRegistryMetadata {
  registry_version: STRING,
  last_updated: INT,
  last_modified_by: STRING,
  last_modified_at: INT,
  total_promoted_cues: INT,
  registry_hash: STRING
})
```

## Registry Data

### Registry Metadata
```
(• ⟦registry_metadata⟧ ∷ CueRegistryMetadata = {
  registry_version: "1.0.0",
  last_updated: 1721594700,
  total_promoted_cues: 0,
  registry_hash: "sha256:pending"
})
```

### Promoted Cue Records
```
(• ⟦promoted_cues⟧ ∷ [PromotedCueRecord] = [
  // Records will be appended here by promotion process
])
```

## Registry Operations

### Lookup Functions
```
(ƒ lookup_by_uuid ∷ STRING → PromotedCueRecord)
(ƒ lookup_by_domain ∷ Domain → [PromotedCueRecord])
(ƒ lookup_by_source ∷ STRING → [PromotedCueRecord])
(ƒ lookup_by_tags ∷ [STRING] → [PromotedCueRecord])
(ƒ lookup_related_cues ∷ STRING → [PromotedCueRecord])
(ƒ verify_artifact_integrity ∷ STRING → BOOLEAN)
```

### Registry Validation
```
(ƒ validate_uuid_uniqueness ∷ [PromotedCueRecord] → BOOLEAN)
(ƒ validate_artifact_links ∷ [PromotedCueRecord] → BOOLEAN)
(ƒ validate_registry_consistency ∷ CueRegistryMetadata → [PromotedCueRecord] → BOOLEAN)
```

### Registry Management
```
(ƒ append_promoted_cue ∷ PromotedCueRecord → [PromotedCueRecord] → [PromotedCueRecord])
(ƒ update_registry_metadata ∷ CueRegistryMetadata → [PromotedCueRecord] → CueRegistryMetadata)
(ƒ compute_registry_hash ∷ [PromotedCueRecord] → STRING)
```

## Registry Hash Management

### Regenerate Registry Hash Plan
```
(§ regenerate_registry_hash
  steps:
    - serialize_promoted_cues
    - compute_content_hash
    - update_registry_metadata
    - verify_hash_integrity
)
```

## Registry Contracts

### UUID Uniqueness Contract
```
(⊨ uuid_uniqueness_contract
  requires: valid_promoted_cue_records(records)
  ensures: unique_uuids_in_registry(records)
)
```

### Artifact Integrity Contract
```
(⊨ artifact_integrity_contract
  requires: promoted_cue_with_artifact(record)
  ensures: artifact_hash_matches_content(record.artifact_hash, record.artifact_path)
)
```

### Registry Consistency Contract
```
(⊨ registry_consistency_contract
  requires: valid_registry_state(metadata, records)
  ensures: metadata_matches_records(metadata, records)
  ensures: all_artifacts_accessible(records)
)
```

### Registry Hash Contract
```
(⊨ registry_hash_contract
  requires: promoted_cue_records_modified(records)
  ensures: registry_hash_updated(metadata.registry_hash)
)
```

### Registry Population Contract
```
(⊨ cue_registry_minimum_population
  requires: total_promoted_cues ≥ 1
  ensures: nonempty_registry
)
```

## Registry Update Plans

### Promote Cue Plan
```
(§ promote_cue
  steps:
    - generate_spec_from_cue
    - validate_artifact_integrity
    - append_to_registry
    - regenerate_registry_hash
    - verify_registry_consistency
)
```

### Registry Maintenance Plan
```
(§ maintain_registry
  steps:
    - validate_all_uuid_uniqueness
    - verify_all_artifact_integrity
    - regenerate_registry_hash
    - check_registry_consistency
    - repair_inconsistencies
)
```

### Registry Query Plan
```
(§ query_registry
  steps:
    - parse_query_criteria
    - apply_lookup_functions
    - filter_matching_records
    - return_query_results
)
```

## Example Promoted Cue (Template)

### Example Record
```
(• ⟦example_promoted_cue⟧ ∷ PromotedCueRecord = {
  uuid: "cue-12345678-1234-5678-9abc-123456789abc",
  source_file: "spec/automation/example.smars.md",
  source_line: 42,
  promoted_timestamp: 1721594700,
  artifact_path: "spec/automation/promoted-validation-enhancement.smars.md",
  artifact_hash: "sha256:abc123def456...",
  promotion_score: 0.85,
  domain_classification: {primary: "automation", secondary: "validation"},
  validation_status: "validated",
  original_cue_content: "(cue validation_enhancement ⊨ suggests: \"improve validation mechanisms\")",
  provenance: {source_author: "system", source_session: "2025-07-21-promotion-cycle"},
  tags: ["validation", "enhancement", "reliability"],
  related_cues: ["cue-87654321-4321-8765-dcba-987654321fed", "cue-abcdef12-3456-7890-abcd-ef1234567890"]
})
```

### Example Promotion Trace
```
(• ⟦example_promotion_trace⟧ ∷ PromotionTrace = {
  detection_method: "semantic_analysis_scanner",
  assessment_scores: {
    technical_feasibility: 0.9,
    system_alignment: 0.8,
    implementation_complexity: 0.7,
    value_proposition: 0.9
  },
  verification_result: "artifact_created_successfully",
  integration_result: "specification_parsed_and_validated"
})
```

## Registry Evolution

This symbolic registry enables:
- **Symbolic Queries**: `(apply lookup_by_domain ▸ {primary: "automation", secondary: "validation"})`
- **Tag-Based Clustering**: `(apply lookup_by_tags ▸ ["validation", "enhancement"])`
- **Cross-Reference Navigation**: `(apply lookup_related_cues ▸ "cue-uuid")`
- **Validation Enforcement**: `(⊨ uniqueness(UUID))` contracts
- **Programmatic Updates**: Registry changes via symbolic plans
- **Agent Integration**: Registry becomes queryable data source for agents
- **Self-Validation**: Registry validates its own consistency via contracts
- **Explicit Hash Management**: `(§ regenerate_registry_hash)` ensures integrity after modifications
- **Provenance Tracking**: Full lineage with `last_modified_by` and `last_modified_at` timestamping
- **Bootstrap Protection**: `(⊨ cue_registry_minimum_population)` prevents empty registry issues

The registry is now a first-class SMARS specification that can be processed by the same symbolic interpreters used throughout the system.