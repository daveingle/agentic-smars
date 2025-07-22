# Plan Promotion Registry

@role(nucleus)

Self-describing symbolic registry of promoted plans - fully parsable and queryable via SMARS.

## Registry Types

### Domain Classification
```
(∷ Domain {
  primary: STRING,
  secondary: STRING
})
```

### Plan Metrics
```
(∷ PlanMetrics {
  step_count: INT,
  complexity_score: FLOAT,
  execution_frequency: INT,
  success_rate: FLOAT
})
```

### Promoted Plan Record
```
(∷ PromotedPlanRecord {
  uuid: STRING,
  plan_name: STRING,
  source_file: STRING,
  source_line: INT,
  promoted_timestamp: INT,
  artifact_path: STRING,
  artifact_hash: STRING,
  promotion_score: FLOAT,
  domain_classification: Domain,
  validation_status: STRING,
  original_plan_definition: STRING,
  plan_metrics: PlanMetrics,
  provenance: PlanProvenance,
  tags: [STRING],
  related_plans: [STRING],
  dependent_maplets: [STRING]
})

(∷ PlanProvenance {
  source_author: STRING,
  source_session: STRING
})

(∷ PlanRegistryMetadata {
  registry_version: STRING,
  last_updated: INT,
  last_modified_by: STRING,
  last_modified_at: INT,
  total_promoted_plans: INT,
  registry_hash: STRING,
  complexity_distribution: {STRING: INT}
})
```

## Registry Data

### Registry Metadata
```
(• ⟦registry_metadata⟧ ∷ PlanRegistryMetadata = {
  registry_version: "1.0.0",
  last_updated: 1721594700,
  last_modified_by: "system",
  last_modified_at: 1721594700,
  total_promoted_plans: 0,
  registry_hash: "sha256:pending",
  complexity_distribution: {}
})
```

### Promoted Plan Records
```
(• ⟦promoted_plans⟧ ∷ [PromotedPlanRecord] = [
  // Records will be appended here by plan promotion process
])
```

## Registry Operations

### Lookup Functions
```
(ƒ lookup_plan_by_uuid ∷ STRING → PromotedPlanRecord)
(ƒ lookup_plans_by_domain ∷ Domain → [PromotedPlanRecord])
(ƒ lookup_plans_by_complexity ∷ ComplexityRange → [PromotedPlanRecord])
(ƒ lookup_plans_by_tags ∷ [STRING] → [PromotedPlanRecord])
(ƒ lookup_related_plans ∷ STRING → [PromotedPlanRecord])
```

## Registry Contracts

### Registry Population Contract
```
(⊨ plan_registry_minimum_population
  requires: total_promoted_plans ≥ 1
  ensures: nonempty_plan_registry
)
```