# Kind Promotion Registry

@role(nucleus)

Self-describing symbolic registry of promoted kinds - fully parsable and queryable via SMARS.

## Registry Types

### Domain Classification
```
(∷ Domain {
  primary: STRING,
  secondary: STRING
})
```

### Kind Complexity Metrics
```
(∷ KindComplexity {
  field_count: INT,
  nesting_depth: INT,
  dependency_count: INT,
  reusability_score: FLOAT
})
```

### Promoted Kind Record
```
(∷ PromotedKindRecord {
  uuid: STRING,
  kind_name: STRING,
  source_file: STRING,
  source_line: INT,
  promoted_timestamp: INT,
  artifact_path: STRING,
  artifact_hash: STRING,
  promotion_score: FLOAT,
  domain_classification: Domain,
  validation_status: STRING,
  original_kind_definition: STRING,
  complexity_metrics: KindComplexity,
  provenance: KindProvenance,
  tags: [STRING],
  related_kinds: [STRING],
  dependent_kinds: [STRING]
})

(∷ KindProvenance {
  source_author: STRING,
  source_session: STRING
})

(∷ KindPromotionTrace {
  detection_method: STRING,
  complexity_assessment: KindComplexity,
  domain_classification_confidence: FLOAT,
  duplication_check_result: STRING,
  placement_decision: STRING,
  verification_result: STRING,
  integration_result: STRING
})

(∷ KindRegistryMetadata {
  registry_version: STRING,
  last_updated: INT,
  last_modified_by: STRING,
  last_modified_at: INT,
  total_promoted_kinds: INT,
  registry_hash: STRING,
  domain_distribution: {Domain: INT}
})
```

## Registry Data

### Registry Metadata
```
(• ⟦registry_metadata⟧ ∷ KindRegistryMetadata = {
  registry_version: "1.0.0",
  last_updated: 1721594700,
  last_modified_by: "system",
  last_modified_at: 1721594700,
  total_promoted_kinds: 0,
  registry_hash: "sha256:pending",
  domain_distribution: {}
})
```

### Promoted Kind Records
```
(• ⟦promoted_kinds⟧ ∷ [PromotedKindRecord] = [
  // Records will be appended here by kind promotion process
])
```

## Registry Operations

### Lookup Functions
```
(ƒ lookup_kind_by_uuid ∷ STRING → PromotedKindRecord)
(ƒ lookup_kinds_by_domain ∷ Domain → [PromotedKindRecord])
(ƒ lookup_kinds_by_source ∷ STRING → [PromotedKindRecord])
(ƒ lookup_kinds_by_tags ∷ [STRING] → [PromotedKindRecord])
(ƒ lookup_related_kinds ∷ STRING → [PromotedKindRecord])
(ƒ lookup_dependent_kinds ∷ STRING → [PromotedKindRecord])
(ƒ lookup_kinds_by_complexity ∷ ComplexityRange → [PromotedKindRecord])
(ƒ verify_kind_artifact_integrity ∷ STRING → BOOLEAN)
```

### Dependency Analysis
```
(ƒ analyze_kind_dependencies ∷ PromotedKindRecord → [KindDependency])
(ƒ detect_circular_dependencies ∷ [PromotedKindRecord] → [CircularDependency])
(ƒ compute_dependency_graph ∷ [PromotedKindRecord] → DependencyGraph)
```

### Registry Validation
```
(ƒ validate_kind_uuid_uniqueness ∷ [PromotedKindRecord] → BOOLEAN)
(ƒ validate_kind_name_uniqueness ∷ [PromotedKindRecord] → BOOLEAN)
(ƒ validate_kind_artifact_links ∷ [PromotedKindRecord] → BOOLEAN)
(ƒ validate_kind_registry_consistency ∷ KindRegistryMetadata → [PromotedKindRecord] → BOOLEAN)
(ƒ validate_domain_distribution ∷ KindRegistryMetadata → [PromotedKindRecord] → BOOLEAN)
```

### Registry Management
```
(ƒ append_promoted_kind ∷ PromotedKindRecord → [PromotedKindRecord] → [PromotedKindRecord])
(ƒ update_kind_registry_metadata ∷ KindRegistryMetadata → [PromotedKindRecord] → KindRegistryMetadata)
(ƒ compute_kind_registry_hash ∷ [PromotedKindRecord] → STRING)
(ƒ update_domain_distribution ∷ [PromotedKindRecord] → {Domain: INT})
```

## Registry Hash Management

### Regenerate Kind Registry Hash Plan
```
(§ regenerate_kind_registry_hash
  steps:
    - serialize_promoted_kinds
    - compute_content_hash
    - update_registry_metadata
    - verify_hash_integrity
)
```

## Registry Contracts

### UUID Uniqueness Contract
```
(⊨ kind_uuid_uniqueness_contract
  requires: valid_promoted_kind_records(records)
  ensures: unique_uuids_in_kind_registry(records)
)
```

### Kind Name Uniqueness Contract
```
(⊨ kind_name_uniqueness_contract
  requires: valid_promoted_kind_records(records)
  ensures: unique_kind_names_per_domain(records)
)
```

### Artifact Integrity Contract
```
(⊨ kind_artifact_integrity_contract
  requires: promoted_kind_with_artifact(record)
  ensures: artifact_hash_matches_content(record.artifact_hash, record.artifact_path)
)
```

### Registry Consistency Contract
```
(⊨ kind_registry_consistency_contract
  requires: valid_kind_registry_state(metadata, records)
  ensures: metadata_matches_kind_records(metadata, records)
  ensures: all_kind_artifacts_accessible(records)
  ensures: domain_distribution_accurate(metadata.domain_distribution, records)
)
```

### Dependency Integrity Contract
```
(⊨ kind_dependency_integrity_contract
  requires: promoted_kinds_with_dependencies(records)
  ensures: all_dependencies_resolvable(records)
  ensures: no_circular_dependencies(records)
)
```

### Registry Population Contract
```
(⊨ kind_registry_minimum_population
  requires: total_promoted_kinds ≥ 1
  ensures: nonempty_kind_registry
)
```

## Registry Update Plans

### Promote Kind Plan
```
(§ promote_kind
  steps:
    - generate_kind_specification_from_definition
    - validate_kind_artifact_integrity
    - analyze_kind_dependencies
    - append_to_kind_registry
    - update_domain_distribution
    - regenerate_kind_registry_hash
    - verify_kind_registry_consistency
)
```

### Kind Registry Maintenance Plan
```
(§ maintain_kind_registry
  steps:
    - validate_all_kind_uuid_uniqueness
    - validate_all_kind_name_uniqueness
    - verify_all_kind_artifact_integrity
    - analyze_dependency_graph_integrity
    - update_domain_distribution
    - regenerate_kind_registry_hash
    - check_kind_registry_consistency
    - repair_kind_inconsistencies
)
```

### Kind Registry Query Plan
```
(§ query_kind_registry
  steps:
    - parse_kind_query_criteria
    - apply_kind_lookup_functions
    - filter_matching_kind_records
    - resolve_kind_dependencies
    - return_kind_query_results
)
```

### Domain Distribution Analysis Plan
```
(§ analyze_kind_domain_distribution
  steps:
    - collect_kind_domain_classifications
    - compute_distribution_statistics
    - identify_domain_imbalances
    - suggest_promotion_focus_areas
    - update_distribution_metadata
)
```

## Example Promoted Kind (Template)

### Example Kind Record
```
(• ⟦example_promoted_kind⟧ ∷ PromotedKindRecord = {
  uuid: "kind-12345678-1234-5678-9abc-123456789abc",
  kind_name: "ValidationRequest",
  source_file: "spec/patterns/validation-patterns.smars.md",
  source_line: 15,
  promoted_timestamp: 1721594700,
  artifact_path: "spec/automation/validation-request-type.smars.md",
  artifact_hash: "sha256:def789abc456...",
  promotion_score: 0.92,
  domain_classification: {primary: "automation", secondary: "validation"},
  validation_status: "validated",
  original_kind_definition: "(∷ ValidationRequest {target: STRING, criteria: [STRING], confidence_threshold: FLOAT})",
  complexity_metrics: {
    field_count: 3,
    nesting_depth: 1,
    dependency_count: 0,
    reusability_score: 0.95
  },
  provenance: {source_author: "system", source_session: "2025-07-21-kind-promotion-cycle"},
  tags: ["validation", "request", "automation", "core"],
  related_kinds: ["kind-87654321-4321-8765-dcba-987654321fed"],
  dependent_kinds: ["kind-abcdef12-3456-7890-abcd-ef1234567890"]
})
```

### Example Kind Promotion Trace
```
(• ⟦example_kind_promotion_trace⟧ ∷ KindPromotionTrace = {
  detection_method: "structural_analysis_scanner",
  complexity_assessment: {
    field_count: 3,
    nesting_depth: 1,
    dependency_count: 0,
    reusability_score: 0.95
  },
  domain_classification_confidence: 0.88,
  duplication_check_result: "no_duplicates_detected",
  placement_decision: "spec/automation/validation-request-type.smars.md",
  verification_result: "kind_artifact_created_successfully",
  integration_result: "kind_specification_parsed_and_validated"
})
```

## Registry Evolution

This symbolic kind registry enables:
- **Symbolic Queries**: `(apply lookup_kinds_by_domain ▸ {primary: "automation", secondary: "validation"})`
- **Tag-Based Clustering**: `(apply lookup_kinds_by_tags ▸ ["validation", "core"])`
- **Dependency Navigation**: `(apply lookup_dependent_kinds ▸ "kind-uuid")`
- **Complexity Analysis**: `(apply lookup_kinds_by_complexity ▸ {min_fields: 3, max_nesting: 2})`
- **Validation Enforcement**: `(⊨ unique_kind_names_per_domain)` contracts
- **Dependency Integrity**: Circular dependency detection and resolution tracking
- **Programmatic Updates**: Registry changes via symbolic plans
- **Agent Integration**: Registry becomes queryable data source for agents
- **Self-Validation**: Registry validates its own consistency via contracts
- **Explicit Hash Management**: `(§ regenerate_kind_registry_hash)` ensures integrity after modifications
- **Provenance Tracking**: Full lineage with `last_modified_by` and `last_modified_at` timestamping
- **Bootstrap Protection**: `(⊨ kind_registry_minimum_population)` prevents empty registry issues
- **Domain Distribution**: Real-time tracking of kind distribution across domains

The kind registry is now a first-class SMARS specification that maintains structural integrity while enabling rich querying and analysis of promoted type definitions.