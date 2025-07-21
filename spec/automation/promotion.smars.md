@role(architect)

// --- Types
(kind Cue ∷ { id: STRING, suggests: STRING })
(kind Promotion ∷ { cueId: STRING, declaration: STRING })
(kind ReviewResult ∷ { cueId: STRING, outcome: STRING, reason: STRING })
(kind PromotionKind ∷ "plan" | "maplet" | "contract" | "test" | "kind")
(kind CuePromotionMemo ∷ { cueId: STRING, promotedAs: PromotionKind, artifact: STRING })
(datum ⟦promotion_policy⟧ ∷ Cue → BOOL)

// --- Maplets
(maplet extractCues ∷ Artifact → [Cue])
(maplet assessCue ∷ Cue → BOOL)
(maplet promoteCue ∷ Cue → Promotion)
(maplet rejectCue ∷ Cue → ReviewResult)
(maplet recordPromotion ∷ Promotion → CuePromotionMemo)
(maplet evaluateCueForPromotion ∷ Cue → { ready: BOOL, reason: STRING })
(maplet promoteKindFromCue ∷ Cue → KindPlacement)

// --- Contracts
(contract assessCue
  ⊨ requires: suggests ≠ ""
  ⊨ ensures: output = true | false
)

(contract evaluateCueForPromotion
  ⊨ requires: cue.id ≠ ""
  ⊨ requires: promotion_policy(cue) = true
  ⊨ ensures: reason ≠ ""
)

(contract promoteCue
  ⊨ requires: assessCue(cue) = true
  ⊨ ensures: declaration ≠ ""
  ⊨ ensures: declaration reuses defined kind if applicable
)

(contract recordPromotion
  ⊨ requires: promotion.cueId ≠ ""
  ⊨ ensures: artifact ≠ ""
)

(contract promoteKindFromCue
  ⊨ requires: suggests contains "kind"
  ⊨ ensures: kind placed in canonical location
)

// --- Agent Plan
(plan promoteAvailableCues
  § steps:
    - extractCues
    - evaluateCueForPromotion
    - promoteCue
    - promoteKindFromCue
    - recordPromotion
    - rejectCue
)

// --- Test
(test promote_if_valid expects: "declaration emitted")

(cue possible_kind_duplication
  ⊨ suggests: check if promoted declaration duplicates a known kind
)

(cue integrate_kind_promotion
  ⊨ suggests: link with kind-promotion system for canonical placement
)

(kind PromotionLog ∷ [CuePromotionMemo])

// --- Artifact Export
apply ArtifactExport ∷
  ▸ concrete_interpreter: evaluateCue, promoteToSpec, recordPromotion functions
  ▸ traceable_artifact: spec/{{domain}}/promoted-specs.smars.md, cues/promotion-log.md
  ▸ phase_execution_report: promotion_status with success/failure outcomes
