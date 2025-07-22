# Registry Query Interface

@role(nucleus)

Exposed registry query functions enabling symbolic plans to interact with all promotion registries.

## Cross-Registry Query Functions

### Universal Lookup Functions
```
(ƒ lookup_cues_by_tag ∷ STRING → [PromotedCueRecord])
(ƒ lookup_kinds_by_tag ∷ STRING → [PromotedKindRecord])
(ƒ lookup_agents_by_tag ∷ STRING → [PromotedAgentRecord])
(ƒ lookup_plans_by_tag ∷ STRING → [PromotedPlanRecord])
```

### Domain-Based Queries
```
(ƒ lookup_cues_by_domain ∷ Domain → [PromotedCueRecord])
(ƒ lookup_kinds_by_domain ∷ Domain → [PromotedKindRecord])
(ƒ lookup_agents_by_domain ∷ Domain → [PromotedAgentRecord])
(ƒ lookup_plans_by_domain ∷ Domain → [PromotedPlanRecord])
```

### Cross-Registry Search
```
(ƒ search_all_registries ∷ SearchCriteria → UnifiedSearchResults)
(ƒ find_cross_references ∷ UUID → [CrossReference])
(ƒ analyze_promotion_patterns ∷ TimeRange → PromotionAnalysis)
```

## Query Plans

### Tag-Based Query Plan
```
(§ query_by_tag
  steps:
    - validate_tag_parameter
    - query_cues_registry
    - query_kinds_registry
    - query_agents_registry
    - query_plans_registry
    - aggregate_results
    - return_unified_results
)
```

### Domain Analysis Plan
```
(§ analyze_domain_distribution
  steps:
    - collect_all_domain_classifications
    - compute_distribution_statistics
    - identify_domain_gaps
    - suggest_promotion_opportunities
    - generate_analysis_report
)
```

## Example Query Usage

### Find All Validation-Related Promotions
```
(§ find_validation_promotions
  steps:
    - apply_lookup_cues_by_tag_validation
    - apply_lookup_kinds_by_tag_validation
    - apply_lookup_agents_by_tag_validation
    - apply_lookup_plans_by_tag_validation
    - aggregate_validation_ecosystem
)
```

### Cross-Reference Analysis
```
(§ analyze_promotion_relationships
  steps:
    - identify_related_cue_chains
    - map_kind_dependency_networks
    - trace_agent_collaboration_patterns
    - visualize_plan_execution_flows
    - generate_relationship_insights
)
```

This query interface enables plans to perform:
- `(apply lookup_kinds_by_tag ▸ "validation")` - Find all validation-related kinds
- `(apply search_all_registries ▸ {tag: "core", domain: {primary: "automation"}})` - Complex searches
- `(apply find_cross_references ▸ "cue-uuid")` - Trace promotion genealogies