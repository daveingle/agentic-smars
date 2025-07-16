@role(architect)

// --- Enhanced Advisory Types
(kind Advisory ∷ { id: STRING, domain: STRING, context: STRING, guidance: STRING, confidence: FLOAT })
(kind AdvisoryPattern ∷ { pattern: STRING, triggers: [STRING], responses: [Advisory] })
(kind AdvisoryContext ∷ { symbols: [STRING], relationships: [STRING], constraints: [STRING] })
(kind AdvisoryApplication ∷ { advisory: Advisory, target: STRING, result: STRING })
(kind AdvisoryKnowledge ∷ { domain: STRING, patterns: [AdvisoryPattern], heuristics: [STRING] })
(kind PatternAudit ∷ { successful_patterns: [AdvisoryPattern], failed_patterns: [AdvisoryPattern], new_patterns: [AdvisoryPattern], confidence_scores: [FLOAT] })

// --- Advisory Classification
(kind AdvisoryType ∷ "aesthetic" | "semantic" | "contextual" | "experiential" | "domain_specific")
(kind AdvisoryStrength ∷ "suggestion" | "recommendation" | "strong_guidance" | "requirement")
(kind AdvisoryScope ∷ "local" | "component" | "system" | "cross_domain")

// --- Outcome Shape Types
(kind ExtractOutcome ∷ { symbols: Status, relationships: Status })
(kind MatchOutcome ∷ { patterns: Status, confidence: Status })
(kind ApplicationOutcome ∷ { coherence: Status, perception: Status })
(kind SynthesisOutcome ∷ { patterns: Status, heuristics: Status })
(kind UpdateOutcome ∷ { library: Status, learning: Status })
(kind Status ∷ "captured" | "missing" | "unknown" | "populated" | "assigned" | "matched" | "maintained" | "considered" | "extracted" | "derived" | "enhanced")

// --- Formal Artifact Definition
(kind Artifact ∷ { id: STRING, symbols: [STRING], relationships: [STRING], content: STRING })

// --- Datum Constants
(datum ⟦advisory_threshold⟧ ∷ FLOAT = 0.7)
(datum ⟦pattern_library⟧ ∷ STRING = "spec/advisory/patterns/")
(datum ⟦knowledge_base⟧ ∷ STRING = "spec/advisory/knowledge/")
(datum ⟦symbol_registry⟧ ∷ [STRING] = ["kind", "maplet", "contract", "plan", "branch", "test", "cue", "datum"])
(datum ⟦pattern_approval_threshold⟧ ∷ FLOAT = 0.6)

// --- Core Advisory Maplets
(maplet extractContext ∷ Artifact → AdvisoryContext)
(maplet matchPatterns ∷ { context: AdvisoryContext, patterns: [AdvisoryPattern] } → [Advisory])
(maplet evaluateRelevance ∷ { advisory: Advisory, context: AdvisoryContext } → FLOAT)
(maplet applyGuidance ∷ { advisory: Advisory, target: STRING } → AdvisoryApplication)
(maplet synthesizeKnowledge ∷ [AdvisoryApplication] → AdvisoryKnowledge)
(maplet updatePatternLibrary ∷ { knowledge: AdvisoryKnowledge, library: [AdvisoryPattern] } → [AdvisoryPattern])
(maplet auditPatternMatches ∷ { knowledge: AdvisoryKnowledge, applications: [AdvisoryApplication] } → PatternAudit)
(maplet approveNewPatterns ∷ { audit: PatternAudit, threshold: FLOAT } → [AdvisoryPattern])

// --- Advisory Contracts with Formal Symbol Assertions
(contract extractContext
  ⊨ requires: artifact.symbols ≠ []
  ⊨ requires: all symbols in artifact.symbols are in symbol_registry
  ⊨ ensures: context.symbols ≠ []
  ⊨ ensures: context.relationships capture symbol dependencies)

(contract matchPatterns
  ⊨ requires: context.symbols ≠ []
  ⊨ requires: patterns ≠ []
  ⊨ ensures: matched advisories relate to context
  ⊨ ensures: confidence scores assigned)

(contract evaluateRelevance
  ⊨ requires: advisory.confidence > 0
  ⊨ requires: context.symbols ≠ []
  ⊨ ensures: relevance_score ≥ 0 and relevance_score ≤ 1
  ⊨ ensures: higher_relevance for better context_match)

(contract applyGuidance
  ⊨ requires: advisory.confidence > advisory_threshold
  ⊨ requires: target ≠ ""
  ⊨ ensures: result describes guidance_application
  ⊨ ensures: application preserves symbolic_integrity)

(contract synthesizeKnowledge
  ⊨ requires: applications ≠ []
  ⊨ ensures: knowledge captures application_patterns
  ⊨ ensures: heuristics derived from successful_applications)

(contract auditPatternMatches
  ⊨ requires: knowledge.patterns ≠ []
  ⊨ requires: applications ≠ []
  ⊨ ensures: audit categorizes patterns by success_rate
  ⊨ ensures: new_patterns identified from application_trends)

(contract approveNewPatterns
  ⊨ requires: audit.new_patterns ≠ []
  ⊨ requires: threshold > 0 and threshold ≤ 1
  ⊨ ensures: approved patterns meet confidence_threshold
  ⊨ ensures: pattern quality validated before approval)

// --- Advisory Guidance Plan
(plan provideAdvisoryGuidance
  § steps:
    - extractContext
    - matchPatterns
    - evaluateRelevance
    - applyGuidance
    - synthesizeKnowledge
    - updatePatternLibrary
)

// --- Pattern Evolution Plan
(plan evolveAdvisoryPatterns
  § steps:
    - synthesizeKnowledge
    - auditPatternMatches
    - approveNewPatterns
    - updatePatternLibrary
)

// --- Relevance Filtering Branch
(branch relevanceFiltering
  ⎇ when relevance_score > 0.8:
      → applyGuidance
    when relevance_score > 0.5:
      → conditionalGuidance
    when relevance_score > 0.2:
      → recordForLearning
    else:
      → discardAdvisory
)

// --- Advisory Type Routing
(branch advisoryTypeRouting
  ⎇ when advisory.type = "aesthetic":
      → applyAestheticGuidance
    when advisory.type = "semantic":
      → applySemanticGuidance
    when advisory.type = "contextual":
      → applyContextualGuidance
    when advisory.type = "experiential":
      → applyExperientialGuidance
    else:
      → applyGenericGuidance
)

// --- Domain-Specific Advisory Applications
(maplet applyAestheticGuidance ∷ { advisory: Advisory, target: STRING } → AdvisoryApplication)
(maplet applySemanticGuidance ∷ { advisory: Advisory, target: STRING } → AdvisoryApplication)
(maplet applyContextualGuidance ∷ { advisory: Advisory, target: STRING } → AdvisoryApplication)
(maplet applyExperientialGuidance ∷ { advisory: Advisory, target: STRING } → AdvisoryApplication)

// --- Advisory Contracts for Domain-Specific Applications
(contract applyAestheticGuidance
  ⊨ requires: advisory.type = "aesthetic"
  ⊨ requires: advisory.domain contains visual_elements
  ⊨ ensures: application considers human_perception
  ⊨ ensures: result maintains design_coherence)

(contract applySemanticGuidance
  ⊨ requires: advisory.type = "semantic"
  ⊨ requires: advisory.context contains meaning_relationships
  ⊨ ensures: application preserves semantic_integrity
  ⊨ ensures: result enhances conceptual_clarity)

// --- Default Advisory Behavior
(default continuous_learning: true)
(default pattern_evolution: true)
(default context_sensitivity: true)

// --- Advisory Tests with Proper Outcome Shapes
(test extract_meaningful_context expects: ExtractOutcome { symbols: "populated", relationships: "captured" })
(test match_relevant_patterns expects: MatchOutcome { patterns: "matched", confidence: "assigned" })
(test apply_aesthetic_guidance expects: ApplicationOutcome { coherence: "maintained", perception: "considered" })
(test synthesize_actionable_knowledge expects: SynthesisOutcome { patterns: "extracted", heuristics: "derived" })
(test update_pattern_library expects: UpdateOutcome { library: "enhanced", learning: "captured" })
(test audit_pattern_effectiveness expects: PatternAudit { successful_patterns: "identified", failed_patterns: "identified", new_patterns: "discovered" })
(test approve_quality_patterns expects: [AdvisoryPattern] { approved: "quality_validated", threshold: "met" })

// --- Advisory System Cues
(cue embed_domain_expertise
  ⊨ suggests: capture domain-specific advisory patterns from expert knowledge)

(cue contextual_advisory_weighting
  ⊨ suggests: weight advisory relevance based on current symbolic context)

(cue adaptive_guidance_strength
  ⊨ suggests: adjust advisory strength based on application success patterns)

(cue cross_domain_advisory_transfer
  ⊨ suggests: identify advisory patterns that transfer across domains)

(cue human_feedback_integration
  ⊨ suggests: incorporate human feedback to refine advisory pattern matching)