# Macro Rewrites: Expanded Atoms → Core Primitives

@role(foundation)

This specification defines how expanded SMARS atoms can be systematically rewritten as compositions of the six core primitives: datum, kind, maplet, apply, contract, and plan.

## Rewrite Rules

### agent → compound kind + datum
```
// Expanded form:
(agent ⟦cautious_planner⟧ ∷ PlanningAgent
  capabilities: "plan_validation", "uncertainty_assessment"
  memory: validation_memory
  confidence_calibration: 0.8)

// Core rewrite:
(kind AgentType ∷ {
  identity: STRING,
  capabilities: [STRING],
  memory_ref: STRING,
  confidence_calibration: FLOAT
})

(datum ⟦cautious_planner⟧ ∷ AgentType = {
  identity: "cautious_planner",
  capabilities: ["plan_validation", "uncertainty_assessment"],
  memory_ref: "validation_memory", 
  confidence_calibration: 0.8
})
```

### memory → kind
```
// Expanded form:
(memory validation_memory ∷ ValidationMemory)

// Core rewrite:
(kind ValidationMemory ∷ {
  entries: [MemoryEntry],
  persistence_level: STRING,
  access_pattern: STRING
})
```

### confidence → kind + datum
```
// Expanded form:
(confidence assessment ∷ ConfidenceAssessment)

// Core rewrite:
(kind ConfidenceAssessment ∷ {
  level: FLOAT,
  uncertainty_sources: [STRING],
  calibration: FLOAT,
  domain_context: STRING
})

(datum ⟦default_confidence⟧ ∷ ConfidenceAssessment = {
  level: 0.5,
  uncertainty_sources: ["default"],
  calibration: 1.0,
  domain_context: "general"
})
```

### validation → kind + maplet + contract
```
// Expanded form:
(validation plan_validation_request ∷ ValidationRequest)

// Core rewrite:
(kind ValidationRequest ∷ {
  validator_id: STRING,
  target: STRING,
  criteria: [STRING],
  confidence_threshold: FLOAT
})

(maplet validate_plan ∷ ValidationRequest → ValidationResult)

(contract validation_process
  ⊨ requires: valid_request(input)
  ⊨ ensures: validation_completed
)
```

### branch → plan + contract
```
// Expanded form:
(branch decision
  ⎇ when email_missing:
      → raise MissingEmail
    when email_invalid:
      → register_user
    else:
      → proceed)

// Core rewrite:
(kind BranchCondition ∷ {
  condition: STRING,
  target: STRING
})

(datum ⟦email_conditions⟧ ∷ [BranchCondition] = [
  {condition: "email_missing", target: "raise_MissingEmail"},
  {condition: "email_invalid", target: "register_user"},
  {condition: "else", target: "proceed"}
])

(maplet evaluate_condition ∷ STRING → BOOLEAN)
(maplet select_branch ∷ [BranchCondition] → STRING)

(plan conditional_execution
  § steps:
    - evaluate_condition
    - select_branch  
    - execute_target
)

(contract branching_logic
  ⊨ requires: valid_conditions(branches)
  ⊨ ensures: single_target_selected
)
```

### cue → datum + plan
```
// Expanded form:
(cue strategic_validation ⊨ suggests: "request validation when confidence < 0.7")

// Core rewrite:
(datum ⟦strategic_validation_cue⟧ ∷ STRING = "request validation when confidence < 0.7")

(plan advisory_guidance
  § steps:
    - assess_confidence
    - check_threshold
    - suggest_validation
)
```

### test → contract + datum
```
// Expanded form:
(test missing_email_case expects: raise MissingEmail)

// Core rewrite:
(datum ⟦expected_outcome⟧ ∷ STRING = "raise_MissingEmail")

(contract missing_email_test
  ⊨ requires: email_missing_scenario
  ⊨ ensures: outcome_matches_expected
)
```

### default → datum
```
// Expanded form:
(default enforce_json_schema: true)

// Core rewrite:
(datum ⟦enforce_json_schema⟧ ∷ BOOLEAN = true)
```

## Systematic Rewrite Process

### 1. Identify Expanded Construct
```
maplet identify_construct ∷ SymbolicExpression → ConstructType
```

### 2. Extract Semantic Components  
```
maplet extract_semantics ∷ ConstructType → SemanticComponents
```

### 3. Map to Core Primitives
```
maplet map_to_core ∷ SemanticComponents → CoreComposition
```

### 4. Generate Core Representation
```
maplet generate_core ∷ CoreComposition → CoreSpecification
```

## Rewrite Validation

(contract rewrite_correctness
  ⊨ requires: expanded_construct_valid(input)
  ⊨ ensures: core_representation_equivalent(output)
)

(plan validate_rewrite
  § steps:
    - parse_expanded_form
    - apply_rewrite_rules
    - validate_semantic_preservation
    - verify_core_syntax
)

## Meta-Rewrite Capabilities

The core system can represent its own rewrite rules:

```
(kind RewriteRule ∷ {
  source_pattern: STRING,
  target_pattern: STRING,
  semantic_constraints: [STRING]
})

(maplet apply_rewrite ∷ RewriteRule → SymbolicExpression → SymbolicExpression)

(plan meta_rewrite
  § steps:
    - identify_pattern
    - select_rule
    - apply_rewrite
    - validate_result
)
```

This enables the system to evolve its own rewrite capabilities through symbolic manipulation of the rewrite rules themselves.

## Compilation Pipeline

(plan compile_expanded_to_core
  § steps:
    - tokenize_expanded_spec
    - parse_symbolic_structure
    - identify_expandable_constructs  
    - apply_systematic_rewrites
    - validate_core_compliance
    - generate_core_specification
)

This systematic approach ensures that all expanded SMARS constructs can be mechanically transformed into equivalent core representations while preserving semantic meaning and enabling Foundation Model processing.