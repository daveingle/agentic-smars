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
  ⊨ ensures: kind = "implementation"
)

(contract reviewArtifact
  ⊨ requires: kind = "implementation"
  ⊨ ensures: result ≠ ""
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
