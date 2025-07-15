# SMARS DSL Grammar (v0.2)

A formal specification for the SMARS (Symbolic Multi-Agent Reasoning System) DSL. Provides a deterministic, context-free structure, supporting multi-role layers and all core primitives.

---

## 📘 Overview

- Layered roles: platform, developer, user  
- All SMARS atoms: kind, datum, maplet, apply, contract, plan, branch  
- LLM-specific constructs: default, test  
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
               | test_decl ;

kind_decl      = "(" "kind" IDENTIFIER "∷" type_expr ")" ;
datum_decl     = "(" "datum" "⟦" IDENTIFIER "⟧" "∷" IDENTIFIER "=" literal ")" ;
maplet_decl    = "(" "maplet" IDENTIFIER "∷" type_expr "→" type_expr ")" ;
apply_decl     = "(" "apply" IDENTIFIER "▸" expr ")" ;

contract_decl  = "(" "contract" IDENTIFIER { require_clause | ensure_clause } ")" ;
require_clause = "⊨" "requires:" condition ;
ensure_clause  = "⊨" "ensures:" condition ;
condition      = IDENTIFIER | IDENTIFIER relation literal ;
relation       = "≠" | "=" | "<" | ">" ;

plan_decl      = "(" "plan" IDENTIFIER "§" "steps:" step_list ")" ;
step_list      = "-" IDENTIFIER { "-" IDENTIFIER } ;

branch_decl    = "(" "branch" IDENTIFIER "⎇" branch_cases ")" ;
branch_cases   = branch_case { branch_case } [ "else:" "→" IDENTIFIER ] ;
branch_case    = "when" condition ":" "→" IDENTIFIER ;

default_decl   = "(" "default" IDENTIFIER ":" literal_or_identifier ")" ;
test_decl      = "(" "test" IDENTIFIER "expects:" outcome_expr ")" ;
outcome_expr   = "raise" IDENTIFIER | IDENTIFIER ;

type_expr      = IDENTIFIER | "{" field_list "}" ;
field_list     = field { "," field } ;
field          = IDENTIFIER ":" IDENTIFIER ;

expr           = literal | IDENTIFIER | "{" arg_list "}" ;
arg_list       = field { "," field } ;

literal        = STRING | INT ;
literal_or_identifier = literal | IDENTIFIER ;

IDENTIFIER     = letter { letter | digit | "_" } ;
STRING         = '"' { any_character - '"' } '"' ;
INT            = digit { digit } ;
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
  § steps:
    - validate_email_format
    - check_email_uniqueness
    - hash_password
    - store_user
    - send_welcome_email
)

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
