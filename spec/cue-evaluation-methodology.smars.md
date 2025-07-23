@role(platform)

# Cue Evaluation Methodology
# Generated from: cues/cue-evaluation-methodology.md  
# REQ-NNN: Systematic cue management system

kind CueEvaluation = {
  cue_id: String,
  technical_feasibility: Float,
  system_alignment: Float,
  implementation_complexity: Float,
  value_proposition: Float,
  combined_score: Float,
  promotion_recommended: Boolean
}

kind CueReport = {
  report_id: String,
  evaluation_date: String,
  evaluated_cues: List[CueEvaluation],
  promotion_candidates: List[String],
  archive_candidates: List[String]
}

maplet scanCueFiles ∷ String → List[String]
maplet evaluateCue ∷ String → CueEvaluation  
maplet generateCueReport ∷ List[CueEvaluation] → CueReport
maplet promoteCueToSpec ∷ String → String

contract SystematicCueManagement ⊨ requires:
  - Regular scanning of all cue files with format validation
  - Multi-criteria evaluation using standardized framework
  - Clear promotion thresholds with documented rationale
  ⊨ ensures:
  - Consistent evaluation across all cues
  - Audit trail for promotion decisions
  - Trending analysis for system evolution

plan executeCueEvaluationCycle § steps:
  1. scanAllCueFiles ▸ identifyEvaluationCandidates
  2. validateCueFormat ▸ ensureStructuralCompliance
  3. performMultiCriteriaEvaluation ▸ scoreTechnicalFeasibility
  4. generateEvaluationReport ▸ documentDecisionRationale
  5. promoteQualifiedCues ▸ createFormalSpecifications

test CueEvaluationConsistency = {
  given: Same cue evaluated multiple times
  when: Evaluation methodology applied
  then: Scores should be within acceptable variance
}

artifact CueManagementSystem = {
  format: "Automated cue evaluation framework",
  required_components: ["cue_scanner", "evaluation_engine", "promotion_system"],
  validation: "Systematic cue processing operational"
}