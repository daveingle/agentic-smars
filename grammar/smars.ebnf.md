# SMARS DSL Grammar (v0.3)

A formal specification for the SMARS (Symbolic Multi-Agent Reasoning System) DSL. Provides a deterministic, context-free structure, supporting multi-role layers, all core primitives, and symbolic agency constructs.

---

## 📘 Overview

- Layered roles: platform, developer, user  
- All SMARS atoms: kind, datum, maplet, apply, contract, plan, branch  
- LLM-specific constructs: default, test  
- Symbolic agency constructs: agent, memory, confidence, validation
- Structured using **EBNF** compliant syntax

---

## 🔤 EBNF Grammar

```
spec_file      = { directive | declaration } ;

directive      = role_directive ;
role_directive = "@role" "(" role_type ")" ;
role_type      = "platform" | "developer" | "user" ;

declaration    = kind_decl
               | datum_decl
               | maplet_decl
               | apply_decl
               | contract_decl
               | plan_decl
               | branch_decl
               | default_decl
               | test_decl
               | agent_decl
               | memory_decl
               | confidence_decl
               | validation_decl
               | cue_decl ;

kind_decl      = "(" "kind" IDENTIFIER "∷" type_expr ")" ;
datum_decl     = "(" "datum" "⟦" IDENTIFIER "⟧" "∷" IDENTIFIER "=" literal ")" ;
maplet_decl    = "(" "maplet" IDENTIFIER "∷" type_expr "→" type_expr ")" ;
apply_decl     = "(" "apply" IDENTIFIER "▸" expr ")" ;

contract_decl  = "(" "contract" IDENTIFIER { require_clause | ensure_clause } ")" ;
require_clause = "⊨" "requires:" condition ;
ensure_clause  = "⊨" "ensures:" condition ;
condition      = IDENTIFIER | IDENTIFIER relation literal ;
relation       = "≠" | "=" | "<" | ">" ;

plan_decl      = "(" "plan" IDENTIFIER
                 [ "confidence:" FLOAT ]
                 [ "uncertainty_sources:" string_list ]
                 "§" "steps:" step_list ")" ;
step_list      = "-" IDENTIFIER { "-" IDENTIFIER } ;

branch_decl    = "(" "branch" IDENTIFIER "⎇" branch_cases ")" ;
branch_cases   = branch_case { branch_case } [ "else:" "→" IDENTIFIER ] ;
branch_case    = "when" condition ":" "→" IDENTIFIER ;

default_decl   = "(" "default" IDENTIFIER ":" literal_or_identifier ")" ;
test_decl      = "(" "test" IDENTIFIER "expects:" outcome_expr ")" ;
outcome_expr   = "raise" IDENTIFIER | IDENTIFIER ;

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

type_expr      = IDENTIFIER | "{" field_list "}" ;
field_list     = field { "," field } ;
field          = IDENTIFIER ":" IDENTIFIER ;

expr           = literal | IDENTIFIER | "{" arg_list "}" ;
arg_list       = field { "," field } ;

literal        = STRING | INT | FLOAT ;
literal_or_identifier = literal | IDENTIFIER ;

capability_list = capability { "," capability } ;
capability     = IDENTIFIER | "{" IDENTIFIER ":" IDENTIFIER "}" ;
memory_ref     = IDENTIFIER ;
string_list    = STRING { "," STRING } ;

IDENTIFIER     = letter { letter | digit | "_" } ;
STRING         = '"' { any_character - '"' } '"' ;
INT            = digit { digit } ;
FLOAT          = digit { digit } [ "." digit { digit } ] ;
letter         = "A" … "Z" | "a" … "z" ;
digit          = "0" … "9" ;
```

---

## 📖 Symbol Table

| Symbol     | Description                     |
|------------|---------------------------------|
| ▸          | Function application in apply   |
| §          | Plan step list delimiter        |
| ⎇          | Conditional branching           |
| ⊨          | Contract requirement/postcondition |
| @role(...) | Role-scoping declaration        |
| default    | LLM-default behavior directive  |
| test       | Behavior test case declaration  |
| agent      | Agent identity declaration      |
| memory     | Agent memory structure          |
| confidence | Confidence assessment construct |
| validation | Validation request/result       |
| cue        | Advisory suggestion construct   |

---

## ⚙️ Example Usage

```
@role(platform)
(contract send_email
  ⊨ requires: valid_email(mail)
  ⊨ ensures: email_sent
)

@role(developer)
(default enforce_json_schema: true)

@role(user)
(plan register_user
  confidence: 0.85
  uncertainty_sources: "email_uniqueness_check", "password_validation"
  § steps:
    - validate_email_format
    - check_email_uniqueness
    - hash_password
    - store_user
    - send_welcome_email
)

(agent ⟦cautious_planner⟧ ∷ PlanningAgent
  capabilities: "plan_validation", "uncertainty_assessment"
  memory: validation_memory
  confidence_calibration: 0.8
)

(memory validation_memory ∷ ValidationMemory)

(validation plan_validation_request ∷ ValidationRequest)

(cue strategic_validation ⊨ suggests: "request validation when confidence < 0.7")

(branch decision
  ⎇ when email_missing:
      → raise MissingEmail
    when email_invalid:
      → register_user
    else:
      → proceed
)

(test missing_email_case
  expects: raise MissingEmail
)
```

---
