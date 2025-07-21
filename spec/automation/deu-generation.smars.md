@role(architect)

// --- Types
(kind Prompt ∷ { text: STRING, domain: STRING })
(kind Spec ∷ { module: STRING, path: STRING, domain: STRING })
(kind Implementation ∷ { module: STRING, path: STRING, content: STRING })
(kind Review ∷ { module: STRING, status: STRING, notes: STRING })
(kind TestSet ∷ { module: STRING, cases: [STRING] })
(kind ValidationResult ∷ { success: BOOL, errors: [STRING] })
(kind DEUArtifact ∷ { spec: Spec, impl: Implementation, tests: TestSet })

// --- Datum Constants
(datum ⟦spec_template⟧ ∷ STRING = "spec/{{domain}}/{{module}}.smars.md")
(datum ⟦impl_template⟧ ∷ STRING = "impl/{{module}}.implementation.md")
(datum ⟦validation_policy⟧ ∷ STRING = "strict")

// --- Core Maplets
(maplet interpretPrompt ∷ Prompt → Spec)
(maplet generateImplementation ∷ Spec → Implementation)
(maplet generateTests ∷ Spec → TestSet)
(maplet validateImplementation ∷ { spec: Spec, impl: Implementation } → Review)
(maplet assembleArtifact ∷ { spec: Spec, impl: Implementation, tests: TestSet } → DEUArtifact)

// --- Contracts
(contract interpretPrompt
  ⊨ requires: text ≠ ""
  ⊨ requires: domain ≠ ""
  ⊨ ensures: path ≠ ""
  ⊨ ensures: module ≠ "")

(contract generateImplementation
  ⊨ requires: path ≠ ""
  ⊨ requires: module ≠ ""
  ⊨ ensures: content ≠ ""
  ⊨ ensures: path contains ".implementation.md")

(contract generateTests
  ⊨ requires: module ≠ ""
  ⊨ ensures: cases ≠ []
  ⊨ ensures: all test cases reference module symbols)

(contract validateImplementation
  ⊨ requires: spec.module = impl.module
  ⊨ requires: validation_policy ≠ ""
  ⊨ ensures: status = "pass" | status = "fail"
  ⊨ ensures: notes ≠ "")

(contract assembleArtifact
  ⊨ requires: spec.module = impl.module
  ⊨ requires: spec.module = tests.module
  ⊨ ensures: artifact contains all components)

// --- Primary Plan
(plan generateDeclarativeExecutionUnit
  § steps:
    - interpretPrompt
    - generateImplementation
    - generateTests
    - validateImplementation
    - assembleArtifact
)

// --- Validation Branching
(branch validationOutcome
  ⎇ when status = "pass":
      → assembleArtifact
    when status = "fail":
      → generateImplementation
    else:
      → validateImplementation
)

// --- Default Behavior
(default automated_validation: true)

// --- Tests
(test full_deu_generation expects: "pass")
(test validation_retry_on_fail expects: "generateImplementation")
(test empty_prompt_handling expects: "raise InvalidPrompt")

// --- Cues
(cue capture_unresolved_symbols
  ⊨ suggests: track any identifiers in the plan not resolved in the implementation)

(cue recommend_test_stub
  ⊨ suggests: auto-generate test scaffolds for any declared test blocks)

(cue emit_validation_matrix
  ⊨ suggests: include a structured table of plan-to-code mapping in review notes)

(cue test_agentic_pathways
  ⊨ suggests: emit test cases simulating plan execution across roles and branches)

(cue integrate_with_promotion
  ⊨ suggests: link DEU generation with cue promotion workflow for iterative refinement)

// --- Artifact Export
apply ArtifactExport ∷
  ▸ concrete_interpreter: parsePrompt, generateSpec, validateOutput functions
  ▸ traceable_artifact: .swift, .json, .sh execution units
  ▸ phase_execution_report: validation_status with pass/fail results