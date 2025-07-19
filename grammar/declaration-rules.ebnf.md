# SMARS Declaration Rules Specification (v1.0)

**Precise cardinalities and ordering constraints for SMARS declarations**

## Overview

This specification tightens the grammar rules for complex SMARS declarations, providing unambiguous parsing through explicit cardinalities, mandatory ordering, and validation constraints.

## Enhanced Declaration Grammar (EBNF)

```ebnf
(* ========== CORE DECLARATIONS ========== *)
kind_decl      = "(" "kind" IDENTIFIER "∷" type_expr ")" ;
datum_decl     = "(" "datum" "⟦" IDENTIFIER "⟧" "∷" type_spec "=" literal ")" ;
maplet_decl    = "(" "maplet" IDENTIFIER "∷" type_signature ")" ;
apply_decl     = "(" "apply" IDENTIFIER "▸" expression ")" ;

(* ========== CONTRACT DECLARATIONS ========== *)
contract_decl  = "(" "contract" IDENTIFIER 
                 [ contract_metadata ]
                 contract_clauses ")" ;

contract_metadata = "description:" STRING ;

contract_clauses = requires_section [ ensures_section ] |
                   ensures_section |
                   requires_section ensures_section ;

requires_section = requires_clause { requires_clause } ;
ensures_section  = ensures_clause { ensures_clause } ;

requires_clause = "⊨" "requires:" condition_expr ;
ensures_clause  = "⊨" "ensures:" condition_expr ;

condition_expr  = logical_expr | comparison_expr | predicate_call | IDENTIFIER ;
logical_expr    = condition_expr logical_op condition_expr |
                  "¬" condition_expr |
                  "(" condition_expr ")" ;
comparison_expr = value_expr comparison_op value_expr ;
predicate_call  = IDENTIFIER "(" [ argument_list ] ")" ;

logical_op      = "∧" | "∨" | "→" | "↔" ;
comparison_op   = "=" | "≠" | "<" | ">" | "≤" | "≥" ;
value_expr      = literal | IDENTIFIER | function_call ;

(* Contract cardinality constraints:
   - At least one requires OR ensures clause required
   - Maximum 10 requires clauses per contract
   - Maximum 5 ensures clauses per contract
   - Maximum 50 tokens per condition expression *)

(* ========== PLAN DECLARATIONS ========== *)
plan_decl      = "(" "plan" IDENTIFIER
                 [ plan_metadata ]
                 plan_body ")" ;

plan_metadata  = { confidence_spec | uncertainty_spec | precondition_spec | postcondition_spec } ;

confidence_spec     = "confidence:" FLOAT ;
uncertainty_spec    = "uncertainty_sources:" string_list ;
precondition_spec   = "preconditions:" condition_list ;
postcondition_spec  = "postconditions:" condition_list ;

plan_body      = "§" "steps:" step_sequence ;
step_sequence  = step_item { step_item } ;
step_item      = simple_step | conditional_step | parallel_step | loop_step ;

simple_step    = "-" step_identifier [ step_metadata ] ;
conditional_step = "-" "if" condition_expr ":" step_identifier [ "else:" step_identifier ] ;
parallel_step  = "-" "parallel:" "{" step_list "}" ;
loop_step      = "-" "while" condition_expr ":" step_identifier ;

step_identifier = IDENTIFIER | qualified_step ;
qualified_step = IDENTIFIER "." IDENTIFIER ;
step_metadata  = "(" step_properties ")" ;
step_properties = step_property { "," step_property } ;
step_property  = "timeout:" INT | "retry:" INT | "critical:" BOOL ;

string_list    = STRING { "," STRING } ;
condition_list = condition_expr { "," condition_expr } ;
step_list      = step_identifier { "," step_identifier } ;

(* Plan cardinality constraints:
   - Minimum 1 step required
   - Maximum 20 steps per plan
   - Maximum 5 uncertainty sources
   - Maximum 3 preconditions, 3 postconditions
   - Confidence must be in range [0.0, 1.0] *)

(* ========== BRANCH DECLARATIONS ========== *)
branch_decl    = "(" "branch" IDENTIFIER 
                 [ branch_metadata ]
                 "⎇" branch_body ")" ;

branch_metadata = "exhaustive:" BOOL | "default_action:" IDENTIFIER ;

branch_body    = branch_cases [ else_clause ] ;
branch_cases   = branch_case { branch_case } ;
branch_case    = "when" condition_expr ":" "→" branch_target ;
else_clause    = "else:" "→" branch_target ;

branch_target  = IDENTIFIER | action_block ;
action_block   = "{" action_sequence "}" ;
action_sequence = action { ";" action } ;
action         = function_call | assignment | IDENTIFIER ;

function_call  = IDENTIFIER "(" [ argument_list ] ")" ;
assignment     = IDENTIFIER "=" expression ;
argument_list  = expression { "," expression } ;

(* Branch cardinality constraints:
   - Minimum 2 branch cases required
   - Maximum 10 branch cases per branch
   - Else clause optional but recommended
   - Maximum 5 actions per action block *)

(* ========== ENHANCED DECLARATIONS ========== *)
default_decl   = "(" "default" IDENTIFIER ":" literal_or_expr 
                 [ "scope:" scope_spec ] ")" ;

test_decl      = "(" "test" IDENTIFIER 
                 [ test_metadata ]
                 "expects:" outcome_expr ")" ;

test_metadata  = { "timeout:" INT | "setup:" IDENTIFIER | "teardown:" IDENTIFIER } ;
outcome_expr   = "raise" exception_spec | "return" value_spec | predicate_expr ;
exception_spec = IDENTIFIER [ "(" STRING ")" ] ;
value_spec     = literal | IDENTIFIER | comparison_expr ;
predicate_expr = condition_expr ;

scope_spec     = "global" | "local" | role_type ;

(* ========== SYMBOLIC AGENCY DECLARATIONS ========== *)
agent_decl     = "(" "agent" "⟦" IDENTIFIER "⟧" "∷" type_expr
                 agent_specification ")" ;

agent_specification = { capability_spec | memory_spec | confidence_spec | validation_spec } ;

capability_spec     = "capabilities:" capability_list ;
memory_spec        = "memory:" memory_ref ;
validation_spec    = "validation:" validation_ref ;

capability_list    = capability { "," capability } ;
capability        = simple_capability | complex_capability ;
simple_capability = IDENTIFIER ;
complex_capability = "{" capability_properties "}" ;
capability_properties = capability_property { "," capability_property } ;
capability_property   = IDENTIFIER ":" ( IDENTIFIER | STRING | literal ) ;

memory_decl    = "(" "memory" IDENTIFIER "∷" memory_type 
                 [ memory_specification ] ")" ;

memory_type    = "MemoryEntry" | "ValidationMemory" | "AgentMemory" | custom_memory_type ;
custom_memory_type = IDENTIFIER ;

memory_specification = { "capacity:" INT | "persistence:" BOOL | "encryption:" BOOL } ;

confidence_decl = "(" "confidence" IDENTIFIER "∷" confidence_type
                  confidence_specification ")" ;

confidence_type = "ConfidenceAssessment" | "PlanWithConfidence" | custom_confidence_type ;
custom_confidence_type = IDENTIFIER ;

confidence_specification = { "calibration:" FLOAT | "uncertainty_model:" IDENTIFIER } ;

validation_decl = "(" "validation" IDENTIFIER "∷" validation_type
                  [ validation_specification ] ")" ;

validation_type = "ValidationRequest" | "ValidationResult" | "ValidationFeedback" | custom_validation_type ;
custom_validation_type = IDENTIFIER ;

validation_specification = { "validator:" IDENTIFIER | "criteria:" condition_list } ;

(* ========== CUE DECLARATIONS ========== *)
cue_decl       = "(" "cue" IDENTIFIER 
                 [ cue_metadata ]
                 "⊨" "suggests:" cue_content ")" ;

cue_metadata   = { "priority:" cue_priority | "context:" IDENTIFIER | "expires:" STRING } ;
cue_priority   = "low" | "medium" | "high" | "critical" ;
cue_content    = STRING | structured_suggestion ;
structured_suggestion = "{" suggestion_properties "}" ;
suggestion_properties = suggestion_property { "," suggestion_property } ;
suggestion_property   = IDENTIFIER ":" ( STRING | IDENTIFIER | literal ) ;

(* ========== TYPE SYSTEM ========== *)
type_expr      = primitive_type | composite_type | parametric_type | type_reference ;

primitive_type = "STRING" | "INTEGER" | "FLOAT" | "BOOL" | "TIMESTAMP" ;
composite_type = record_type | list_type | optional_type ;
parametric_type = generic_type | constrained_type ;
type_reference = IDENTIFIER ;

record_type    = "{" field_list "}" ;
field_list     = field_declaration { "," field_declaration } ;
field_declaration = IDENTIFIER ":" type_expr [ field_constraints ] ;
field_constraints = "[" constraint_list "]" ;
constraint_list = constraint { "," constraint } ;
constraint     = "required" | "unique" | "min:" literal | "max:" literal | "pattern:" STRING ;

list_type      = "[" type_expr "]" | type_expr "[]" ;
optional_type  = "?" type_expr | type_expr "?" ;

generic_type   = IDENTIFIER "<" type_parameter_list ">" ;
type_parameter_list = type_parameter { "," type_parameter } ;
type_parameter = type_expr | type_constraint ;
type_constraint = IDENTIFIER ":" type_expr ;

constrained_type = type_expr "where" constraint_expr ;
constraint_expr  = condition_expr ;

type_signature = input_types "→" output_type ;
input_types    = type_expr | "(" type_list ")" ;
output_type    = type_expr ;
type_list      = type_expr { "," type_expr } ;

type_spec      = type_expr [ type_annotation ] ;
type_annotation = "(" annotation_properties ")" ;
annotation_properties = annotation_property { "," annotation_property } ;
annotation_property   = IDENTIFIER ":" ( STRING | literal ) ;

(* ========== EXPRESSIONS ========== *)
expression     = literal | identifier_expr | compound_expr | function_call ;
identifier_expr = IDENTIFIER [ "." IDENTIFIER ] ;
compound_expr  = record_expr | list_expr ;
record_expr    = "{" field_assignments "}" ;
list_expr      = "[" expression_list "]" ;
field_assignments = field_assignment { "," field_assignment } ;
field_assignment  = IDENTIFIER ":" expression ;
expression_list   = expression { "," expression } ;

literal        = string_literal | numeric_literal | boolean_literal | null_literal ;
string_literal = STRING ;
numeric_literal = INT | FLOAT ;
boolean_literal = "true" | "false" ;
null_literal   = "null" ;

literal_or_expr = literal | identifier_expr ;

memory_ref     = IDENTIFIER ;
validation_ref = IDENTIFIER ;

(* ========== ORDERING CONSTRAINTS ========== *)
(* 
1. Contract declarations: requires clauses must precede ensures clauses
2. Plan declarations: metadata must precede step sequence
3. Branch declarations: when clauses must precede else clause
4. Agent declarations: type must precede specifications
5. All declarations: metadata/annotations must precede main content
*)

(* ========== CARDINALITY CONSTRAINTS ========== *)
(*
CONTRACT_DECL:
  - requires_clause: 0..10
  - ensures_clause: 0..5
  - total_clauses: 1..15

PLAN_DECL:
  - step_item: 1..20
  - uncertainty_sources: 0..5
  - preconditions: 0..3
  - postconditions: 0..3

BRANCH_DECL:
  - branch_case: 2..10
  - else_clause: 0..1
  - actions_per_block: 1..5

AGENT_DECL:
  - capabilities: 0..10
  - memory_refs: 0..3
  - confidence_specs: 0..1

CUE_DECL:
  - suggestion_properties: 1..10
*)

(* ========== VALIDATION RULES ========== *)
(*
1. Identifier uniqueness within scope
2. Type compatibility in assignments
3. Circular dependency detection
4. Required field validation
5. Cardinality enforcement
6. Ordering constraint validation
7. Reserved word checking
8. Unicode normalization
*)
```

## Cardinality Rules

### Contract Declarations
| Element | Minimum | Maximum | Notes |
|---------|---------|---------|-------|
| requires clauses | 0 | 10 | At least one requires OR ensures required |
| ensures clauses | 0 | 5 | At least one requires OR ensures required |
| condition tokens | 1 | 50 | Per condition expression |

### Plan Declarations  
| Element | Minimum | Maximum | Notes |
|---------|---------|---------|-------|
| steps | 1 | 20 | At least one step required |
| uncertainty sources | 0 | 5 | Optional metadata |
| preconditions | 0 | 3 | Optional validation |
| postconditions | 0 | 3 | Optional validation |

### Branch Declarations
| Element | Minimum | Maximum | Notes |
|---------|---------|---------|-------|
| branch cases | 2 | 10 | Minimum two alternatives |
| else clause | 0 | 1 | Optional default |
| actions per block | 1 | 5 | For action blocks |

### Agent Declarations
| Element | Minimum | Maximum | Notes |
|---------|---------|---------|-------|
| capabilities | 0 | 10 | Optional specification |
| memory references | 0 | 3 | Multiple memory types |
| confidence specifications | 0 | 1 | Single calibration |

## Ordering Constraints

### 1. Contract Declaration Order
```smars
(contract example
  description: "Optional metadata first"
  ⊨ requires: condition1 = true    // Requires section
  ⊨ requires: condition2 = true
  ⊨ ensures: result = valid        // Ensures section
)
```

### 2. Plan Declaration Order  
```smars
(plan example
  confidence: 0.85                 // Metadata first
  uncertainty_sources: "source1"
  preconditions: valid_input = true
  § steps:                         // Steps section last
    - validate_input
    - process_data
    - generate_output
)
```

### 3. Branch Declaration Order
```smars
(branch example
  exhaustive: true                 // Metadata first
  ⎇ when condition1: → action1     // When clauses
    when condition2: → action2
    else: → default_action         // Else clause last
)
```

## Validation Rules

### 1. Structural Validation
- **Balanced parentheses**: All declarations properly nested
- **Required elements**: Mandatory components present
- **Cardinality bounds**: Element counts within limits
- **Ordering compliance**: Elements in required order

### 2. Semantic Validation
- **Type consistency**: Types match across references
- **Identifier resolution**: All references resolve to declarations
- **Circular dependencies**: No cycles in dependency graph
- **Scope compliance**: Identifiers used within valid scope

### 3. Quality Validation
- **Meaningful names**: Identifiers follow naming conventions
- **Complete specifications**: All required metadata present
- **Reasonable constraints**: Numeric values within sensible ranges
- **Documentation coverage**: Critical declarations documented

## Error Handling

### 1. Cardinality Violations
```
Error: Too many requires clauses in contract 'user_validation'
  Found: 12 clauses
  Maximum: 10 clauses
  Location: line 15, column 3
```

### 2. Ordering Violations
```
Error: Ensures clause before requires clause in contract 'data_processing'
  Expected: requires clauses first
  Found: ensures clause at line 8
  Location: line 8, column 5
```

### 3. Missing Required Elements
```
Error: Plan 'process_data' has no steps
  Required: At least 1 step
  Found: 0 steps
  Location: line 23, column 1
```

This enhanced declaration grammar provides unambiguous parsing rules with precise constraints, enabling robust validation and helpful error reporting.