# CLI Dispatch Graph - Orchestrated Command Architecture

@role(nucleus)

Redesign of CLI from procedural commands to orchestrated dispatch graph where commands can invoke other commands based on plan requirements.

## Dispatch Graph Architecture

### Command Graph Model
```
(∷ CommandGraph {
  commands: [CommandNode],
  dependencies: [CommandDependency],
  orchestration_rules: [OrchestrationRule],
  execution_context: GlobalExecutionContext
})

(∷ CommandNode {
  command_name: STRING,
  command_implementation: CommandImplementation,
  dependencies: [STRING],
  post_execution_triggers: [PostExecutionTrigger],
  required_capabilities: [STRING]
})

(∷ CommandDependency {
  source_command: STRING,
  target_command: STRING,
  dependency_type: DependencyType, // "prerequisite", "post_hook", "conditional", "recovery"
  trigger_condition: TriggerCondition
})
```

### Orchestration Engine
```
(ƒ orchestrate_command_execution ∷ CommandRequest → OrchestrationResult)

(§ command_orchestration
  steps:
    - parse_initial_command_request
    - build_execution_dependency_graph
    - resolve_command_prerequisites
    - execute_primary_command
    - trigger_post_execution_hooks
    - handle_conditional_commands
    - aggregate_orchestration_results
)

(∷ OrchestrationResult {
  primary_command_result: CommandResult,
  triggered_commands: [TriggeredCommand],
  dependency_resolution: DependencyResolution,
  orchestration_trace: OrchestrationTrace
})
```

## Self-Orchestrating Commands

### Auto-Audit Integration
```
(∷ AutoAuditTrigger {
  trigger_condition: STRING, // "on_execution_error", "on_artifact_generation", "on_registry_update"
  audit_scope: AuditScope,
  audit_severity: STRING // "quick", "comprehensive", "deep"
})

# smars exec automatically calls smars audit when plans demand it
(• ⟦exec_with_auto_audit⟧ ∷ OrchestrationRule = {
  rule_name: "exec_triggers_audit",
  source_command: "exec",
  trigger_condition: {
    condition_type: "contract_violation_detected",
    severity_threshold: "error"
  },
  target_command: "audit",
  target_parameters: {
    audit_scope: "execution_context",
    auto_fix: true,
    report_format: "actionable"
  }
})
```

### Plan-Driven Command Orchestration
```
(§ plan_driven_orchestration
  steps:
    - analyze_plan_requirements
    - identify_required_cli_commands
    - build_command_execution_graph
    - execute_orchestrated_sequence
    - validate_orchestration_outcome
)

# Example: Plan specifies it needs validation and artifact generation
(∷ PlanRequiredCommands {
  primary_command: "exec",
  required_pre_commands: ["plan validate"],
  required_post_commands: ["audit --artifacts", "registry promote --if-successful"],
  conditional_commands: [
    {
      condition: "compilation_failed",
      command: "debug --compilation-errors --suggest-fixes"
    }
  ]
})
```

### Command Chaining Declarations
```
(ƒ declare_command_chain ∷ CommandChainSpec → CommandChain)

# Commands can declare their orchestration requirements in specifications
(• ⟦signup_flow_orchestration⟧ ∷ CommandChainSpec = {
  primary_command: "exec signup_flow.smars.md",
  orchestration_requirements: [
    {
      stage: "pre_execution",
      commands: ["plan validate signup_flow.smars.md", "audit --dependencies"],
      failure_behavior: "halt_execution"
    },
    {
      stage: "post_execution", 
      commands: ["audit --artifacts --auto-fix", "registry promote signup_flow --score-threshold 0.8"],
      failure_behavior: "warn_and_continue"
    },
    {
      stage: "on_error",
      commands: ["debug --trace-analysis", "generate-diagnostic-plan --error-context"],
      failure_behavior: "best_effort"
    }
  ]
})
```

## Dynamic Command Dispatch

### Capability-Driven Dispatch
```
(ƒ dispatch_by_capability ∷ CapabilityRequirement → [AvailableCommand])

(§ capability_dispatch
  steps:
    - analyze_capability_requirements
    - scan_available_commands
    - match_commands_to_capabilities
    - select_optimal_command_sequence
    - dispatch_with_monitoring
)

(∷ CapabilityRequirement {
  required_capabilities: [STRING],
  performance_requirements: PerformanceRequirement,
  reliability_requirements: ReliabilityRequirement,
  resource_constraints: ResourceConstraints
})

# Example: Plan needs code generation capability
# System automatically dispatches to available generators
(• ⟦code_generation_dispatch⟧ ∷ DispatchRule = {
  capability_pattern: "generate_swift_code",
  available_handlers: [
    {
      command: "generate --swift --template-based",
      capability_score: 0.7,
      speed: "fast",
      quality: "medium"
    },
    {
      command: "generate --swift --llm-assisted", 
      capability_score: 0.9,
      speed: "slow",
      quality: "high"
    }
  ],
  selection_strategy: "quality_over_speed"
})
```

### Context-Aware Command Selection
```
(ƒ select_contextual_command ∷ ExecutionContext → SelectedCommand)

(§ contextual_command_selection
  steps:
    - analyze_current_execution_context
    - evaluate_available_command_options
    - consider_performance_history
    - apply_selection_heuristics
    - validate_selection_appropriateness
)

(∷ ExecutionContext {
  current_working_directory: STRING,
  active_specifications: [SpecificationFile],
  previous_command_results: [CommandResult],
  available_resources: ResourceState,
  user_preferences: UserPreferences,
  project_configuration: ProjectConfiguration
})
```

## Command Composition and Pipelines

### Command Composition Framework
```
(ƒ compose_commands ∷ [CommandSpec] → ComposedCommand)

(§ command_composition
  steps:
    - validate_command_compatibility
    - establish_data_flow_connections
    - create_shared_execution_context
    - implement_error_propagation_strategy
    - optimize_execution_pipeline
)

# Example: Composed workflow for feature development
(• ⟦feature_development_pipeline⟧ ∷ ComposedCommand = {
  pipeline_name: "feature_development",
  stages: [
    {
      stage_name: "planning",
      commands: ["plan init feature-name --domain auth", "plan validate"],
      data_outputs: ["validated_plan"]
    },
    {
      stage_name: "implementation",
      commands: ["exec --plan main_workflow --artifacts", "audit --generated-code"],
      data_inputs: ["validated_plan"],
      data_outputs: ["generated_artifacts", "audit_report"]
    },
    {
      stage_name: "validation", 
      commands: ["test --integration", "registry promote --conditional"],
      data_inputs: ["generated_artifacts", "audit_report"],
      success_criteria: ["all_tests_pass", "audit_score > 0.8"]
    }
  ]
})
```

### Pipeline Error Handling
```
(∷ PipelineErrorHandling {
  error_propagation_strategy: ErrorPropagationStrategy,
  recovery_points: [RecoveryPoint],
  rollback_strategy: RollbackStrategy,
  notification_policy: NotificationPolicy
})

(• ⟦pipeline_error_recovery⟧ ∷ PipelineErrorHandling = {
  error_propagation_strategy: "fail_fast_with_recovery_points",
  recovery_points: [
    {
      stage: "after_planning",
      recovery_action: "retry_with_different_template"
    },
    {
      stage: "after_implementation",
      recovery_action: "fallback_to_manual_review"
    }
  ],
  rollback_strategy: "restore_to_last_successful_stage",
  notification_policy: "immediate_for_pipeline_failure"
})
```

## Orchestration Contracts

### Command Orchestration Contracts
```
(⊨ orchestration_completeness_contract
  requires: all_dependencies_resolvable(command_graph)
  ensures: execution_order_deterministic(execution_plan)
  ensures: no_circular_dependencies(dependency_graph)
)

(⊨ command_composability_contract
  requires: compatible_input_output_interfaces(command_sequence)
  ensures: data_flow_integrity_maintained(pipeline_execution)
  ensures: error_handling_complete(error_scenarios)
)

(⊨ dynamic_dispatch_contract
  requires: capability_requirements_expressible(requirements)
  ensures: optimal_command_selection(selection_result)
  ensures: fallback_strategies_available(fallback_options)
)
```

### Orchestration Performance Contracts
```
(⊨ orchestration_performance_contract
  requires: reasonable_command_graph_complexity(graph_size < 50)
  ensures: command_resolution_time(resolution_time < 100ms)
  ensures: orchestration_overhead(overhead < 5% of execution_time)
)
```

## Integration with Planning System

### Plan-Specified Orchestration
```
(∷ PlanOrchestrationDirectives {
  required_pre_commands: [CommandSpec],
  required_post_commands: [CommandSpec], 
  conditional_commands: [ConditionalCommand],
  orchestration_preferences: OrchestrationPreferences
})

# Plans can specify their orchestration requirements directly
(§ orchestration_aware_plan
  orchestration_directives: {
    required_pre_commands: [
      {command: "audit --dependencies", failure_behavior: "halt"}
    ],
    required_post_commands: [
      {command: "registry promote", condition: "execution_successful"}
    ]
  },
  steps:
    - validate_input
    - process_data
    - generate_output
)
```

### Self-Orchestrating Plans
```
(ƒ generate_orchestration_plan ∷ PlanDefinition → OrchestrationPlan)

(§ self_orchestrating_plan_generation
  steps:
    - analyze_plan_dependencies
    - identify_orchestration_requirements
    - generate_command_sequence
    - optimize_execution_order
    - validate_orchestration_completeness
)

(∷ OrchestrationPlan {
  plan_id: STRING,
  command_sequence: [ScheduledCommand],
  dependency_graph: CommandDependencyGraph,
  estimated_execution_time: INT,
  resource_requirements: ResourceRequirements
})
```

This dispatch graph architecture transforms the CLI from a collection of isolated commands into an intelligent orchestration system where commands can dynamically invoke other commands based on plan requirements, capability needs, and execution context.