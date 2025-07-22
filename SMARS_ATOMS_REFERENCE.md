# SMARS Atoms Reference Guide

## Overview

SMARS (Symbolic Multi-Agent Reasoning System) provides **14 atomic constructs** for expressing multi-agent reasoning systems with reality-grounded execution. These atoms are the fundamental building blocks for symbolic specifications that bridge formal reasoning with emergent agency.

---

## Foundation Atoms (7 Core Primitives)

### 1. `kind` - Data Structure Declarations

**Purpose**: Defines typed data structures with named fields, similar to structs or records in programming languages.

**Syntax**: `(kind IDENTIFIER ∷ type_expr)`

**Grammar Rule**: 
```ebnf
kind_decl = "(" "kind" IDENTIFIER "∷" type_expr ")" ;
```

**Text Representation**:
```smars
(kind User ∷ { name: STRING, email: STRING, age: INTEGER })
(kind UserList ∷ [User])
(kind APIResponse ∷ { status: INTEGER, data: [User], meta: { count: INTEGER } })
```

**Usage Examples**:
- **Simple Record**: `(kind Profile ∷ { username: STRING, verified: BOOL })`
- **Nested Structure**: `(kind Account ∷ { user: User, settings: { theme: STRING } })`
- **Collection Type**: `(kind MessageQueue ∷ [Message])`
- **Optional Type**: `(kind OptionalUser ∷ ?User)`

**Real-World Applications**:
- Database schema definitions
- API response structures
- Configuration objects
- Agent state representations

---

### 2. `datum` - Symbolic Constants

**Purpose**: Declares symbolic constants with explicit values, providing named constants for the system.

**Syntax**: `(datum ⟦IDENTIFIER⟧ ∷ TYPE = value)`

**Grammar Rule**:
```ebnf
datum_decl = "(" "datum" "⟦" IDENTIFIER "⟧" "∷" IDENTIFIER "=" literal ")" ;
```

**Text Representation**:
```smars
(datum ⟦max_users⟧ ∷ INTEGER = 1000)
(datum ⟦app_name⟧ ∷ STRING = "SMARS System")
(datum ⟦pi_approx⟧ ∷ FLOAT = 3.14159)
(datum ⟦debug_mode⟧ ∷ BOOL = true)
```

**Usage Examples**:
- **Configuration Constants**: `(datum ⟦api_timeout⟧ ∷ INTEGER = 5000)`
- **System Limits**: `(datum ⟦max_retries⟧ ∷ INTEGER = 3)`
- **Default Values**: `(datum ⟦default_theme⟧ ∷ STRING = "dark")`
- **Mathematical Constants**: `(datum ⟦euler_number⟧ ∷ FLOAT = 2.71828)`

**Real-World Applications**:
- Configuration management
- System boundaries and limits
- Default parameter values
- Mathematical/scientific constants

---

### 3. `maplet` - Function Type Declarations

**Purpose**: Declares function signatures with explicit domain and codomain types, similar to function prototypes.

**Syntax**: `(maplet IDENTIFIER ∷ domain_type → codomain_type)`

**Grammar Rule**:
```ebnf
maplet_decl = "(" "maplet" IDENTIFIER "∷" type_expr "→" type_expr ")" ;
```

**Text Representation**:
```smars
(maplet validate_email ∷ STRING → BOOL)
(maplet authenticate_user ∷ (STRING, STRING) → AuthResult)
(maplet process_payment ∷ PaymentData → PaymentResult)
(maplet map_transform ∷ (T → U, [T]) → [U])
```

**Usage Examples**:
- **Simple Predicate**: `(maplet is_valid_age ∷ INTEGER → BOOL)`
- **Data Transformation**: `(maplet serialize_user ∷ User → JSON)`
- **Multi-Parameter**: `(maplet create_account ∷ (STRING, STRING, STRING) → Account)`
- **Higher-Order**: `(maplet filter_list ∷ (T → BOOL, [T]) → [T])`

**Real-World Applications**:
- API endpoint definitions
- Data validation functions
- Business logic operations
- Utility and helper functions

---

### 4. `apply` - Function Applications

**Purpose**: Applies functions to arguments, representing function calls or invocations.

**Syntax**: `(apply IDENTIFIER ▸ expression)`

**Grammar Rule**:
```ebnf
apply_decl = "(" "apply" IDENTIFIER "▸" expr ")" ;
```

**Text Representation**:
```smars
(apply email_check ▸ validate_email("user@example.com"))
(apply user_auth ▸ authenticate_user("john_doe", "password123"))
(apply data_transform ▸ map_transform(serialize_user, user_list))
```

**Usage Examples**:
- **Simple Application**: `(apply age_validation ▸ is_valid_age(25))`
- **Complex Expression**: `(apply filtered_users ▸ filter_list(is_active, all_users))`
- **Chained Operations**: `(apply result ▸ process_data(validate_input(raw_data)))`

**Real-World Applications**:
- Function call representations
- Data pipeline steps
- Validation chains
- Processing workflows

---

### 5. `contract` - Behavioral Requirements

**Purpose**: Specifies behavioral contracts with preconditions (requires) and postconditions (ensures) using formal logic.

**Syntax**: `(contract IDENTIFIER requires/ensures clauses)`

**Grammar Rule**:
```ebnf
contract_decl = "(" "contract" IDENTIFIER { require_clause | ensure_clause } ")" ;
require_clause = "⊨" "requires:" condition ;
ensure_clause = "⊨" "ensures:" condition ;
```

**Text Representation**:
```smars
(contract user_registration
  ⊨ requires: valid_email(email)
  ⊨ requires: password_strength(password) > 5
  ⊨ ensures: user_exists(email)
  ⊨ ensures: account_created
)

(contract payment_processing
  ⊨ requires: account_balance >= amount
  ⊨ requires: valid_payment_method(method)
  ⊨ ensures: balance_updated
  ⊨ ensures: transaction_recorded
)
```

**Usage Examples**:
- **Data Validation**: `(contract email_validation ⊨ requires: email ≠ "" ⊨ ensures: valid_format(email))`
- **State Changes**: `(contract user_logout ⊨ requires: user_authenticated ⊨ ensures: session_terminated)`
- **Resource Management**: `(contract file_write ⊨ requires: file_writable ⊨ ensures: data_persisted)`

**Real-World Applications**:
- API contract specifications
- Business rule enforcement
- Security requirement definitions
- Quality assurance constraints

---

### 6. `plan` - Ordered Procedures

**Purpose**: Defines ordered sequences of steps with optional confidence metrics and uncertainty tracking.

**Syntax**: `(plan IDENTIFIER [confidence] [uncertainty_sources] § steps: step_list)`

**Grammar Rule**:
```ebnf
plan_decl = "(" "plan" IDENTIFIER
            [ "confidence:" FLOAT ]
            [ "uncertainty_sources:" string_list ]
            "§" "steps:" step_list ")" ;
```

**Text Representation**:
```smars
(plan user_registration
  confidence: 0.85
  uncertainty_sources: "email_uniqueness", "password_validation"
  § steps:
    - validate_email_format
    - check_email_uniqueness
    - hash_password
    - create_user_record
    - send_welcome_email
)

(plan deploy_application
  confidence: 0.92
  § steps:
    - run_tests
    - build_application
    - deploy_to_staging
    - validate_deployment
    - promote_to_production
)
```

**Usage Examples**:
- **Simple Workflow**: `(plan backup_data § steps: - compress_files - upload_to_cloud - verify_integrity)`
- **With Confidence**: `(plan ai_prediction confidence: 0.78 § steps: - preprocess_data - run_model - validate_output)`
- **Error-Prone Process**: `(plan network_sync uncertainty_sources: "connectivity", "data_consistency" § steps: - establish_connection - sync_data - verify_sync)`

**Real-World Applications**:
- Workflow automation
- Deployment procedures
- Business process modeling
- AI agent task planning

---

### 7. `branch` - Conditional Dispatch

**Purpose**: Implements conditional logic with multiple cases and optional else clause for decision-making.

**Syntax**: `(branch IDENTIFIER ⎇ when conditions → targets [else: → target])`

**Grammar Rule**:
```ebnf
branch_decl = "(" "branch" IDENTIFIER "⎇" branch_cases ")" ;
branch_cases = branch_case { branch_case } [ "else:" "→" IDENTIFIER ] ;
branch_case = "when" condition ":" "→" IDENTIFIER ;
```

**Text Representation**:
```smars
(branch user_authentication ⎇
  when credentials_missing: → request_login
  when credentials_invalid: → show_error
  when account_locked: → unlock_procedure
  else: → grant_access
)

(branch payment_validation ⎇
  when insufficient_funds: → request_payment_method
  when invalid_card: → card_validation_flow
  when fraud_detected: → security_review
  else: → process_payment
)
```

**Usage Examples**:
- **Status Handling**: `(branch request_status ⎇ when pending: → wait_for_completion when failed: → retry_request else: → return_result)`
- **Input Validation**: `(branch input_check ⎇ when empty_input: → request_input when invalid_format: → show_format_help else: → process_input)`
- **Error Routing**: `(branch error_handler ⎇ when network_error: → retry_connection when auth_error: → re_authenticate else: → log_unknown_error)`

**Real-World Applications**:
- State machine implementations
- Error handling logic
- Decision trees
- Conditional workflows

---

## LLM Integration Atoms (2 Specialized Constructs)

### 8. `default` - LLM Behavior Directives

**Purpose**: Provides default behavior instructions specifically for Language Learning Models (LLMs) or AI agents.

**Syntax**: `(default IDENTIFIER: value)`

**Grammar Rule**:
```ebnf
default_decl = "(" "default" IDENTIFIER ":" literal_or_identifier ")" ;
```

**Text Representation**:
```smars
(default error_handling: "provide helpful error messages with suggested solutions")
(default response_format: "JSON with status and data fields")
(default max_tokens: 150)
(default temperature: 0.7)
```

**Usage Examples**:
- **Response Guidelines**: `(default tone: "professional and helpful")`
- **Processing Limits**: `(default timeout: 30000)`
- **Fallback Behavior**: `(default unknown_query: "ask for clarification")`
- **Model Parameters**: `(default creativity_level: 0.8)`

**Real-World Applications**:
- AI agent configuration
- LLM parameter tuning
- Default response behaviors
- Fallback mechanisms

---

### 9. `test` - Behavioral Expectations

**Purpose**: Specifies expected outcomes for testing and validation, similar to unit test assertions.

**Syntax**: `(test IDENTIFIER expects: outcome)`

**Grammar Rule**:
```ebnf
test_decl = "(" "test" IDENTIFIER "expects:" outcome_expr ")" ;
outcome_expr = "raise" IDENTIFIER | IDENTIFIER ;
```

**Text Representation**:
```smars
(test valid_email_test expects: true)
(test invalid_email_test expects: raise InvalidEmailError)
(test user_creation_test expects: user_created)
(test empty_input_test expects: raise EmptyInputError)
```

**Usage Examples**:
- **Success Cases**: `(test successful_login expects: authentication_success)`
- **Error Cases**: `(test invalid_password expects: raise AuthenticationError)`
- **State Validation**: `(test user_logout expects: session_terminated)`
- **Data Validation**: `(test age_validation expects: raise InvalidAgeError)`

**Real-World Applications**:
- Unit testing specifications
- Contract validation
- Behavioral verification
- Quality assurance

---

## Multi-Agent Extension Atoms (4 Agency Constructs)

### 10. `agent` - Agent Identity and Capabilities

**Purpose**: Defines agent entities with capabilities, memory references, and confidence calibration for multi-agent systems.

**Syntax**: `(agent ⟦IDENTIFIER⟧ ∷ TYPE [capabilities] [memory] [confidence_calibration])`

**Grammar Rule**:
```ebnf
agent_decl = "(" "agent" "⟦" IDENTIFIER "⟧" "∷" type_expr
             [ "capabilities:" capability_list ]
             [ "memory:" memory_ref ]
             [ "confidence_calibration:" FLOAT ] ")" ;
```

**Text Representation**:
```smars
(agent ⟦email_validator⟧ ∷ ValidationAgent
  capabilities: "email_format_check", "domain_verification", "spam_detection"
  memory: email_validation_history
  confidence_calibration: 0.85
)

(agent ⟦task_planner⟧ ∷ PlanningAgent
  capabilities: "workflow_optimization", "resource_allocation"
  memory: planning_memory
  confidence_calibration: 0.90
)
```

**Usage Examples**:
- **Specialist Agent**: `(agent ⟦data_processor⟧ ∷ ProcessingAgent capabilities: "data_cleaning", "feature_extraction")`
- **Learning Agent**: `(agent ⟦ml_trainer⟧ ∷ MLAgent memory: training_history confidence_calibration: 0.75)`
- **Coordinator Agent**: `(agent ⟦orchestrator⟧ ∷ CoordinatorAgent capabilities: "task_distribution", "result_aggregation")`

**Real-World Applications**:
- Multi-agent system design
- AI agent definition
- Capability-based routing
- Agent specialization

---

### 11. `memory` - Persistent State Structures

**Purpose**: Defines memory structures for agent persistence, state management, and learning.

**Syntax**: `(memory IDENTIFIER ∷ MEMORY_TYPE)`

**Grammar Rule**:
```ebnf
memory_decl = "(" "memory" IDENTIFIER "∷" memory_structure ")" ;
memory_structure = "MemoryEntry" | "ValidationMemory" | "AgentMemory" ;
```

**Text Representation**:
```smars
(memory user_interaction_history ∷ AgentMemory)
(memory validation_cache ∷ ValidationMemory)
(memory learning_data ∷ MemoryEntry)
```

**Usage Examples**:
- **Interaction History**: `(memory conversation_log ∷ AgentMemory)`
- **Validation Cache**: `(memory previous_validations ∷ ValidationMemory)`
- **Learning Buffer**: `(memory experience_replay ∷ MemoryEntry)`

**Real-World Applications**:
- Agent state persistence
- Learning system memory
- Validation caching
- Historical data storage

---

### 12. `confidence` - Uncertainty Metrics

**Purpose**: Provides first-class support for uncertainty quantification and confidence tracking in agent decisions.

**Syntax**: `(confidence IDENTIFIER ∷ CONFIDENCE_TYPE)`

**Grammar Rule**:
```ebnf
confidence_decl = "(" "confidence" IDENTIFIER "∷" confidence_structure ")" ;
confidence_structure = "ConfidenceAssessment" | "PlanWithConfidence" ;
```

**Text Representation**:
```smars
(confidence email_validation_confidence ∷ ConfidenceAssessment)
(confidence deployment_plan_confidence ∷ PlanWithConfidence)
(confidence prediction_uncertainty ∷ ConfidenceAssessment)
```

**Usage Examples**:
- **Decision Confidence**: `(confidence routing_decision ∷ ConfidenceAssessment)`
- **Plan Reliability**: `(confidence backup_procedure ∷ PlanWithConfidence)`
- **Prediction Quality**: `(confidence model_output ∷ ConfidenceAssessment)`

**Real-World Applications**:
- Uncertainty quantification
- Decision quality metrics
- Risk assessment
- Confidence-driven routing

---

### 13. `validation` - Inter-Agent Validation Protocols

**Purpose**: Enables structured validation requests and results between agents for collaborative verification.

**Syntax**: `(validation IDENTIFIER ∷ VALIDATION_TYPE)`

**Grammar Rule**:
```ebnf
validation_decl = "(" "validation" IDENTIFIER "∷" validation_structure ")" ;
validation_structure = "ValidationRequest" | "ValidationResult" | "ValidationFeedback" ;
```

**Text Representation**:
```smars
(validation peer_review_request ∷ ValidationRequest)
(validation quality_check_result ∷ ValidationResult)
(validation improvement_feedback ∷ ValidationFeedback)
```

**Usage Examples**:
- **Peer Review**: `(validation code_review ∷ ValidationRequest)`
- **Quality Assurance**: `(validation qa_result ∷ ValidationResult)`
- **Feedback Loop**: `(validation user_feedback ∷ ValidationFeedback)`

**Real-World Applications**:
- Peer review systems
- Quality assurance workflows
- Collaborative validation
- Multi-agent consensus

---

## Advisory Atom (1 Guidance Construct)

### 14. `cue` - Advisory Suggestions

**Purpose**: Provides non-binding advisory suggestions and guidance for system behavior and decision-making.

**Syntax**: `(cue IDENTIFIER ⊨ suggests: "suggestion_text")`

**Grammar Rule**:
```ebnf
cue_decl = "(" "cue" IDENTIFIER "⊨" "suggests:" STRING ")" ;
```

**Text Representation**:
```smars
(cue strategic_validation ⊨ suggests: "request validation when confidence < 0.7")
(cue performance_optimization ⊨ suggests: "cache frequent database queries")
(cue error_recovery ⊨ suggests: "implement exponential backoff for network retries")
(cue user_experience ⊨ suggests: "provide progress indicators for long operations")
```

**Usage Examples**:
- **Performance Hints**: `(cue caching_strategy ⊨ suggests: "use LRU cache for user sessions")`
- **Security Advice**: `(cue authentication ⊨ suggests: "require 2FA for admin accounts")`
- **Best Practices**: `(cue code_quality ⊨ suggests: "maintain test coverage above 80%")`
- **Operational Guidance**: `(cue monitoring ⊨ suggests: "alert on response times > 500ms")`

**Real-World Applications**:
- Best practice recommendations
- Performance optimization hints
- Security guidance
- Operational suggestions

---

## Special Operators and Symbols

### Core Symbols
- **`▸`** - Function application operator (used in `apply`)
- **`§`** - Plan step delimiter (used in `plan`)
- **`⎇`** - Conditional branching operator (used in `branch`)
- **`⊨`** - Contract entailment/requirement (used in `contract` and `cue`)
- **`⟦⟧`** - Datum value brackets (used in `datum` and `agent`)
- **`∷`** - Type annotation separator (used in all typed declarations)
- **`→`** - Function type arrows and branch targets

### Role Directive
- **`@role(...)`** - Role-scoping declaration (platform/developer/user)

---

## Complete Example Specification

```smars
@role(developer)

// Data structures
(kind User ∷ { name: STRING, email: STRING, verified: BOOL })
(kind AuthResult ∷ { success: BOOL, token: STRING, expires: INTEGER })

// Constants
(datum ⟦max_login_attempts⟧ ∷ INTEGER = 3)
(datum ⟦session_timeout⟧ ∷ INTEGER = 3600)

// Function signatures
(maplet validate_email ∷ STRING → BOOL)
(maplet authenticate_user ∷ (STRING, STRING) → AuthResult)

// Function applications
(apply email_check ▸ validate_email("user@example.com"))
(apply user_auth ▸ authenticate_user("john_doe", "password123"))

// Behavioral contracts
(contract user_authentication
  ⊨ requires: valid_email(email)
  ⊨ requires: password_strength(password) > 5
  ⊨ ensures: auth_result.success = true
  ⊨ ensures: session_created
)

// Ordered procedures
(plan login_workflow
  confidence: 0.88
  uncertainty_sources: "network_connectivity", "database_availability"
  § steps:
    - validate_credentials
    - check_account_status
    - create_session
    - log_access
)

// Conditional logic
(branch authentication_flow ⎇
  when credentials_missing: → request_credentials
  when too_many_attempts: → account_lockout
  when credentials_invalid: → login_failure
  else: → successful_login
)

// Multi-agent constructs
(agent ⟦auth_validator⟧ ∷ ValidationAgent
  capabilities: "credential_check", "session_management"
  memory: auth_history
  confidence_calibration: 0.85
)

(memory auth_history ∷ AgentMemory)
(confidence auth_confidence ∷ ConfidenceAssessment)
(validation peer_auth_check ∷ ValidationRequest)

// LLM directives
(default error_messages: "provide clear, actionable error descriptions")
(test invalid_email_test expects: raise InvalidEmailError)

// Advisory guidance
(cue security_best_practice ⊨ suggests: "implement rate limiting for login attempts")
```

This comprehensive reference provides the foundation for creating symbolic specifications in SMARS that bridge formal reasoning with multi-agent execution capabilities.