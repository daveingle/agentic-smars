# SMARS Planning Substrate

This directory contains the SMARS (Symbolic Multi-Agent Reasoning System) substrate for this repository. SMARS provides deterministic planning and execution capabilities with reality grounding and comprehensive validation.

## Directory Structure

```
.smars/
├── config/          # SMARS configuration
├── specs/           # SMARS plan specifications  
├── plans/           # Deprecated (kept for compatibility)
├── agents/          # Agent configurations
├── templates/       # Plan templates
├── traces/          # Execution traces (local-only)
├── smars-cli.py     # Repository CLI wrapper
├── integrate.sh     # Repository integration script
└── README.md        # This file
```

## Quick Start

### 1. Check Status
```bash
python .smars/smars-cli.py status
```

### 2. Create a Plan
```bash
python .smars/smars-cli.py init feature-authentication
```

### 3. Execute Plan
```bash
python .smars/smars-cli.py exec feature-authentication
```

### 4. List Plans
```bash
python .smars/smars-cli.py list
```

## Integration

Run the integration script to add shell aliases and repository configuration:

```bash
.smars/integrate.sh
```

After integration, you can use the `smars` command directly:

```bash
smars status
smars init my-feature
smars exec my-feature
```

## Plan Templates

Available templates:
- `feature`: Feature development with requirements, implementation, and validation
- `bugfix`: Bug resolution with root cause analysis and testing
- `refactor`: Code refactoring with safety validation
- `deployment`: Deployment planning with rollback procedures

## Configuration

Edit `.smars/config/smars.toml` to customize:
- Execution parameters (determinism, feedback enforcement)
- Validation settings (contract, artifact, reality validation)
- Agent capabilities (self-auditing, reality simulation)

## Dependencies

Requires SMARS agent binary:
- Install from source or package manager
- Or build from `smars-agent/` directory
- Or use containerized version

## Reality Grounding

SMARS prevents "symbolic hallucination" by:
- Enforcing artifact existence validation
- Requiring concrete feedback collection
- Implementing confidence bounds
- Maintaining reality-simulation alignment

All plan executions produce verifiable artifacts and comprehensive execution traces.
