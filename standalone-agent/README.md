# SMARS Standalone Agent

A self-contained SMARS (Symbolic Multi-Agent Reasoning System) agent that leverages existing specifications and implementations for planning and execution.

## Features

- **Planning Cycle**: Takes natural language prompts and converts them to SMARS specifications
- **Multi-Agent Coordination**: Spawns and coordinates multiple agents for complex tasks
- **Reality Grounding**: Ensures all operations are grounded in reality with artifact validation
- **User Interaction**: Interactive stdio interface for user input and decision making
- **Session Management**: Save and restore planning sessions

## Usage

### Basic Planning
```bash
cargo run -- --prompt "Create a simple web application with user authentication"
```

### Multi-Agent Mode
```bash
cargo run -- --prompt "Analyze and optimize database performance" --multi-agent
```

### Verbose Mode
```bash
cargo run -- --prompt "Research machine learning trends" --verbose
```

### Custom Specification Directory
```bash
cargo run -- --prompt "Build a CLI tool" --spec-dir /path/to/specs
```

## Architecture

### Core Components

1. **SMARSIntegration** (`src/smars_integration.rs`)
   - Loads and processes SMARS specifications
   - Converts natural language prompts to SMARS plans
   - Executes plans using deterministic runtime
   - Validates against baseline specifications

2. **UserInterface** (`src/user_interface.rs`)
   - Handles all stdio user interactions
   - Provides formatted output and progress display
   - Manages user input requests and decisions

3. **AgentCoordinator** (`src/agent_coordinator.rs`)
   - Manages multi-agent network
   - Coordinates agent responses and consensus
   - Handles agent spawning and capability matching

### Bundled Specifications

The agent includes essential SMARS specifications in the `specs/` directory:

- `smars-baseline-v0.1.smars.md` - Core baseline specification
- `core-patterns.smars.md` - Common planning and execution patterns
- `runtime-loop.smars.md` - Deterministic runtime loop specification

## Planning Cycle

1. **Prompt Analysis**: Convert natural language to SMARS specification
2. **Plan Validation**: Validate against baseline specifications
3. **Execution**: Run plan using deterministic runtime with reality grounding
4. **Multi-Agent Coordination**: Coordinate with multiple agents if needed
5. **User Interaction**: Handle user input requests through stdio
6. **Evaluation**: Assess completion and determine next steps
7. **Iteration**: Continue cycle until goal achieved or max cycles reached

## Examples

### Simple Task
```bash
cargo run -- --prompt "Create a TODO list application"
```

This will:
1. Generate a SMARS plan with steps for requirements, design, implementation, testing
2. Execute each step with user input requests
3. Create artifacts and validate their existence
4. Report completion status

### Complex Multi-Agent Task
```bash
cargo run -- --prompt "Design and implement a microservices architecture" --multi-agent
```

This will:
1. Generate a complex SMARS plan
2. Spawn validation, simulation, and decision agents
3. Coordinate agent responses for architecture decisions
4. Handle user decisions when agents can't reach consensus
5. Execute with reality grounding and feedback collection

## Building and Running

```bash
# Build the project
cargo build

# Run with example prompt
cargo run -- --prompt "Your task here"

# Run tests
cargo test

# Build for release
cargo build --release
```

## Integration with Main SMARS Project

This standalone agent leverages:

- SMARS specification format and grammar
- Baseline specification requirements
- Multi-agent coordination patterns
- Reality grounding mechanisms
- Deterministic execution principles

It's designed to be easily copied to other locations for benchmarking and testing while maintaining compatibility with the main SMARS ecosystem.

## Benchmarking

To use for benchmarking:

1. Copy the entire `standalone-agent/` directory to your benchmark location
2. Run `cargo build` to compile
3. Execute with your benchmark prompts
4. Results are saved as JSON sessions for analysis

The agent produces structured output suitable for automated analysis and comparison with other planning systems.