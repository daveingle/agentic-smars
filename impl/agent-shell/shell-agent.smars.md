# Shell Agent for SMARS Plan Invocation

@role(nucleus)

Interactive shell agent providing command-line interface for SMARS plan execution with full trace feedback and runtime integration.

## Shell Agent Types

### Shell Agent State
```
(∷ ShellAgentState {
  agent_id: UUID,
  current_context: ExecutionContext,
  command_history: [ShellCommand],
  active_executions: [UUID],
  environment_variables: {[STRING]: STRING},
  working_registry: RegistryViewContext
})
```

### Shell Command
```
(∷ ShellCommand {
  command_id: UUID,
  command_text: STRING,
  parsed_command: ParsedCommand,
  executed_at: INT,
  execution_envelope: AgentExecutionEnvelope,
  result_output: STRING
})
```

### Parsed Command
```
(∷ ParsedCommand {
  command_type: STRING,  // "execute_plan", "query_registry", "inspect_state", "load_spec"
  target: STRING,
  arguments: [STRING],
  flags: {[STRING]: STRING}
})
```

### Shell Response
```
(∷ ShellResponse {
  success: BOOL,
  output_text: STRING,
  execution_log: ExecutionLog,
  cues_generated: [Cue],
  promotion_candidates: [PromotionCandidate],
  next_suggestions: [STRING]
})
```

## Command Parsing Functions

### Command Parser
```
(ƒ parse_shell_command ∷ STRING → ParsedCommand)
(ƒ validate_command_syntax ∷ ParsedCommand → BOOL)
(ƒ resolve_command_target ∷ STRING → RegistryViewContext → UUID)
(ƒ prepare_command_arguments ∷ [STRING] → {[STRING]: Any})
```

### Command Types
```
(ƒ parse_execute_command ∷ STRING → ExecuteCommand)
(ƒ parse_query_command ∷ STRING → QueryCommand)
(ƒ parse_inspect_command ∷ STRING → InspectCommand)
(ƒ parse_load_command ∷ STRING → LoadCommand)
```

## Plan Execution Interface

### Plan Invocation Functions
```
(ƒ execute_plan_by_name ∷ STRING → [Any] → ShellAgentState → ShellResponse)
(ƒ execute_plan_by_uuid ∷ UUID → [Any] → ShellAgentState → ShellResponse)
(ƒ execute_plan_with_context ∷ PlanDef → ExecutionContext → ShellResponse)
```

### Execution Management
```
(ƒ start_plan_execution ∷ PlanDef → [Any] → ExecutionContext → UUID)
(ƒ monitor_execution_progress ∷ UUID → ExecutionStatus)
(ƒ cancel_execution ∷ UUID → ShellAgentState → ShellAgentState)
(ƒ get_execution_results ∷ UUID → ExecutionLog)
```

## Registry Integration

### Registry Query Interface
```
(ƒ query_promoted_plans ∷ PolymorphicQuery → ShellAgentState → [PromotedPlanRecord])
(ƒ search_registry_by_tag ∷ STRING → ShellAgentState → [UniversalRegistryEntry])
(ƒ inspect_promotion_lineage ∷ UUID → ShellAgentState → PromotionLineage)
```

### Registry Management
```
(ƒ reload_registry_context ∷ ShellAgentState → ShellAgentState)
(ƒ update_working_registry ∷ ExecutionLog → ShellAgentState → ShellAgentState)
(ƒ export_registry_snapshot ∷ STRING → ShellAgentState → BOOL)
```

## Shell Command Plans

### Main Shell Loop
```
(§ shell_agent_main_loop
  steps:
    - initialize_shell_state
    - load_registry_context
    - display_welcome_prompt
    - read_user_command
    - parse_and_validate_command
    - execute_command_handler
    - display_execution_results
    - update_shell_state
    - check_exit_condition
)
```

### Command Execution Handler
```
(§ execute_command_handler
  steps:
    - determine_command_type
    - validate_command_permissions
    - prepare_execution_context
    - invoke_appropriate_handler
    - capture_execution_results
    - generate_response_output
)
```

### Plan Execution Handler
```
(§ handle_execute_plan_command
  steps:
    - resolve_plan_identifier
    - validate_plan_arguments
    - create_execution_envelope
    - start_plan_execution
    - monitor_execution_progress
    - collect_execution_results
    - format_execution_output
)
```

### Registry Query Handler
```
(§ handle_registry_query_command
  steps:
    - parse_query_parameters
    - build_polymorphic_query
    - execute_registry_lookup
    - format_query_results
    - suggest_related_queries
)
```

## Shell Command Contracts

### Command Execution Contract
```
(⊨ command_execution_contract
  requires: valid_parsed_command(command)
  requires: authorized_execution(command, shell_state)
  ensures: execution_logged(execution_log)
  ensures: state_updated_consistently(shell_state)
)
```

### Plan Invocation Contract
```
(⊨ plan_invocation_contract
  requires: valid_plan_identifier(plan_id)
  requires: compatible_arguments(arguments)
  ensures: execution_envelope_created(envelope)
  ensures: trace_feedback_available(execution_log)
)
```

### Registry Access Contract
```
(⊨ registry_access_contract
  requires: valid_registry_context(registry_context)
  ensures: query_results_consistent(results)
  ensures: registry_state_preserved(registry_context)
)
```

## Interactive Features

### Command Completion
```
(∷ CommandCompletion {
  available_commands: [STRING],
  available_plans: [STRING],
  available_flags: [STRING],
  completion_suggestions: [STRING]
})
```

### Help System
```
(∷ HelpContent {
  command_descriptions: {[STRING]: STRING},
  usage_examples: [STRING],
  common_patterns: [STRING],
  troubleshooting_tips: [STRING]
})
```

### Interactive Functions
```
(ƒ get_command_completions ∷ STRING → ShellAgentState → [STRING])
(ƒ display_help ∷ STRING → HelpContent)
(ƒ show_execution_status ∷ UUID → ExecutionStatus)
(ƒ format_output_for_display ∷ Any → STRING)
```

## Built-in Shell Commands

### Core Commands
- `execute <plan_name> [args...]` - Execute a promoted plan with arguments
- `query <query_expression>` - Query the promotion registry
- `inspect <uuid>` - Inspect execution details or promotion lineage
- `load <spec_file>` - Load SMARS specification into working context
- `status` - Show current shell state and active executions
- `history` - Display command execution history
- `help [command]` - Show help for specific command or general usage

### Registry Commands
- `list plans` - Show all promoted plans
- `list kinds` - Show all promoted kinds
- `search <tag>` - Search registry entries by tag
- `lineage <uuid>` - Show promotion lineage for entry
- `health` - Display registry health diagnostics

### Execution Commands
- `ps` - Show active executions
- `kill <execution_id>` - Cancel running execution
- `logs <execution_id>` - Show detailed execution logs
- `trace <execution_id>` - Show execution trace with contract validation

## Error Handling and Recovery

### Shell Error Types
```
(∷ ShellError {
  error_code: STRING,
  error_message: STRING,
  command_context: ShellCommand,
  recovery_suggestions: [STRING],
  help_references: [STRING]
})
```

### Error Recovery Functions
```
(ƒ handle_command_error ∷ ShellError → ShellAgentState → ShellResponse)
(ƒ suggest_command_correction ∷ STRING → [STRING])
(ƒ recover_from_execution_failure ∷ UUID → ShellAgentState → ShellAgentState)
```

## Output Formatting

### Output Formatters
```
(ƒ format_execution_log ∷ ExecutionLog → STRING)
(ƒ format_registry_results ∷ [UniversalRegistryEntry] → STRING)
(ƒ format_promotion_lineage ∷ PromotionLineage → STRING)
(ƒ format_error_message ∷ ShellError → STRING)
```

### Display Utilities
```
(ƒ create_table_output ∷ [{[STRING]: STRING}] → STRING)
(ƒ create_tree_output ∷ PromotionLineage → STRING)
(ƒ colorize_output ∷ STRING → STRING → STRING)
(ƒ paginate_output ∷ STRING → INT → [STRING])
```

This shell agent provides:
- **Interactive Plan Execution**: Direct command-line access to SMARS plan execution
- **Real-time Feedback**: Live execution monitoring with detailed trace output
- **Registry Integration**: Complete access to promotion registry with query capabilities
- **Command History**: Full command history and execution tracking
- **Error Recovery**: Robust error handling with helpful suggestions
- **Rich Output Formatting**: Structured, readable output for complex data structures
- **Built-in Help**: Comprehensive help system and command completion