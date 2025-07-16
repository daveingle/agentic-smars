@role(architect)

// --- Integration Types
(kind DEURequest ∷ { prompt: STRING, domain: STRING })
(kind DEUSpec ∷ { module: STRING, path: STRING, domain: STRING })
(kind DEUImplementation ∷ { module: STRING, path: STRING, content: STRING })
(kind DEUReview ∷ { module: STRING, status: STRING, notes: STRING })
(kind AgenticCycle ∷ { phase: STRING, artifact: STRING, status: STRING })

// --- Integration Maplets
(maplet requestToDEU ∷ DEURequest → DEUSpec)
(maplet specToImplementation ∷ DEUSpec → DEUImplementation)
(maplet implementationToReview ∷ DEUImplementation → DEUReview)
(maplet reviewToUpdate ∷ DEUReview → DEUSpec)
(maplet cycleToPhase ∷ AgenticCycle → STRING)

// --- Integration Contracts
(contract requestToDEU
  ⊨ requires: prompt ≠ ""
  ⊨ requires: domain ≠ ""
  ⊨ ensures: module ≠ ""
  ⊨ ensures: path contains domain)

(contract specToImplementation
  ⊨ requires: path ≠ ""
  ⊨ ensures: content ≠ ""
  ⊨ ensures: content validates against spec)

(contract implementationToReview
  ⊨ requires: content ≠ ""
  ⊨ ensures: status = "pass" | status = "fail"
  ⊨ ensures: notes provide actionable feedback)

(contract reviewToUpdate
  ⊨ requires: status ≠ ""
  ⊨ ensures: updated spec addresses review feedback)

// --- Integrated Agentic Loop
(plan agenticDEULoop
  § steps:
    - requestToDEU
    - specToImplementation
    - implementationToReview
    - reviewToUpdate
)

// --- Validation Branch
(branch reviewOutcome
  ⎇ when status = "pass":
      → assembleArtifact
    when status = "fail":
      → reviewToUpdate
    else:
      → implementationToReview
)

// --- Integration Tests
(test deu_loop_closure expects: "loop complete")
(test failed_review_triggers_update expects: "reviewToUpdate")
(test successful_review_assembles_artifact expects: "assembleArtifact")

// --- Integration Cues
(cue cross_domain_reuse
  ⊨ suggests: extract common patterns from DEU generation for reuse across domains)

(cue feedback_loop_optimization
  ⊨ suggests: optimize review-to-update cycle based on failure patterns)

(cue meta_level_reflection
  ⊨ suggests: apply DEU generation to improve the agentic loop itself)