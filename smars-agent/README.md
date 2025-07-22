# SMARS Agent - Cross-Runtime Symbolic Execution

A cross-runtime SMARS (Symbolic Multi-Agent Reasoning System) agent that combines Rust's deterministic execution with Swift's FoundationModels integration for LLM-powered symbolic reasoning.

## Architecture

```
┌─────────────────┐    JSON/Subprocess    ┌──────────────────────┐
│   Rust CLI      │ ──────────────────── │  Swift LLM Agent    │
│                 │                       │                      │
│ • Parse SMARS   │                       │ • FoundationModels  │
│ • Execute Plans │                       │ • Cue Completion    │
│ • Validate ⊨    │                       │ • Contract LLM      │
│ • Route ƒ calls │                       │ • Pattern Analysis  │
└─────────────────┘                       └──────────────────────┘
```

## Features

### 🦀 Rust Core Agent
- **SMARS Parser**: Extracts symbolic constructs from `.smars.md` files using pulldown-cmark and nom
- **Plan Executor**: Executes `§` plans with step-by-step validation and tracing
- **Maplet Dispatcher**: Routes `ƒ` maplet calls to local implementations or Swift subprocess
- **Contract Validator**: Validates `⊨` contracts with requirement/ensure checking
- **CLI Interface**: Clean command-line interface with clap for specification loading and execution

### 🍎 Swift LLM Bridge
- **FoundationModels Integration**: Native Apple FoundationModels API for LLM capabilities
- **Subprocess Protocol**: JSON-based communication protocol between Rust and Swift
- **Fallback Implementations**: Works with and without FoundationModels availability
- **Cue Completion**: LLM-powered completion of incomplete symbolic cues
- **Contract LLM Validation**: Advanced contract validation using natural language reasoning

## Usage

### Basic Plan Execution

```bash
# Build the Rust agent
cd smars-agent
cargo build --release

# List available plans in a specification
./target/release/smars-agent --spec test-plans/example-plan.smars.md

# Execute a specific plan
./target/release/smars-agent --spec test-plans/example-plan.smars.md --plan simple_test_plan

# Enable verbose logging
./target/release/smars-agent --spec test-plans/example-plan.smars.md --plan complex_workflow_plan --verbose
```

### With FoundationModels Integration

```bash
# Compile Swift agent (requires macOS with FoundationModels)
cd swift-agent
swiftc -o swift-foundationmodels-agent main.swift

# Run with LLM integration enabled
./target/release/smars-agent --spec test-plans/example-plan.smars.md --plan llm_integration_plan --foundation-models
```

## SMARS Language Support

### Supported Constructs

- **`§ plans`**: Sequential step execution with tracing
- **`ƒ maplets`**: Function definitions with local/remote routing
- **`⊨ contracts`**: Requirement/guarantee validation
- **`• datum`**: Symbolic constants with typed values
- **`∷ kinds`**: Structured type definitions
- **`apply ▸`**: Function application expressions

### Example SMARS Specification

```smars
(• ⟦timeout⟧ config ∷ INT = 30)

(∷ Result { success: BOOL, message: STRING })

(ƒ complete_cue ∷ Context → Cue → CompletedCue)

(⊨ safety_contract
  requires: valid_inputs(data)
  ensures: safe_execution(result)
)

(§ example_plan
  steps:
    - apply log_message ▸ "Starting execution"
    - apply complete_cue ▸ { context: "optimization", missing: ["analysis"] }
    - apply log_message ▸ "Execution completed"
)
```

## Built-in Maplets

### Local Maplets (Rust)
- `log(message: STRING)` - Logs messages with timestamps
- `concat(strings: [STRING])` - Concatenates string arrays
- `get_timestamp()` - Returns current Unix timestamp

### Remote Maplets (Swift + LLM)
- `complete_cue(context: Context, missing: [STRING])` - LLM-powered cue completion
- `generate_plan(goal: STRING, context: Context)` - Generates execution plans
- `analyze_pattern(data: Data, pattern: STRING)` - Pattern analysis and insights

## Directory Structure

```
smars-agent/
├── src/
│   ├── main.rs              # CLI entry point and orchestration
│   ├── parser.rs            # SMARS AST parser with nom combinators
│   ├── executor.rs          # Plan execution engine with maplet dispatch
│   └── bridge/
│       ├── mod.rs
│       └── foundation_bridge.rs  # Swift subprocess integration
├── swift-agent/
│   └── main.swift          # FoundationModels LLM agent
├── test-plans/
│   └── example-plan.smars.md    # Example SMARS specifications
└── README.md
```

## Development

### Prerequisites
- Rust 1.70+ with Cargo
- Swift 6.0+ (for LLM integration)
- macOS 15+ (for FoundationModels)

### Building

```bash
# Rust agent
cargo build --release

# Swift agent (macOS only)
cd swift-agent
swiftc -o swift-foundationmodels-agent main.swift
```

### Testing

```bash
# Run Rust tests
cargo test

# Test basic functionality
./target/release/smars-agent --spec test-plans/example-plan.smars.md --plan simple_test_plan --verbose

# Test LLM integration (requires Swift agent)
./target/release/smars-agent --spec test-plans/example-plan.smars.md --plan llm_integration_plan --foundation-models --verbose
```

## Benefits

- **🔬 Deterministic Core**: Rust provides reliable, fast symbolic execution
- **🧠 LLM Integration**: Swift FoundationModels enables intelligent cue completion
- **📝 Self-Describing**: SMARS specifications are human-readable and executable
- **🔗 Cross-Runtime**: Combines strengths of both Rust and Swift ecosystems
- **🎯 Composable**: Modular maplet system allows extensible functionality
- **📊 Traceable**: Complete execution tracing and contract validation

This creates a powerful symbolic reasoning system that bridges deterministic execution with emergent AI capabilities.