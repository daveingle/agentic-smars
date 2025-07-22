# Canonical Agent Loop

@role(nucleus)

The fundamental agentic execution cycle - the canonical pattern for autonomous symbolic agents.

## Core Agent Loop

```
(§ agent_loop
  steps:
    - perceive
    - reason
    - decide
    - act
)
```

## Loop Component Definitions

### Perception Phase
```
(∷ PerceptionState {
  sensory_input: SensoryData,
  context_state: ContextSnapshot,
  memory_retrieval: MemoryAccess,
  environmental_scan: EnvironmentState
})

(ƒ perceive ∷ Environment → PerceptionState)

(⊨ perception_contract
  requires: accessible_environment(environment)
  ensures: complete_perception_state(perception_state)
)
```

### Reasoning Phase
```
(∷ ReasoningState {
  situation_assessment: SituationModel,
  pattern_recognition: [RecognizedPattern],
  causal_analysis: CausalChain,
  uncertainty_assessment: UncertaintyMetrics
})

(ƒ reason ∷ PerceptionState → ReasoningState)

(⊨ reasoning_contract
  requires: valid_perception_input(perception_state)
  ensures: logically_sound_reasoning(reasoning_state)
)
```

### Decision Phase
```
(∷ DecisionState {
  available_actions: [ActionOption],
  action_evaluation: [ActionAssessment],
  selected_action: SelectedAction,
  confidence_level: FLOAT
})

(ƒ decide ∷ ReasoningState → DecisionState)

(⊨ decision_contract
  requires: sufficient_reasoning_basis(reasoning_state)
  ensures: executable_action_selected(selected_action)
)
```

### Action Phase
```
(∷ ActionState {
  executed_action: ExecutedAction,
  action_result: ActionResult,
  environment_impact: EnvironmentDelta,
  feedback_signals: [FeedbackSignal]
})

(ƒ act ∷ DecisionState → ActionState)

(⊨ action_contract
  requires: valid_action_decision(decision_state)
  ensures: environment_modified(action_result)
)
```

## Loop Continuity and State

### Loop State Management
```
(∷ AgentLoopState {
  loop_iteration: INT,
  accumulated_experience: ExperienceBuffer,
  persistent_memory: AgentMemory,
  goal_state: GoalStack,
  termination_condition: TerminationCriteria
})

(ƒ update_loop_state ∷ ActionState → AgentLoopState → AgentLoopState)

(⊨ state_continuity_contract
  requires: consistent_loop_state(current_state)
  ensures: evolved_loop_state(next_state)
)
```

### Loop Execution Control
```
(§ continuous_agent_execution
  steps:
    - initialize_agent_state
    - execute_agent_loop
    - update_loop_state
    - check_termination_conditions
    - continue_or_terminate
)

(⊨ continuous_execution_contract
  requires: initialized_agent_state(agent_state)
  ensures: goal_achieved_or_terminated_safely(final_state)
)
```

## Pattern Context Integration

### Agent Pattern Context
```
(∷ AgentPatternContext {
  context_id: STRING,
  loop_state: AgentLoopState,
  pattern_bindings: {IDENTIFIER: PatternInstance},
  communication_channels: [AgentChannel],
  shared_resources: [SharedResource]
})

(ƒ establish_agent_context ∷ AgentConfiguration → AgentPatternContext)

(§ context_integration
  steps:
    - create_pattern_context
    - bind_agent_loop
    - establish_communication_channels
    - initialize_shared_resources
    - activate_agent_runtime
)
```

### Multi-Agent Loop Coordination
```
(∷ MultiAgentCoordination {
  agent_instances: [AgentInstance],
  coordination_protocol: CoordinationProtocol,
  shared_context: SharedPatternContext,
  synchronization_points: [SyncPoint]
})

(ƒ coordinate_agent_loops ∷ [AgentInstance] → MultiAgentCoordination)

(§ multi_agent_execution
  steps:
    - initialize_agent_instances
    - establish_coordination_protocol
    - execute_coordinated_loops
    - maintain_shared_context
    - handle_agent_interactions
)
```

## Loop Variants and Specializations

### Reactive Agent Loop
```
(§ reactive_agent_loop
  steps:
    - wait_for_stimulus
    - perceive
    - react_immediately
    - update_reactive_state
)
```

### Deliberative Agent Loop
```
(§ deliberative_agent_loop
  steps:
    - perceive
    - plan_extensively
    - reason_about_consequences
    - decide_with_deliberation
    - execute_planned_action
)
```

### Learning Agent Loop
```
(§ learning_agent_loop
  steps:
    - perceive
    - reason
    - decide
    - act
    - evaluate_outcome
    - update_knowledge
    - adapt_behavior
)
```

## Loop Meta-Properties

### Loop Invariants
```
(⊨ agent_loop_invariants
  requires: well_formed_agent_state(state)
  ensures: loop_termination_guaranteed(execution)
  ensures: state_consistency_maintained(state_transitions)
  ensures: goal_progress_measurable(progress_metrics)
)
```

### Loop Performance Metrics
```
(∷ LoopPerformanceMetrics {
  cycles_per_second: FLOAT,
  decision_quality: FLOAT,
  goal_achievement_rate: FLOAT,
  resource_utilization: FLOAT,
  adaptation_effectiveness: FLOAT
})

(ƒ measure_loop_performance ∷ AgentLoopExecution → LoopPerformanceMetrics)
```

### Loop Debugging and Introspection
```
(§ loop_introspection
  steps:
    - capture_loop_trace
    - analyze_decision_patterns
    - identify_performance_bottlenecks
    - suggest_loop_optimizations
    - validate_optimization_effectiveness
)

(⊨ introspection_contract
  requires: complete_loop_execution_trace(trace)
  ensures: actionable_optimization_insights(insights)
)
```

## Integration with Protocol System

### Agent Loop as Pattern Server
```
(• ⟦canonical_agent_loop⟧ ∷ PatternServer = {
  pattern_id: "canonical_agent_loop",
  capabilities: ["autonomous_execution", "state_management", "goal_pursuit"],
  outbox: [],
  state: "ready"
})

(ƒ serve_agent_pattern ∷ AgentRequest → AgentInstance)

(§ agent_pattern_service
  steps:
    - receive_agent_instantiation_request
    - create_agent_loop_instance
    - bind_to_pattern_context
    - activate_continuous_execution
    - publish_agent_capabilities
)
```

This canonical agent loop provides the fundamental autonomous execution pattern that can be instantiated, specialized, and coordinated within our protocol-based SMARS system.