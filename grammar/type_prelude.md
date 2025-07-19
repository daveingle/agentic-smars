# SMARS Type Prelude and Semantic Rules

## Type System Foundation

The SMARS type system provides a symbolic foundation for multi-agent reasoning with built-in support for uncertainty, validation, and behavioral contracts.

### Core Types

#### Primitive Types
```smars
(kind Boolean)
(kind Number) 
(kind String)
(kind Identifier)
(kind Unit)
```

#### Composite Types
```smars
(kind List element_type: T)
(kind Map key_type: K value_type: V)
(kind Tuple fields: T1, T2, ..., Tn)
(kind Optional wrapped_type: T)
(kind Result success_type: T error_type: E)
```

#### Agent Types
```smars
(kind Agent capabilities: List<String> memory: Optional<Memory>)
(kind Memory capacity: Number persistence: PersistenceType)
(kind Confidence level: Number ∷ [0.0, 1.0])
```

### Type Annotations

#### Function Types
```smars
(maplet function_name ∷ domain_type → codomain_type)
(maplet binary_op ∷ (T, T) → T)
(maplet predicate ∷ T → Boolean)
```

#### Parametric Types
```smars
(kind Container element_type: T)
(maplet map ∷ (T → U, List<T>) → List<U>)
(maplet filter ∷ (T → Boolean, List<T>) → List<T>)
```

## Semantic Rules

### Declaration Ordering Rules

1. **Kind-First Principle**: All `kind` declarations must precede their usage
2. **Datum Dependency**: `datum` declarations may reference previously declared kinds
3. **Contract Precedence**: `contract` declarations should precede `plan` declarations that reference them
4. **Agent Specification**: `agent` declarations may reference `memory` and `confidence` declarations

### Cardinality Constraints

#### Plan Declarations
- **Steps**: 1-20 steps maximum
- **Uncertainty Sources**: 0-5 sources maximum
- **Confidence**: Single value in range [0.0, 1.0]

#### Contract Declarations
- **Requires Clauses**: 0-10 maximum
- **Ensures Clauses**: 0-10 maximum
- **Logical Operators**: ∧, ∨, ¬, →, ↔

#### Branch Declarations
- **Branch Cases**: 2-10 cases (minimum 2 for meaningful branching)
- **Actions per Case**: 1-5 actions maximum
- **Condition Complexity**: Nested depth ≤ 3

#### Agent Declarations
- **Capabilities**: 0-10 capabilities maximum
- **Memory References**: 0-3 memory instances maximum
- **Confidence Calibration**: Single value in range [0.0, 1.0]

### Validation Rules

#### Identifier Rules
- **Format**: `[a-zA-Z_][a-zA-Z0-9_]*`
- **Reserved Words**: Cannot use SMARS keywords as identifiers
- **Scope**: Identifiers must be unique within their declaration scope
- **Unicode Support**: Extended Unicode characters allowed for internationalization

#### Value Constraints
- **Confidence Values**: Must be in range [0.0, 1.0]
- **Memory Capacity**: Positive integers or "unlimited"
- **TTL Values**: Positive durations (seconds, minutes, hours, days)
- **Priority Levels**: "low", "medium", "high", "critical"

#### Reference Integrity
- **Forward References**: Not allowed - declarations must precede usage
- **Circular Dependencies**: Detected and rejected
- **Type Consistency**: All type annotations must resolve to declared kinds

### Metadata Semantics

#### Confidence Metadata
```smars
confidence: 0.85                    # Direct confidence value
uncertainty_sources: "sensor", "model"  # Sources of uncertainty
calibration: "platt_scaling"        # Calibration method
```

#### Memory Metadata
```smars
capacity: 1000_items               # Memory capacity
persistence: "volatile" | "permanent" | "temporary"
retention_policy: "lru" | "fifo" | "priority"
ttl: 3600s                        # Time-to-live for temporary memory
```

#### Performance Metadata
```smars
complexity: O(n*log(n))           # Algorithmic complexity
timeout: 5000ms                   # Operation timeout
retry_count: 3                    # Retry attempts
```

## Contract Logic

### Precondition-Postcondition Semantics

#### Requires Clauses
- **Interpretation**: Conditions that must hold before operation execution
- **Evaluation**: Logical AND of all requires clauses
- **Failure Handling**: Contract violation if any requires clause fails

#### Ensures Clauses  
- **Interpretation**: Conditions guaranteed to hold after successful execution
- **Evaluation**: Logical AND of all ensures clauses
- **Verification**: Post-execution validation of ensures clauses

### Logical Operators

#### Binary Operators
- `∧` (AND): Logical conjunction
- `∨` (OR): Logical disjunction  
- `→` (IMPLIES): Logical implication
- `↔` (IFF): Logical biconditional

#### Unary Operators
- `¬` (NOT): Logical negation

#### Comparison Operators
- `=`, `≠`: Equality and inequality
- `<`, `≤`, `>`, `≥`: Ordering comparisons
- `∈`, `∉`: Set membership

### Quantifiers
- `∀` (FORALL): Universal quantification
- `∃` (EXISTS): Existential quantification

## Plan Execution Semantics

### Step Sequencing
- **Sequential**: Steps execute in declared order by default
- **Conditional**: `if-then-else` constructs for branching
- **Parallel**: `parallel: {step1, step2, step3}` for concurrent execution
- **Loops**: `while condition: step` for iteration

### Error Handling
- **Precondition Failures**: Plan execution halts
- **Step Failures**: Error propagation or recovery based on plan specification
- **Postcondition Violations**: Contract enforcement triggers

### Plan Metadata
- **Confidence**: Overall plan success probability
- **Uncertainty Sources**: Factors affecting plan reliability
- **Preconditions**: Required state before plan execution
- **Postconditions**: Guaranteed state after successful completion

## Agent Interaction Semantics

### Agent Capabilities
- **Capability Matching**: Agent selection based on required capabilities
- **Capability Composition**: Complex tasks requiring multiple capabilities
- **Capability Evolution**: Dynamic capability acquisition and refinement

### Memory Sharing
- **Access Control**: Read-only, read-write, or write-only access
- **Synchronization**: Concurrent access coordination
- **Consistency**: Memory state consistency across agents
- **Privacy**: Agent-specific vs. shared memory partitions

### Communication Protocols
- **Message Passing**: Asynchronous communication between agents
- **Contract Negotiation**: Dynamic contract establishment
- **Coordination Patterns**: Leader-follower, peer-to-peer, hierarchical

## Validation Framework

### Static Analysis
- **Type Checking**: All type annotations must be valid
- **Reference Resolution**: All identifiers must resolve to declarations
- **Constraint Satisfaction**: All cardinality and value constraints must be satisfied
- **Contract Consistency**: Requires and ensures clauses must be logically consistent

### Dynamic Validation
- **Runtime Checking**: Contract verification during execution
- **Performance Monitoring**: Timeout and resource usage validation
- **Confidence Tracking**: Uncertainty propagation through operations
- **Error Recovery**: Graceful handling of validation failures

### Compliance Checking
- **Grammar Conformance**: All declarations must match EBNF specification
- **Semantic Consistency**: Cross-references must be semantically valid
- **Best Practices**: Adherence to SMARS style guidelines
- **Evolution Compatibility**: Forward compatibility with language evolution

This type prelude and semantic rules specification provides the foundation for Phase 6 implementation and future SMARS language development.