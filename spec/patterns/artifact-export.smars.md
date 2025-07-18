# Artifact Export Pattern

@role(architect)

(kind ArtifactExport ∷ {
  source_block_id: STRING,
  output_path: STRING,
  artifact_type: STRING,
  content_format: STRING,
  verified: BOOL,
  notes: STRING
})

(datum ⟦extraction_policy⟧ ∷ STRING = "extract any explicitly declared ArtifactExport block from *.smars.md or *.md")

(maplet extractDeclaredArtifacts ∷ File → [ArtifactExport])
(maplet writeArtifactsToDisk ∷ [ArtifactExport] → BOOL)
(maplet verifyArtifactPresence ∷ [ArtifactExport] → BOOL)

(contract validateArtifactProduction
  ⊨ requires: all(artifact in artifacts, artifact.output_path ≠ "")
  ⊨ ensures: all(artifact in artifacts, artifact.verified = true)
)

(plan exportDeclaredArtifacts
  § steps:
    - scanSpecFilesForArtifacts
    - extractDeclaredArtifacts
    - writeArtifactsToDisk
    - verifyArtifactPresence
)

(cue reinforce_output_grounding
  ⊨ suggests: require validateArtifactProduction as a default postcondition on implementation specs
)