# Agentic Patterns in SMARS

Emergent patterns that arise from sophisticated composition of SMARS primitives for agentic development workflows.

---

```smars
@role(platform)

// 1. Structured Change Management
(kind SpecDelta ∷ { change_id: STRING, description: STRING, applied: BOOL })

(maplet proposeChange ∷ STRING → SpecDelta)
(maplet applyDelta ∷ SpecDelta → SpecDelta)
(maplet rejectDelta ∷ SpecDelta → SpecDelta)

(contract proposeChange
  ⊨ requires: description ≠ ""
  ⊨ ensures: applied = false)

(contract applyDelta
  ⊨ requires: applied = false
  ⊨ ensures: applied = true)

// 2. Self-Referential Execution Context
(kind AgenticCycle ∷ { phase: STRING, artifact: STRING, status: STRING })

(datum ⟦cycle_phases⟧ ∷ [STRING] = ["review", "automation", "projection"])

(maplet locateArtifact ∷ STRING → AgenticCycle)
(maplet advancePhase ∷ AgenticCycle → AgenticCycle)

(contract locateArtifact
  ⊨ requires: artifact ≠ ""
  ⊨ ensures: phase ∈ cycle_phases)

// 3. Meta-Plan Orchestration
(plan runSymbolicAutomation § steps:
  - evaluateCues
  - promoteValidCues
  - invokeAgenticLoop
  - reconcileReviewState)

(maplet evaluateCues ∷ [Cue] → [Cue])
(maplet promoteValidCues ∷ [Cue] → [Plan])
(maplet invokeAgenticLoop ∷ [Plan] → [Artifact])
(maplet reconcileReviewState ∷ [Artifact] → ReviewOutcome)

(contract runSymbolicAutomation
  ⊨ requires: cues_available
  ⊨ ensures: review_state_consistent)

// 4. Structured Review Results
(kind ReviewOutcome ∷ { status: STRING, notes: STRING, deltas: [SpecDelta] })

(datum ⟦review_statuses⟧ ∷ [STRING] = ["pass", "fail", "partial"])

(maplet generateReview ∷ Artifact → ReviewOutcome)
(maplet extractDeltas ∷ ReviewOutcome → [SpecDelta])

(contract generateReview
  ⊨ requires: artifact_complete
  ⊨ ensures: status ∈ review_statuses)

// 5. Cue-to-Plan Linking
(kind CueLink ∷ { cue_id: STRING, target_plan: STRING, promoted: BOOL })

(maplet linkCueToPlan ∷ STRING → CueLink)
(maplet promoteCue ∷ CueLink → Plan)

(contract linkCueToPlan
  ⊨ requires: cue_id ≠ ""
  ⊨ ensures: promoted = false)

(contract promoteCue
  ⊨ requires: promoted = false
  ⊨ ensures: promoted = true)

// 6. Symbolic Refinement and Stability
(kind RefinementType ∷ { 
  type: STRING, 
  intent_preserved: BOOL, 
  compatibility: STRING 
})

(kind SymbolicChange ∷ { 
  symbol_name: STRING, 
  old_definition: STRING, 
  new_definition: STRING, 
  refinement_type: RefinementType 
})

(kind AgenticInsight ∷ { 
  understanding: STRING, 
  confidence: FLOAT, 
  implications: [STRING] 
})

(kind ConsensusView ∷ { 
  agreed_definition: STRING, 
  consensus_level: FLOAT, 
  dissenting_agents: [STRING] 
})

(datum ⟦refinement_types⟧ ∷ [STRING] = ["additive", "clarifying", "structural"])
(datum ⟦intent_preservation_threshold⟧ ∷ FLOAT = 0.8)
(datum ⟦consensus_threshold⟧ ∷ FLOAT = 0.7)

(maplet detectSymbolicRefinement ∷ SymbolicChange → RefinementType)
(maplet preserveSymbolicIntent ∷ SymbolicChange → SymbolicChange)
(maplet validateIntentConsistency ∷ SymbolicChange → BOOL)
(maplet learnFromEvolution ∷ SymbolicChange → AgenticInsight)
(maplet adaptUnderstanding ∷ AgenticInsight → SymbolicChange)
(maplet reconcileAgentViews ∷ [AgenticInsight] → ConsensusView)
(maplet establishSymbolicConsensus ∷ [SymbolicChange] → SymbolicChange)

(contract detectSymbolicRefinement
  ⊨ requires: old_definition ≠ new_definition
  ⊨ ensures: refinement_type.type ∈ refinement_types)

(contract preserveSymbolicIntent
  ⊨ requires: refinement_type.intent_preserved = true
  ⊨ ensures: core_meaning_unchanged)

(contract validateIntentConsistency
  ⊨ requires: refinement_type ≠ ""
  ⊨ ensures: intent_preserved ≥ intent_preservation_threshold)

(contract establishSymbolicConsensus
  ⊨ requires: agent_views.length > 1
  ⊨ ensures: consensus_level ≥ consensus_threshold)

// Meta-Orchestration Plan
(plan agenticEvolution § steps:
  - proposeChange
  - locateArtifact
  - runSymbolicAutomation
  - generateReview
  - promoteCue)

// Enhanced Symbolic Stability Plan
(plan maintainSymbolicStability § steps:
  - detectSymbolicRefinement
  - preserveSymbolicIntent
  - validateIntentConsistency
  - learnFromEvolution
  - establishSymbolicConsensus)

(test delta_application expects: applied = true)
(test cycle_advancement expects: phase = "automation")
(test cue_promotion expects: promoted = true)
(test symbolic_refinement_detection expects: refinement_type.type ∈ refinement_types)
(test intent_preservation expects: intent_preserved ≥ intent_preservation_threshold)
(test consensus_establishment expects: consensus_level ≥ consensus_threshold)
```

---

## Pattern Summary

These emergent patterns demonstrate how agents naturally compose SMARS primitives into sophisticated workflows:

- **SpecDelta**: Structured change proposals using existing `kind` and `contract` primitives
- **AgenticCycle**: Self-referential execution context using `datum` and `maplet`
- **Meta-orchestration**: Higher-level plans coordinating multiple sub-plans
- **ReviewOutcome**: Structured feedback using typed data structures
- **CueLink**: Traceability from suggestions to implementation

The power emerges from composition, not additional syntax.