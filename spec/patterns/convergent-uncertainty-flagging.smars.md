# Convergent Uncertainty Flagging for Agentic Consensus

@role(platform)

## Core Problem Definition

When generally reliable sources converge on claims in domains where they are individually weak, this convergent uncertainty signals a need for deeper multi-agent investigation rather than automatic truth assignment.

(kind UncertainSource ∷ {
  source_id: SourceIdentifier, 
  general_reliability: ReliabilityScore,
  domain_strength: DomainStrengthMap,
  current_assessment: SourceAssessment
})

(kind ConvergentUncertaintyFlag ∷ {
  flagged_claim: Claim,
  convergent_sources: SourceSet,
  weak_domain: DomainIdentifier,
  flag_reason: FlagReason,
  consensus_requirement: ConsensusRequirement,
  preliminary_confidence: NeutralConfidence
})

(kind AgenticConsensusRequest ∷ {
  flagged_item: ConvergentUncertaintyFlag,
  deliberation_type: DeliberationType,
  required_agents: AgentSet,
  consensus_threshold: ConsensusThreshold,
  external_validation_needed: ExternalValidationRequirement
})

## Detection Criteria

(datum ⟦weak_domain_threshold⟧ ∷ DomainStrength = 0.3)
(datum ⟦general_reliability_threshold⟧ ∷ ReliabilityScore = 0.8)
(datum ⟦convergence_similarity_threshold⟧ ∷ SimilarityScore = 0.7)

## Flagging Decision Maplets

(maplet assess_convergent_uncertainty ∷ (SourceSet, Claim, Domain) → ConvergentUncertaintyFlag?)
(maplet detect_weak_domain_convergence ∷ (SourceAssessmentSet, DomainStrength) → WeakDomainConvergence?)
(maplet generate_consensus_request ∷ (ConvergentUncertaintyFlag) → AgenticConsensusRequest)
(maplet determine_deliberation_requirements ∷ (FlaggedClaim, SourceReliability) → DeliberationSpecification)

## Flagging Contracts

(contract convergent_uncertainty_detection
  ⊨ requires: multiple_generally_reliable_sources_with_weak_domain_strength
  ⊨ ensures: convergent_claims_flagged_for_consensus_not_auto_assigned_truth)

(contract consensus_flagging_threshold
  ⊨ requires: source_reliability_above_threshold_and_domain_strength_below_threshold
  ⊨ ensures: flag_generated_with_neutral_confidence_not_boosted_confidence)

(contract agentic_consensus_triggering
  ⊨ requires: convergent_uncertainty_flag_generated
  ⊨ ensures: multi_agent_deliberation_initiated_with_external_validation_option)

## Flagging Detection Plan

(plan detect_convergent_uncertainty_for_flagging
  confidence: 0.8
  uncertainty_sources: "source_reliability_assessment", "domain_strength_evaluation", "convergence_detection"
  § steps:
    - assess_individual_source_reliability_and_domain_strength
    - detect_claim_convergence_patterns_across_sources
    - identify_weak_domain_convergence_scenarios
    - evaluate_flagging_criteria_against_thresholds
    - generate_convergent_uncertainty_flag_with_neutral_confidence
    - create_agentic_consensus_request
    - route_to_multi_agent_deliberation_system)

(plan assess_individual_source_reliability_and_domain_strength
  confidence: 0.9
  § steps:
    - analyze_historical_accuracy_patterns_by_domain
    - evaluate_general_truthfulness_score_across_domains
    - map_source_expertise_to_specific_claim_domain
    - calculate_domain_strength_score_for_current_claim
    - determine_if_source_meets_reliability_threshold)

(plan detect_claim_convergence_patterns_across_sources
  confidence: 0.8
  § steps:
    - extract_semantic_content_from_source_assessments
    - calculate_claim_similarity_scores_between_sources
    - identify_agreement_patterns_in_weak_domains
    - distinguish_convergence_from_coincidental_similarity
    - evaluate_convergence_confidence_against_threshold)

## Convergent Uncertainty Flagging Logic

(branch convergent_uncertainty_flagging_decision
  ⎇ when sources_reliable_and_domain_weak_and_convergent:
      → generate_consensus_flag_with_neutral_confidence
    when sources_reliable_and_domain_strong_and_convergent:
      → proceed_with_standard_high_confidence_assessment
    when sources_unreliable_regardless_of_convergence:
      → apply_standard_low_confidence_skepticism
    when sources_divergent_in_weak_domain:
      → apply_standard_uncertainty_handling
    else:
      → defer_to_standard_truth_assessment_pipeline)

## Consensus Flag Generation

(apply assess_convergent_uncertainty ▸ {
  sources: [weak_domain_source_1, weak_domain_source_2], 
  claim: "technical_claim_outside_expertise", 
  domain: "specialized_technical_domain"
})

(apply detect_weak_domain_convergence ▸ {
  assessments: [similar_claim_assessment_1, similar_claim_assessment_2],
  domain_strength: 0.25
})

(apply generate_consensus_request ▸ {
  flag: convergent_uncertainty_flag_for_technical_claim
})

## Agentic Consensus Framework

(kind AgenticDeliberationProcess ∷ {
  flagged_claim: ConvergentUncertaintyFlag,
  participating_agents: AgentSet,
  deliberation_rounds: DeliberationRoundSet,
  consensus_building: ConsensusProcess,
  external_validation: ExternalValidationProcess,
  final_determination: ConsensusResult
})

(kind DeliberationRound ∷ {
  round_number: RoundIdentifier,
  agent_contributions: AgentContributionSet,
  evidence_presented: EvidenceSet,
  challenges_raised: ChallengeSet,
  convergence_assessment: ConvergenceEvaluation
})

(kind ConsensusResult ∷ {
  deliberation_outcome: DeliberationOutcome,
  confidence_level: CalibratedConfidence,
  supporting_evidence: ValidatedEvidenceSet,
  dissenting_views: DissentingViewSet,
  external_validation_results: ExternalValidationResultSet
})

## Multi-Agent Consensus Plans

(plan initiate_agentic_consensus_deliberation
  confidence: 0.85
  § steps:
    - assemble_domain_expert_agents_for_flagged_claim
    - present_convergent_uncertainty_evidence_to_agents
    - initiate_structured_deliberation_rounds
    - facilitate_evidence_sharing_between_agents
    - monitor_consensus_building_progress
    - trigger_external_validation_when_needed
    - synthesize_final_consensus_determination)

(plan structured_multi_agent_deliberation
  confidence: 0.8
  § steps:
    - round_1_independent_agent_assessments
    - round_2_evidence_sharing_and_challenge_phase
    - round_3_consensus_building_and_validation
    - external_validation_if_consensus_uncertain
    - final_determination_with_calibrated_confidence)

## External Validation Integration

(contract external_validation_triggering
  ⊨ requires: agentic_consensus_remains_uncertain_after_deliberation
  ⊨ ensures: authoritative_external_sources_consulted_for_final_determination)

(plan trigger_external_validation_for_consensus
  confidence: 0.9
  § steps:
    - identify_authoritative_sources_for_flagged_domain
    - query_external_databases_and_expert_systems
    - request_human_expert_consultation_if_available
    - cross_reference_multiple_validation_sources
    - integrate_external_validation_into_consensus_result)

## Confidence Calibration for Flagged Items

(maplet calibrate_consensus_confidence ∷ (ConsensusResult, ExternalValidationResult) → CalibratedTruthAssessment)

```swift
func calibrateConsensusConfidence(
    consensusResult: ConsensusResult,
    externalValidation: ExternalValidationResult,
    agentAgreement: Double,
    externalConfirmation: Bool
) -> CalibratedTruthAssessment {
    
    var finalConfidence = 0.5  // Start neutral for flagged items
    
    // Agent consensus factor (modest boost)
    if agentAgreement > 0.8 {
        finalConfidence += 0.2
    } else if agentAgreement > 0.6 {
        finalConfidence += 0.1
    }
    
    // External validation factor (significant)
    if externalConfirmation {
        finalConfidence += 0.3
    } else {
        finalConfidence -= 0.2
    }
    
    // Quality of deliberation factor
    let deliberationQuality = assessDeliberationQuality(consensusResult)
    finalConfidence += deliberationQuality * 0.1
    
    return CalibratedTruthAssessment(
        confidence: min(0.9, max(0.1, finalConfidence)),
        consensusBased: true,
        externallyValidated: externalConfirmation,
        flaggedForUncertainty: true
    )
}
```

## Memory for Convergent Uncertainty Flagging

(memory convergent_uncertainty_state ∷ AgentMemory)
- flagged_claims: FlaggedClaimHistory
- consensus_deliberations: DeliberationHistory
- external_validation_results: ValidationResultHistory
- agent_reliability_by_domain: AgentDomainReliabilityMatrix
- flagging_accuracy_calibration: FlaggingAccuracyMetrics

## Validation Tests

(test weak_domain_convergence_flagging
  expects: convergent_claims_in_weak_domains_flagged_for_consensus_not_auto_boosted)

(test neutral_confidence_assignment_for_flagged_items
  expects: flagged_convergent_uncertainty_assigned_neutral_confidence_around_0_5)

(test agentic_consensus_triggering
  expects: multi_agent_deliberation_initiated_for_flagged_convergent_uncertainty)

(test external_validation_integration
  expects: external_sources_consulted_when_agentic_consensus_remains_uncertain)

(test calibrated_final_confidence
  expects: final_truth_assessment_properly_calibrated_based_on_consensus_and_validation)

## Default Behaviors

(default convergent_uncertainty_handling: "When generally reliable sources converge in weak domains, flag for agentic consensus rather than boosting confidence")

(default consensus_confidence_assignment: "Assign neutral confidence (~0.5) to flagged items until consensus deliberation and external validation complete")

(default multi_agent_deliberation_triggering: "Initiate structured multi-agent deliberation for all convergent uncertainty flags")

(default external_validation_requirement: "Require external validation when agentic consensus remains uncertain after deliberation")

## Critical Implementation Cues

(cue convergent_uncertainty_as_signal_not_truth ⊨ suggests: "Convergent uncertainty signals need for investigation, not automatic truth assignment")

(cue neutral_confidence_for_flagged_items ⊨ suggests: "Flagged convergent uncertainty should start with neutral confidence, not boosted confidence")

(cue agentic_consensus_required ⊨ suggests: "Multi-agent deliberation essential for resolving convergent uncertainty in weak domains")

(cue external_validation_integration ⊨ suggests: "External validation critical when agentic consensus cannot resolve uncertainty")

(cue calibrated_confidence_final_output ⊨ suggests: "Final confidence must be calibrated based on consensus quality and external validation")