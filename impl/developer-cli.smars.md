# Developer CLI Implementation

@role(nucleus)

Command-line interface for SMARS-based development workflow - bootstrapping, planning, execution, and validation.

## CLI Architecture

### Core Commands Structure
```
(∷ CLICommand {
  command_name: STRING,
  subcommands: [Subcommand],
  global_flags: [GlobalFlag],
  description: STRING
})

(∷ Subcommand {
  name: STRING,
  action: CLIAction,
  arguments: [Argument],
  flags: [Flag]
})
```

### Main CLI Entry Point
```
(§ smars_cli_main
  steps:
    - parse_command_arguments
    - validate_global_context
    - dispatch_to_subcommand
    - execute_command_action
    - output_results_and_exit
)
```

## Core Commands Implementation

### 1. Project Initialization (`smars init`)
```
(ƒ init_smars_project ∷ ProjectConfig → ProjectStructure)

(§ project_initialization
  steps:
    - create_directory_structure
    - generate_basic_smars_files
    - setup_registry_templates
    - create_sample_plans
    - generate_gitignore_and_docs
)

(∷ ProjectStructure {
  project_name: STRING,
  base_directory: STRING,
  spec_directory: STRING,
  impl_directory: STRING,
  registry_directory: STRING,
  artifact_directory: STRING
})

# CLI Usage:
# smars init my-product --type rust|swift|nodejs
# smars init my-product --minimal
# smars init my-product --with-examples
```

### 2. Plan Management (`smars plan`)
```
(ƒ create_plan ∷ PlanTemplate → PlanFile)
(ƒ validate_plan ∷ PlanFile → ValidationReport)
(ƒ list_plans ∷ ProjectContext → [PlanSummary])

(§ plan_management
  steps:
    - scan_existing_plans
    - validate_plan_syntax
    - check_dependency_resolution
    - generate_plan_reports
    - suggest_optimizations
)

# CLI Usage:
# smars plan init feature-name --template basic|workflow|validation
# smars plan validate path/to/plan.smars.md
# smars plan list --domain auth|data|ui
# smars plan deps feature-name --graph
```

### 3. Execution Loop (`smars exec`)
```
(ƒ execute_plan ∷ ExecutionRequest → ExecutionResult)
(ƒ loop_execution ∷ LoopConfig → ContinuousExecution)

(§ execution_management
  steps:
    - resolve_execution_context
    - initialize_runtime_environment
    - execute_plan_with_artifacts
    - collect_execution_feedback
    - emit_improvement_cues
)

(∷ ExecutionRequest {
  plan_file: STRING,
  plan_name: STRING,
  execution_mode: ExecutionMode,
  output_directory: STRING,
  validation_level: ValidationLevel
})

# CLI Usage:
# smars exec plan.smars.md --plan main_workflow
# smars exec plan.smars.md --plan main_workflow --artifacts ./out
# smars exec loop --spec plan.smars.md --continuous --watch
```

### 4. Audit and Validation (`smars audit`)
```
(ƒ audit_project ∷ ProjectPath → AuditReport)
(ƒ validate_registry ∷ RegistryPath → RegistryValidation)

(§ project_audit
  steps:
    - scan_project_structure
    - validate_all_specifications
    - check_registry_consistency
    - analyze_plan_dependencies
    - generate_health_report
)

(∷ AuditReport {
  project_health_score: FLOAT,
  specification_issues: [SpecificationIssue],
  registry_inconsistencies: [RegistryIssue],
  dependency_problems: [DependencyIssue],
  improvement_recommendations: [Recommendation]
})

# CLI Usage:
# smars audit --project ./
# smars audit --registry-only
# smars audit --fix-auto
# smars audit --report-format json|markdown|console
```

## Additional Developer Commands

### 5. Registry Management (`smars registry`)
```
(ƒ promote_to_registry ∷ PromotionCandidate → RegistryEntry)
(ƒ query_registry ∷ QueryCriteria → [RegistryResult])

(§ registry_management
  steps:
    - scan_promotion_candidates
    - calculate_promotion_scores
    - update_registry_entries
    - maintain_registry_consistency
    - generate_analytics_reports
)

# CLI Usage:
# smars registry promote plan-name --score 0.85
# smars registry query --domain auth --complexity low
# smars registry stats --format table
# smars registry clean --remove-unused
```

### 6. Development Workflow (`smars dev`)
```
(ƒ watch_and_reload ∷ WatchConfig → ContinuousProcess)
(ƒ generate_artifacts ∷ ArtifactRequest → [Artifact])

(§ development_workflow
  steps:
    - setup_file_watching
    - detect_specification_changes
    - auto_validate_changes
    - regenerate_affected_artifacts
    - notify_developer_of_status
)

# CLI Usage:
# smars dev watch --auto-validate
# smars dev generate --type code --target swift
# smars dev server --port 8080 --hot-reload
```

### 7. Integration and Export (`smars export`)
```
(ƒ export_to_framework ∷ ExportConfig → ExportedArtifacts)
(ƒ generate_documentation ∷ DocConfig → Documentation)

(§ integration_export
  steps:
    - analyze_export_requirements
    - generate_target_artifacts
    - create_integration_templates
    - validate_export_consistency
    - package_for_distribution
)

# CLI Usage:
# smars export --format openapi --output api.json
# smars export --format typescript --output ./types
# smars export docs --format gitbook --output ./docs
```

## CLI Implementation Architecture

### Command Parsing and Dispatch
```
(∷ CLIContext {
  working_directory: STRING,
  global_config: GlobalConfig,
  verbose_logging: BOOL,
  output_format: OutputFormat
})

(∷ GlobalConfig {
  smars_version: STRING,
  default_registry_path: STRING,
  default_artifact_path: STRING,
  foundation_models_enabled: BOOL
})

(ƒ parse_and_dispatch ∷ [STRING] → CLIResult)

(§ cli_execution_flow
  steps:
    - parse_global_flags
    - identify_primary_command
    - validate_command_arguments
    - establish_execution_context
    - execute_command_handler
    - format_and_output_results
)
```

### Error Handling and Help System
```
(∷ CLIError {
  error_type: CLIErrorType,
  error_message: STRING,
  suggested_fix: STRING,
  help_reference: STRING
})

(∷ CLIErrorType {
  category: STRING // "argument", "file", "validation", "execution"
})

(§ error_handling
  steps:
    - classify_error_type
    - generate_helpful_message
    - suggest_corrective_actions
    - display_relevant_help
    - exit_with_appropriate_code
)
```

## Feedback Integration

### Execution Feedback Collection
```
(ƒ collect_feedback ∷ ExecutionResult → FeedbackSummary)

(§ feedback_collection
  steps:
    - analyze_execution_metrics
    - assess_artifact_quality
    - measure_contract_compliance
    - detect_performance_patterns
    - identify_improvement_opportunities
)

(∷ FeedbackSummary {
  execution_success_rate: FLOAT,
  artifact_generation_quality: FLOAT,
  contract_compliance_score: FLOAT,
  performance_metrics: PerformanceMetrics,
  improvement_cues: [ImprovementCue]
})
```

### Diagnostic Plans Integration
```
(ƒ generate_diagnostic_plan ∷ FeedbackSummary → DiagnosticPlan)

(§ diagnostic_generation
  steps:
    - analyze_feedback_patterns
    - identify_spec_drift_indicators
    - detect_unexpected_deltas
    - generate_corrective_plans
    - emit_diagnostic_cues
)

(∷ DiagnosticPlan {
  diagnostic_id: STRING,
  target_issue: STRING,
  corrective_steps: [PlanStep],
  expected_outcome: STRING,
  validation_criteria: [ValidationCriterion]
})

# CLI Integration:
# smars exec plan.smars.md --plan main --with-diagnostics
# smars audit --generate-fixes --auto-apply
```

## Composable Product Integration

### Product Template Generation
```
(ƒ generate_product_template ∷ ProductConfig → ProductTemplate)

(§ product_template_generation
  steps:
    - create_base_project_structure
    - generate_domain_specific_plans
    - setup_registry_with_common_patterns
    - create_integration_examples
    - document_customization_points
)

(∷ ProductConfig {
  product_name: STRING,
  target_platform: Platform,
  domain_focus: [DomainArea],
  integration_requirements: [IntegrationRequirement]
})

# CLI Usage:
# smars init-product mobile-app --platform ios --domains auth,data,ui
# smars init-product web-service --platform rust --domains api,database,auth
# smars init-product desktop-tool --platform swift --minimal
```

### Plugin System Architecture
```
(∷ PluginConfiguration {
  plugin_name: STRING,
  plugin_type: PluginType,
  maplet_bindings: [MapletBinding],
  contract_requirements: [ContractRequirement]
})

(∷ PluginType {
  category: STRING // "tool", "generator", "validator", "integration"
})

(ƒ register_plugin ∷ PluginConfiguration → PluginRegistration)

(§ plugin_integration
  steps:
    - validate_plugin_compatibility
    - register_plugin_maplets
    - establish_contract_bindings
    - test_plugin_functionality
    - integrate_with_cli_commands
)

# CLI Usage:
# smars plugin install swift-codegen
# smars plugin list --active
# smars plugin configure llm-assistant --api-key xxx
```

## CLI Contract Validation

### CLI Behavior Contracts
```
(⊨ cli_reliability_contract
  requires: valid_command_syntax(command_args)
  ensures: deterministic_output(result)
  ensures: appropriate_exit_code(exit_code)
)

(⊨ cli_usability_contract
  requires: user_intent_expressible(command_structure)
  ensures: helpful_error_messages(error_responses)
  ensures: discoverable_functionality(help_system)
)

(⊨ cli_integration_contract
  requires: valid_project_structure(project_path)
  ensures: consistent_artifact_generation(artifacts)
  ensures: reliable_feedback_collection(feedback)
)
```

### Performance and Reliability
```
(§ cli_performance_optimization
  steps:
    - profile_command_execution_time
    - optimize_file_system_operations
    - cache_frequently_accessed_data
    - minimize_startup_overhead
    - provide_progress_indicators
)

(⊨ cli_performance_contract
  requires: reasonable_system_resources(system_state)
  ensures: responsive_command_execution(execution_time < 5000ms)
  ensures: clear_progress_feedback(progress_indicators)
)
```

This CLI implementation provides comprehensive developer tooling that closes the loop from symbolic intent through execution to feedback, making SMARS a practical development co-pilot and automation planner.