# Example SMARS Plan

@role(developer)

## Data Definitions

(datum ⟦default_timeout⟧ ∷ INT = 30)
(datum ⟦system_name⟧ ∷ STRING = "SMARS Agent")

## Type Definitions

(kind ExecutionResult ∷ {
  success: BOOL,
  message: STRING,
  timestamp: INT
})

(kind TaskContext ∷ {
  task_id: STRING,
  priority: INT,
  metadata: STRING
})

## Function Definitions

(maplet log_message ∷ STRING → ExecutionResult)
(maplet get_timestamp ∷ () → INT)
(maplet complete_cue ∷ Context → Cue → CompletedCue)
(maplet validate_inputs ∷ [STRING] → BOOL)

## Contracts

(contract execution_safety_contract ⊨
  requires: valid_inputs(input_data)
  requires: sufficient_resources(system_resources)
  ensures: no_data_corruption(output_data)
  ensures: execution_logged(execution_trace))

(contract cue_completion_contract ⊨
  requires: valid_cue_context(context)
  ensures: meaningful_completion(completed_cue)
  ensures: completion_traceable(completion_source))

## Plans

(plan simple_test_plan § steps:
  - apply log_message ▸ "Starting simple test"
  - apply get_timestamp
  - apply log_message ▸ "Test completed successfully")

(plan complex_workflow_plan § steps:
  - apply validate_inputs ▸ ["input1", "input2", "input3"]
  - apply log_message ▸ "Inputs validated"
  - apply complete_cue ▸ { context: "test_context", missing: ["pattern", "analysis"] }
  - apply log_message ▸ "Cue completion requested"
  - apply get_timestamp
  - apply log_message ▸ "Workflow completed")

(plan llm_integration_plan § steps:
  - apply log_message ▸ "Testing LLM integration"
  - apply complete_cue ▸ { 
      context: "performance_optimization", 
      missing: ["bottleneck_analysis", "optimization_suggestions"] 
    }
  - apply log_message ▸ "LLM integration test completed")

## Application Examples

(apply log_message ▸ "Direct maplet call")
(apply complete_cue ▸ { context: "error_recovery", cue: "incomplete_pattern" })

This specification demonstrates:
- Data definitions with symbolic notation
- Type definitions for structured data
- Function signatures for both local and LLM-based maplets
- Contracts with requirements and guarantees
- Plans with sequential steps and apply expressions
- Integration between local Rust execution and Swift LLM calls