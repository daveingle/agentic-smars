# SMARS Core Implementation

@role(nucleus)

The minimal symbolic substrate - six primitive atoms providing complete expressivity.

## Atomic Primitives

### • (datum)
```
(• ⟦symbolic_constant⟧ ∷ TYPE = value)
```
Atomic values with optional typing.

### ∷ (kind)  
```
(∷ TypeName {field: TYPE, ...})
```
Type definitions supporting composition.

### ƒ (maplet)
```
(ƒ function_name ∷ InputType → OutputType)
```
Function signatures with typed interfaces.

### ▸ (apply)
```
(▸ function_name input_value)
```
Function invocation with symbolic application.

### ⊨ (contract)
```
(⊨ constraint_name
  requires: precondition
  ensures: postcondition)
```
Constraint assertions and validation rules.

### § (plan)
```
(§ procedure_name
  steps:
    - step_one
    - step_two
    - step_three)
```
Ordered procedural sequences.

## Foundation Grammar

```
specification = { role_directive | declaration } ;
role_directive = "@role" "(" role_type ")" ;
declaration = datum_decl | kind_decl | maplet_decl | apply_decl | contract_decl | plan_decl ;

datum_decl = "(" "•" "⟦" IDENTIFIER "⟧" [ "∷" type ] "=" literal ")" ;
kind_decl = "(" "∷" IDENTIFIER "{" field_list "}" ")" ;  
maplet_decl = "(" "ƒ" IDENTIFIER "∷" type_expr "→" type_expr ")" ;
apply_decl = "(" "▸" IDENTIFIER expr ")" ;
contract_decl = "(" "⊨" IDENTIFIER constraint_list ")" ;
plan_decl = "(" "§" IDENTIFIER "steps:" step_list ")" ;
```

This creates perfect consistency between our symbolic atoms and their grammatical representation.