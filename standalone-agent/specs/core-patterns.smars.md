# SMARS Core Patterns

@role(nucleus)

Core patterns for SMARS planning and execution, extracted from the main implementation.

## Planning Patterns

(kind PlanningRequest {
  request_id: STRING,
  user_prompt: STRING,
  context: STRING,
  requirements: [STRING]
})

(kind GeneratedPlan {
  plan_id: STRING,
  smars_specification: STRING,
  validation_status: ValidationStatus,
  estimated_complexity: FLOAT
})

(plan generate_plan_from_prompt
  § steps:
    - parse_user_intent_from_natural_language
    - identify_required_capabilities_and_resources
    - generate_smars_specification_structure
    - validate_generated_plan_against_baseline
    - return_validated_plan_or_request_clarification
)

## Execution Patterns

(kind ExecutionContext {
  execution_id: STRING,
  plan_specification: STRING,
  user_inputs: [UserInput],
  agent_coordination: AgentCoordination
})

(plan execute_plan_deterministically
  § steps:
    - validate_plan_prerequisites_and_contracts
    - initialize_execution_context_with_seed
    - execute_plan_steps_sequentially
    - collect_mandatory_feedback_at_each_step
    - validate_artifacts_against_reality
    - return_execution_results_with_confidence
)

## Multi-Agent Coordination Patterns

(kind AgentNetwork {
  agents: [Agent],
  coordination_protocols: [CoordinationProtocol],
  consensus_mechanisms: [ConsensusMechanism]
})

(plan coordinate_multi_agent_execution
  § steps:
    - identify_required_agent_capabilities
    - select_appropriate_agents_from_network
    - establish_communication_channels
    - coordinate_agent_responses_and_recommendations
    - attempt_consensus_building
    - escalate_to_user_if_consensus_fails
)

## Reality Grounding Patterns

(contract reality_grounding_contract
  requires: execution_produces_concrete_artifacts
  requires: artifacts_existence_verifiable
  ensures: no_symbolic_hallucination_occurs
  ensures: confidence_bounds_properly_maintained
)

(plan validate_reality_grounding
  § steps:
    - verify_physical_artifact_existence
    - validate_artifact_meets_specifications
    - check_confidence_bounds_enforcement
    - test_hallucination_prevention_mechanisms
    - report_reality_alignment_status
)