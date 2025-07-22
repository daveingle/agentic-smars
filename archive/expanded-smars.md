# Expanded SMARS Atoms (v0.3)

This document archives the expanded SMARS symbolic atoms that were part of the v0.3 specification. These atoms have been reduced to a minimal core of 6 primitives. This archive serves as documentation for how the expanded surface area can be reconstructed from the core atoms.

## Archived Atoms

### Multi-Agent Extensions
- `agent` - Agent type definitions with persistent state
- `memory` - Symbolic memory structures for agent persistence  
- `confidence` - First-class uncertainty metrics for decision-making
- `validation` - Inter-agent validation request protocols
- `cue` - Advisory suggestions (non-binding)

### LLM-Specific Constructs
- `default` - LLM-default behavior directive
- `test` - Behavior test case declaration

### Extended Planning Constructs  
- `branch` - Conditional dispatch using `⎇`

## Historical Grammar (EBNF v0.3)

The following grammar definitions are archived here for reference:

```
agent_decl     = "(" "agent" "⟦" IDENTIFIER "⟧" "∷" type_expr
                 [ "capabilities:" capability_list ]
                 [ "memory:" memory_ref ]
                 [ "confidence_calibration:" FLOAT ] ")" ;

memory_decl    = "(" "memory" IDENTIFIER "∷" memory_structure ")" ;
memory_structure = "MemoryEntry" | "ValidationMemory" | "AgentMemory" ;

confidence_decl = "(" "confidence" IDENTIFIER "∷" confidence_structure ")" ;
confidence_structure = "ConfidenceAssessment" | "PlanWithConfidence" ;

validation_decl = "(" "validation" IDENTIFIER "∷" validation_structure ")" ;
validation_structure = "ValidationRequest" | "ValidationResult" | "ValidationFeedback" ;

cue_decl       = "(" "cue" IDENTIFIER "⊨" "suggests:" STRING ")" ;

branch_decl    = "(" "branch" IDENTIFIER "⎇" branch_cases ")" ;
branch_cases   = branch_case { branch_case } [ "else:" "→" IDENTIFIER ] ;
branch_case    = "when" condition ":" "→" IDENTIFIER ;

default_decl   = "(" "default" IDENTIFIER ":" literal_or_identifier ")" ;
test_decl      = "(" "test" IDENTIFIER "expects:" outcome_expr ")" ;
outcome_expr   = "raise" IDENTIFIER | IDENTIFIER ;
```

## Macro Reconstruction Patterns

These expanded atoms can be reconstructed from core primitives as follows:

### Agent as Compound Kind
```
(kind Agent ∷ {
  identity: STRING,
  capabilities: [STRING],
  memory_ref: STRING,
  confidence_calibration: FLOAT
})
```

### Memory as Typed Data Structure
```
(kind MemoryStructure ∷ {
  type: STRING,
  entries: [MemoryEntry],
  persistence_level: STRING
})
```

### Confidence as Quantified Assessment
```
(kind ConfidenceMetric ∷ {
  level: FLOAT,
  uncertainty_sources: [STRING],
  calibration: FLOAT
})
```

### Validation as Structured Request
```
(kind ValidationRequest ∷ {
  validator_id: STRING,
  target: STRING,
  criteria: [STRING],
  confidence_threshold: FLOAT
})
```

### Branch as Conditional Plan
```
(plan conditional_execution
  § steps:
    - evaluate_condition
    - select_branch_target
    - execute_selected_plan
)
```

### Cue as Advisory Datum
```
(datum advisory_insight ∷ STRING = "suggests: specific_guidance")
```

### Test as Contract with Expected Outcome
```
(contract behavior_test
  ⊨ ensures: expected_outcome
)
```

### Default as Configuration Datum
```
(datum system_default ∷ BOOLEAN = true)
```

## Historical Symbol Table

| Symbol       | Description                     |
|--------------|---------------------------------|
| ⎇           | Conditional branching           |
| @role(...)  | Role-scoping declaration        |
| default     | LLM-default behavior directive  |
| test        | Behavior test case declaration  |
| agent       | Agent identity declaration      |
| memory      | Agent memory structure          |
| confidence  | Confidence assessment construct |
| validation  | Validation request/result       |
| cue         | Advisory suggestion construct   |

## Migration Notes

When encountering legacy specifications that use these expanded atoms:
1. Identify the core semantic intent
2. Map to appropriate core primitive combination
3. Use compound kinds for complex structures
4. Represent branching as conditional plans
5. Encode metadata as typed data structures

This reduction maintains full expressivity while simplifying the symbolic surface area for easier Foundation Model interpretation and generation.