# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository implements **Agentic SMARS** - a multi-agent planning operating system that bridges symbolic reasoning with deterministic execution. SMARS evolved from a pure symbolic DSL to a comprehensive runtime system supporting reality grounding, multi-agent coordination, and systematic coverage measurement.

**Current State**: Advanced prototype with working demonstrations across all core capabilities, requiring 6-12 months for production deployment.

## Critical Project Insights

### Reality Grounding is Essential
**CRITICAL**: This project was built to combat "symbolic hallucination" - the tendency for AI systems to claim task completion without producing actual artifacts. Always enforce reality validation:

- **Never claim success without artifacts**: All implementations must produce verifiable outputs
- **Validate artifact existence**: Check that files, data, or results actually exist
- **Use confidence bounds**: Quantify uncertainty rather than expressing false confidence
- **Enforce feedback collection**: Mandatory feedback prevents unsupported claims

### Prototype vs Production Boundaries
The project maintains strict boundaries between demonstrated capabilities and production readiness:

- **What works**: Deterministic runtime loop, multi-agent demonstrations, repository substrate
- **What's simulated**: Coverage percentages, confidence values, agent coordination metrics  
- **What needs implementation**: Real artifact validation, cryptographic determinism, distributed networking

## Core Architecture

### Directory Structure
```
agentic-smars/
├── spec/                     # Formal SMARS specifications
│   ├── smars-baseline-v0.1.smars.md  # Production baseline requirements
│   ├── patterns/             # Reusable agent patterns
│   └── requests/             # Request-driven development specs
├── impl/                     # Implementation specifications
├── smars-agent/              # Rust runtime implementation
│   ├── src/
│   │   ├── runtime_loop.rs   # Deterministic execution engine
│   │   ├── agent_demo.rs     # Multi-agent coordination demos
│   │   ├── executor.rs       # Plan execution with Swift LLM integration
│   │   └── coverage_analyzer.rs  # Implementation measurement
├── mar/                      # Swift FoundationModels integration
├── templates/                # Developer integration tools
├── grammar/                  # SMARS language definition (EBNF)
├── sop/                      # Standard operating procedures
├── journal/                  # Chronological development insights (25+ entries) 
└── experiments/              # Active development and testing
```

### SMARS Language Elements

The SMARS DSL provides symbolic constructs for multi-agent planning:

#### Foundation Elements
- `@role(...)` - Role-scoping declarations (platform, developer, user)
- `kind` - Data type definitions with named fields
- `datum` - Symbolic constants with values in `⟦⟧` brackets
- `maplet` - Typed function declarations with `∷` type annotations
- `apply` - Function application expressions using `▸`
- `contract` - Behavioral requirements using `⊨ requires:` and `⊨ ensures:`
- `plan` - Ordered symbolic procedures with `§ steps:`
- `branch` - Conditional dispatch using `⎇`
- `test` - Behavioral expectations
- `default` - LLM-specific behavior directives
- `cue` - Advisory suggestions (non-binding)

#### Multi-Agent Extensions
- `agent` - Agent type definitions with capabilities and memory
- `memory` - Symbolic memory structures for agent persistence
- `confidence` - First-class uncertainty metrics with bounded ranges
- `validation` - Inter-agent validation request protocols
- `artifact` - Real-world output requirements and verification

#### Key Symbols
- `▸` - Function application in apply statements
- `§` - Plan step list delimiter
- `⎇` - Conditional branching
- `⊨` - Contract requirement/postcondition
- `⟦⟧` - Datum value brackets
- `∷` - Type annotation separator
- `→` - Function type arrows and branch targets

## Development Workflow

### Current Multi-Agent Development Loop
**CRITICAL**: This workflow includes safeguards against symbolic hallucination:

1. **Request Capture** - Assign REQ-NNN identifier and create formal specification
2. **Reality Requirements** - Define concrete artifacts and validation mechanisms
3. **Spec Creation** - Build formal SMARS specifications with contracts and plans
4. **Prototype Implementation** - Create working demonstrations with clear boundaries
5. **Reality Verification** - Enforce actual artifact generation and validation
6. **Journal Documentation** - Record outcomes with honest assessment of progress
7. **Coverage Analysis** - Measure implementation against baseline specifications

### File Type Conventions

#### `.smars.md` Files (in `spec/`)
Formal symbolic declarations following EBNF grammar:
- Must include at least one plan, kind, and contract
- Always start with `@role(...)` directive
- Follow grammar in `grammar/smars.ebnf.md`
- Use symbolic forms consistently

#### `.implementation.md` Files (in `impl/`)
Concrete behavior descriptions for symbolic specs:
- Must provide concrete representations for all declared symbols
- Include artifact requirements to prevent hallucination
- Maintain logical consistency with specifications

#### `.cues.md` Files (in `cues/`)
Advisory suggestions only:
- Use format: `(cue identifier ⊨ suggests: explanation)`
- Non-binding guidance for future development
- Subject to systematic evaluation per SOP

## Key Development Principles

### 1. Specification-Driven Development
- **Comprehensive symbolic architecture before implementation**
- **Formal contracts and plans as primary development artifacts**
- **Implementation as specification fulfillment rather than feature accumulation**

**Result**: System maturity achieved faster with zero architectural debt.

### 2. Reality-Grounded Design
- **Reality validation as architectural requirement, not optional testing**
- **Artifact existence verification and bounded confidence frameworks**
- **Continuous calibration with physical world outcomes**

**Prevents**: Symbolic hallucination and overconfident progress claims.

### 3. Multi-Agent Coordination
- **Agents as first-class symbolic citizens with declared capabilities**
- **Polymorphic delegation based on capability requirements**
- **Structured inter-agent communication and validation protocols**

**Enables**: True distributed intelligence and emergent coordination patterns.

## Build and Development Commands

### SMARS Rust Implementation
```bash
# Build the SMARS agent runtime
cd smars-agent
cargo build

# Run deterministic runtime demonstrations
cargo run -- runtime --spec examples/test-plan.smars.md --detailed

# Demonstrate multi-agent coordination
cargo run -- agent-demo --comprehensive

# Analyze coverage against baseline
cargo run -- coverage --detailed

# Discover agents in network
cargo run --example discover
```

### Swift MAR Implementation
```bash
# Build the Swift Multi-Agent Runtime
cd mar
swift build

# Run tests for Swift implementation
swift test

# Build for release
swift build -c release
```

### Repository Integration
```bash
# Initialize SMARS in any repository
./templates/repo-substrate/smars-init.sh

# Create and execute plans
.smars/smars-cli.py init my-feature
.smars/smars-cli.py exec my-feature
```

## Working with SMARS Files

### When Creating Specifications
**CRITICAL Requirements:**
- Validate syntax against `grammar/smars.ebnf.md`
- Follow SOP defined in `sop/smars-sop.md`
- Include artifact requirements to prevent symbolic hallucination
- Use confidence metrics for uncertain operations
- Design validation request mechanisms for multi-agent coordination
- Maintain request traceability through REQ-NNN identifiers

### When Implementing Code
**Symbolic-to-Code Mapping:**
- SMARS `kind` declarations map to language structs/types
- SMARS `datum` values become static constants
- SMARS `maplet` functions map to function types
- SMARS `plan` steps become sequential execution logic
- SMARS `contract` requirements become preconditions/postconditions

**Implementation Workflow:**
1. Create symbolic specification in `spec/`
2. Generate corresponding types in appropriate language
3. Implement execution logic with reality validation
4. Test with concrete experiments
5. Document implementation in corresponding `.implementation.md` file

## Critical Memories and Lessons

### From Journal Entry 025 (Reality Check Milestone)
**Key Discovery**: Even while building a system to prevent symbolic hallucination, we fell into the trap of overstating capabilities. This validates that reality grounding must be architectural, not optional.

**Honest Assessment**: 
- **Architecture**: Comprehensive and well-designed
- **Core Concepts**: Proven through working demonstrations  
- **Implementation Depth**: Surface-level with solid foundations
- **Production Readiness**: 6-12 months additional development

### From Journal Entry 024 (Agent Introspection)
**Key Achievement**: Successful transition from single-agent execution to multi-agent substrate with:
- Self-descriptive agents with standardized capability declarations
- Automatic agent discovery and capability filtering
- RPC-based agent delegation and orchestration
- Foundation for heterogeneous agent network coordination

### Validated Architectural Patterns
1. **Capability Declaration Pattern**: Enables polymorphic agent coordination
2. **Discovery Protocol Pattern**: Enables autonomous agent network formation
3. **Introspection Contracts Pattern**: Ensures agent network integrity
4. **Reality Grounding Pattern**: Prevents symbolic hallucination systematically

## Request Management

**CRITICAL**: All development requests must follow the evolved multi-agent workflow:

1. **Request Assignment** - Assign REQ-NNN identifier with context analysis
2. **Reality Requirements** - Define concrete artifacts and validation mechanisms  
3. **Spec Creation** - Create formal specifications with artifact requirements
4. **Implementation** - Build concrete behavior with validation mechanisms
5. **Reality Verification** - Ensure actual artifact generation (prevent symbolic hallucination)
6. **Journal Documentation** - Create numbered entry with honest progress assessment
7. **Coverage Analysis** - Measure against baseline specifications

**Symbolic Hallucination Prevention**: Always require concrete artifacts and validation evidence. The system must not claim success without producing verifiable outputs.

## Common Development Tasks

### Adding New SMARS Language Constructs
1. Update `grammar/smars.ebnf.md` with new syntax
2. Add parsing logic in `smars-agent/src/parser.rs`
3. Implement execution in `smars-agent/src/executor.rs`
4. Create demonstration in `smars-agent/examples/`
5. Document in specification and SOP updates

### Implementing Multi-Agent Features  
1. Define agent capabilities in capability registry
2. Implement discovery and communication protocols
3. Create coordination demonstrations
4. Validate with reality grounding checks
5. Measure coverage against baseline requirements

### Creating Repository Substrate Features
1. Update initialization script in `templates/repo-substrate/`
2. Enhance Python CLI wrapper with new commands
3. Test across multiple repository types
4. Document in usage examples
5. Validate end-to-end workflows

## Production Readiness Checklist

### Immediate Priorities (1-2 weeks)
- [ ] Replace simulated artifact validation with real file system checks
- [ ] Implement proper error handling and recovery mechanisms
- [ ] Add comprehensive integration testing beyond demonstrations
- [ ] Validate repository substrate across multiple real projects

### Medium-term Development (1-2 months)  
- [ ] Complete missing maplet implementations identified in coverage analysis
- [ ] Build distributed agent networking for true multi-agent coordination
- [ ] Implement cryptographic determinism for production security
- [ ] Add performance optimization and scalability testing

### Long-term Production Preparation (3-6 months)
- [ ] External framework integration (FIPA, AutoGen compatibility)
- [ ] Enterprise-grade monitoring, security, and audit logging
- [ ] Community documentation and contribution frameworks
- [ ] Benchmark evaluation against existing planning systems

## Important Guidelines for Claude

### Reality Grounding Requirements
- **NEVER** claim task completion without producing actual artifacts
- Always validate that files, outputs, or results actually exist
- Use confidence bounds and uncertainty quantification
- Implement feedback collection as mandatory, not optional
- Distinguish between prototype boundaries and production claims

### Multi-Agent Development
- Treat agents as first-class symbolic citizens with capabilities
- Design for polymorphic delegation and capability-based coordination
- Implement structured communication protocols
- Support both symbolic reasoning and emergent behavior patterns

### Specification-First Methodology
- Create symbolic specifications before implementation
- Use formal contracts and plans as development artifacts
- Implement as specification fulfillment, not feature accumulation
- Maintain clear separation between specification and implementation concerns

### Journal and Documentation Standards
- Use `journal/` for system evolution insights and discoveries
- Use `notes/` for implementation analysis and validation reports
- Maintain clear separation between journaling (learning) and request tracking (execution)
- Document both successes and failures with honest assessment

This CLAUDE.md reflects the current state of SMARS as an advanced prototype demonstrating novel approaches to AI planning systems, with clear boundaries between working capabilities and production requirements.