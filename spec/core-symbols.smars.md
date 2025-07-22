# Core SMARS Symbols (v0.1)

@role(foundation)

The minimal symbolic substrate for SMARS - Six primitive atoms that provide full expressivity through composition.

## Core Primitive Atoms

### datum (•)
Atomic constants with optional typing.

```
datum_decl = "(" "datum" "⟦" IDENTIFIER "⟧" [ "∷" IDENTIFIER ] "=" literal ")"
```

(datum ⟦symbolic_constant⟧ ∷ STRING = "example_value")

### kind (∷) 
Type definitions supporting nesting and composition.

```
kind_decl = "(" "kind" IDENTIFIER "∷" type_expr ")"
type_expr = IDENTIFIER | "{" field_list "}"
field_list = field { "," field }
field = IDENTIFIER ":" IDENTIFIER
```

(kind MessageType ∷ {
  content: STRING,
  timestamp: INT,
  sender: STRING
})

### maplet (ƒ)
Function signatures with typed inputs and outputs.

```
maplet_decl = "(" "maplet" IDENTIFIER "∷" type_expr "→" type_expr ")"
```

(maplet process_message ∷ MessageType → ProcessedMessage)

### apply (▸)
Function application with symbolic invocation.

```
apply_decl = "(" "apply" IDENTIFIER "▸" expr ")"
expr = literal | IDENTIFIER | "{" arg_list "}"
arg_list = field { "," field }
```

(apply process_message ▸ {
  content: "hello",
  timestamp: 1642784400,
  sender: "user"
})

### contract (⊨)
Constraint assertions and validation rules.

```
contract_decl = "(" "contract" IDENTIFIER 
                { require_clause | ensure_clause } ")"
require_clause = "⊨" "requires:" condition
ensure_clause = "⊨" "ensures:" condition
condition = IDENTIFIER | IDENTIFIER relation literal
relation = "≠" | "=" | "<" | ">"
```

(contract message_processing
  ⊨ requires: valid_message(input)
  ⊨ ensures: output_generated
)

### plan (§)
Ordered sequences of symbolic steps.

```
plan_decl = "(" "plan" IDENTIFIER "§" "steps:" step_list ")"
step_list = "-" IDENTIFIER { "-" IDENTIFIER }
```

(plan handle_user_request
  § steps:
    - validate_input
    - process_message
    - generate_response
    - deliver_output
)

## Compositional Principles

All higher-order constructs emerge from these six primitives through:

1. **Structural Composition** - Complex kinds built from primitive types
2. **Functional Composition** - Maplets composed via apply chains  
3. **Constraint Composition** - Contracts composed via logical conjunction
4. **Procedural Composition** - Plans composed via step sequences
5. **Data Composition** - Datum values structured as compound types
6. **Meta-Composition** - Plans that manipulate other symbolic constructs

## Core Symbol Table

| Symbol | Unicode | Semantic Role |
|--------|---------|---------------|
| •      | U+2022  | Data atom marker |
| ∷      | U+2237  | Type annotation |  
| ƒ      | U+0192  | Function marker |
| ▸      | U+25B8  | Application operator |
| ⊨      | U+22A8  | Constraint assertion |
| §      | U+00A7  | Plan delimiter |

## Minimal Grammar (EBNF Core v0.1)

```
spec_file      = { role_directive | declaration } ;

role_directive = "@role" "(" role_type ")" ;
role_type      = "platform" | "developer" | "user" | "foundation" ;

declaration    = kind_decl | datum_decl | maplet_decl 
               | apply_decl | contract_decl | plan_decl ;

kind_decl      = "(" "kind" IDENTIFIER "∷" type_expr ")" ;
datum_decl     = "(" "datum" "⟦" IDENTIFIER "⟧" [ "∷" IDENTIFIER ] "=" literal ")" ;
maplet_decl    = "(" "maplet" IDENTIFIER "∷" type_expr "→" type_expr ")" ;
apply_decl     = "(" "apply" IDENTIFIER "▸" expr ")" ;
contract_decl  = "(" "contract" IDENTIFIER { require_clause | ensure_clause } ")" ;
plan_decl      = "(" "plan" IDENTIFIER "§" "steps:" step_list ")" ;

require_clause = "⊨" "requires:" condition ;
ensure_clause  = "⊨" "ensures:" condition ;
condition      = IDENTIFIER | IDENTIFIER relation literal ;
relation       = "≠" | "=" | "<" | ">" ;
step_list      = "-" IDENTIFIER { "-" IDENTIFIER } ;

type_expr      = IDENTIFIER | "{" field_list "}" ;
field_list     = field { "," field } ;
field          = IDENTIFIER ":" IDENTIFIER ;

expr           = literal | IDENTIFIER | "{" arg_list "}" ;
arg_list       = field { "," field } ;

literal        = STRING | INT | FLOAT ;

IDENTIFIER     = letter { letter | digit | "_" } ;
STRING         = '"' { any_character - '"' } '"' ;
INT            = digit { digit } ;
FLOAT          = digit { digit } [ "." digit { digit } ] ;
letter         = "A" … "Z" | "a" … "z" ;
digit          = "0" … "9" ;
```

## Semantic Foundation

These six atoms provide complete expressivity for:
- **Data modeling** via kind and datum
- **Function specification** via maplet and apply  
- **Constraint specification** via contract
- **Process specification** via plan
- **Compositional extension** via recursive application

All expanded constructs (agent, memory, validation, etc.) are derivable as patterns within this core symbolic algebra.

## Example: Complete Minimal Specification

```
@role(foundation)

(kind RequestType ∷ {
  operation: STRING,
  parameters: {key: STRING, value: STRING}
})

(datum ⟦sample_request⟧ ∷ RequestType = {
  operation: "process",
  parameters: {key: "input", value: "test_data"}
})

(maplet handle_request ∷ RequestType → ResponseType)

(apply handle_request ▸ sample_request)

(contract request_handling
  ⊨ requires: valid_request(input)
  ⊨ ensures: response_generated
)

(plan process_workflow
  § steps:
    - validate_request
    - handle_request
    - return_response
)
```

This specification demonstrates complete symbolic expressivity using only the six core primitives, providing a stable foundation for Foundation Model interpretation and generation.