@role(architect)

// Types
(kind DomainArtifact ∷ { id: STRING, kind: STRING, domain: STRING, location: STRING })
(kind ArtifactReview ∷ { target: STRING, result: STRING, notes: STRING })

// Datum Template Seeds
(datum ⟦default_location⟧ ∷ STRING = "spec/{{domain}}/{{id}}.smars.md")

// Core Transformation Maplets
(maplet declareArtifact ∷ { id: STRING, domain: STRING } → DomainArtifact)
(maplet implementArtifact ∷ DomainArtifact → DomainArtifact)
(maplet reviewArtifact ∷ DomainArtifact → ArtifactReview)
(maplet updateArtifactPlan ∷ ArtifactReview → DomainArtifact)

// Contracts
(contract declareArtifact
  ⊨ requires: id ≠ ""
  ⊨ ensures: kind = "spec"
)

(contract implementArtifact
  ⊨ requires: kind = "spec"
  ⊨ ensures: artifact_exports_defined = true ∧ concrete_interpreters_specified = true
)

(contract reviewArtifact
  ⊨ requires: artifact_exports_defined = true
  ⊨ ensures: result ≠ "" ∧ validation_status_recorded = true
)

// Plan Template
(plan artifactLifecycle
  § steps:
    - declareArtifact
    - implementArtifact
    - reviewArtifact
    - updateArtifactPlan
)

// Cue for Instantiation
(cue instantiate_lifecycle_for_domain
  ⊨ suggests: declareArtifact with a specific id and domain
)

(cue symbolic_first_implementation
  ⊨ suggests: implementation means adding ArtifactExport blocks to specs, not separate files
)

(cue traceable_artifact_validation
  ⊨ suggests: review validates that exported artifacts exist and function correctly
)

// --- Artifact Export
apply ArtifactExport ∷
  ▸ concrete_interpreter: validateLifecycle, checkArtifactExports, generateLifecycleReport functions
  ▸ traceable_artifact: lifecycle-validation.json, artifact-status.md, domain-artifacts-registry.smars.md
  ▸ phase_execution_report: lifecycle_completion_status with validation_results and artifact_inventory
