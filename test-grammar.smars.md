# Test Grammar

@role(language_architect)

## Test Section

(kind TestKind ∷ { name: STRING })

(plan testPlan § steps:
  - step1)

(contract testContract ⊨
  requires: input = true
  ensures: output = true)