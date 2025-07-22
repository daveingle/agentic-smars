# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository implements **Agentic SMARS** - an evolving multi-agent substrate that bridges symbolic reasoning with emergent agency using SMARS (Symbolic Multi-Agent Reasoning System). The project has progressed from pure symbolic planning to a comprehensive multi-agent environment supporting memory, autonomy, validation, and reality-grounded execution.

**Current State**: Post-"symbolic hallucination" discovery, the project is implementing a six-phase multi-agent architecture alignment roadmap with runtime contract enforcement, inter-agent communication, and external framework integration.

## Core Architecture

### Directory Structure
- `spec/` - Canonical `.smars.md` symbolic specifications with formal declarations
- `spec/automation/` - Agentic automation patterns and DEU (Development Enhancement Unit) specs
- `spec/patterns/` - Reusable symbolic patterns for common agentic behaviors
- `spec/requests/` - Request-driven specifications with full traceability
- `spec/smars-dev/` - Meta-specifications where SMARS defines its own development roadmap
- `impl/` - Corresponding `.implementation.md` files that interpret symbolic specs
- `grammar/` - EBNF grammar defining the SMARS language structure
- `sop/` - Standard Operating Procedure for creating and using SMARS artifacts
- `cues/` - Symbolic suggestions for potential directions (advisory only)
- `notes/` - Meta-reflection and design hypotheses
- `journal/` - Numbered symbolic experiments and explorations (001-021+)
- `archive/` - Retired or deprecated symbolic models
- `fake-podcasts/` - Synthetic meta-cognitive analysis documenting evolution journey
- `experiments/` - Concrete implementations and validation testing

### SMARS Language Elements

The SMARS DSL includes these core primitives:

### Foundation Elements
- `@role(...)` - Role-scoping declarations (platform, developer, user)
- `kind` - Data type definitions with named fields
- `datum` - Symbolic constants with values
- `maplet` - Typed function declarations
- `apply` - Function application expressions
- `contract` - Behavioral requirements and guarantees using `⊨`
- `plan` - Ordered symbolic procedures with `§ steps:`
- `branch` - Conditional dispatch using `⎇`
- `test` - Behavioral expectations
- `default` - LLM-specific behavior directives
- `cue` - Advisory suggestions (non-binding)

### Multi-Agent Extensions (Post-Evolution)
- `agent` - Agent type definitions with persistent state
- `memory` - Symbolic memory structures for agent persistence
- `confidence` - First-class uncertainty metrics for decision-making
- `validation` - Inter-agent validation request protocols
- `artifact` - Real-world output requirements and verification
- `communication` - Structured agent messaging primitives

### Key Symbols
- `▸` - Function application in apply statements
- `§` - Plan step list delimiter
- `⎇` - Conditional branching
- `⊨` - Contract requirement/postcondition
- `⟦⟧` - Datum value brackets
- `∷` - Type annotation separator
- `→` - Function type arrows and branch targets

## File Types and Conventions

### `.smars.md` Files
Located in `spec/`, these contain formal symbolic declarations following the EBNF grammar. Must include at least one plan, kind, and contract. Always start with `@role(...)` directive.

### `.implementation.md` Files  
Located in `impl/`, these describe how interpreters fulfill symbolic specs. Must provide concrete representations for all declared symbols and maintain logical consistency with specifications.

### `.cues.md` Files
Located in `cues/`, contain well-formed advisory cues only. Use format: `(cue identifier ⊨ suggests: explanation)`

## Development Workflow

This project follows the **Evolved Multi-Agent Development Loop** with reality-grounded execution:

### Current Workflow (Post-Hallucination Discovery)
**CRITICAL**: This workflow includes safeguards against symbolic hallucination - where the system claims success without producing real artifacts.

1. **Request Capture** - Assign request ID (REQ-NNN) and capture in symbolic form
2. **Cue Generation** - Generate symbolic cues from analytical insights
3. **Spec Promotion** - Promote valuable cues to formal SMARS specifications
4. **Implementation** - Create `.implementation.md` files with concrete artifact requirements
5. **Reality Verification** - Enforce actual artifact generation and validation
6. **Journal Analysis** - Create numbered journal entry with meta-cognitive reflection on outcomes
7. **Multi-Agent Coordination** - Enable inter-agent validation requests and feedback loops
8. **Traceability** - Maintain full genealogy from request to verified outcomes

### Legacy Workflow (Pre-Evolution - Use Only for Internal Specs)
1. **Specification Phase** - Create symbolic declarations in `.smars.md`
2. **Implementation Phase** - Interpret symbols in `.implementation.md`  
3. **Validation Phase** - Verify contracts, tests, and plan flows
4. **Cue Declaration Phase** - Capture advisory guidance
5. **Archival** - Retire deprecated artifacts to `archive/`

### Multi-Agent Architecture Phases (Active Development)
The project is implementing a six-phase evolution:
- **Phase 1**: Runtime contract enforcement
- **Phase 2**: Validation framework with confidence metrics
- **Phase 3**: Symbolic agency constructs (memory, goals, autonomy)
- **Phase 4**: Structured inter-agent communication
- **Phase 5**: Artifact auditing and reality verification
- **Phase 6**: External framework integration and benchmarking

## Working with SMARS Files

### Symbolic Specifications (`.smars.md` files)
When editing SMARS specifications:

**Foundation Requirements:**
- Validate syntax against `grammar/smars.ebnf.md`
- Follow the SOP defined in `sop/smars-sop.md`
- Ensure all symbols are properly declared before use
- Maintain role-based scoping with `@role(...)` directives
- Use symbolic forms consistently (prefer `maplet` over informal descriptions)

**Multi-Agent Evolution Requirements:**
- **CRITICAL**: Include artifact requirements to prevent symbolic hallucination
- For new requests, use the evolved workflow with reality verification
- Implement confidence metrics for uncertain operations
- Design validation request mechanisms for inter-agent coordination
- Maintain request traceability through REQ-NNN identifiers
- Consider memory persistence for agent state management
- Include communication protocols for multi-agent scenarios

### Swift Implementation Integration
When working on the Swift MAR implementation:

**Symbolic-to-Swift Mapping:**
- SMARS `kind` declarations map to Swift structs with `@Generable`
- SMARS `datum` values become Swift static constants
- SMARS `maplet` functions map to Swift function types
- SMARS `plan` steps become Swift async sequences
- SMARS `contract` requirements become Swift preconditions/postconditions

**Development Workflow:**
1. Create symbolic specification in `spec/`
2. Generate corresponding Swift types in `mar/Sources/SMARS/`
3. Implement execution logic in `mar/Sources/Host/`
4. Validate with concrete experiments in `experiments/`
5. Document implementation in corresponding `.implementation.md` file

## Build and Development Commands

### SMARS Symbolic Specifications
This repository's primary focus is symbolic reasoning specifications without traditional build commands. Validation occurs through:

- **Symbolic consistency checking** against grammar and SOP
- **Reality verification** to prevent symbolic hallucination
- **Artifact auditing** to ensure concrete outputs
- **Multi-agent coordination testing** for validation protocols
- **External benchmark integration** for performance measurement

### MAR Swift Implementation
The `mar/` directory contains a Swift implementation of the Multi-Agent Runtime:

```bash
# Build the Swift MAR implementation
cd mar && swift build

# Run tests for the Swift implementation
cd mar && swift test

# Build for release
cd mar && swift build -c release
```

**Key Swift Modules:**
- **Host** - Runtime environment and orchestration
- **SMARS** - Core SMARS language constructs and types
- **Tools** - Development and validation utilities

**Platform Requirements:**
- macOS 26.0+ / iOS 26.0+
- Swift 6.2+
- FoundationModels framework integration

## Key Documents

### Foundation Documents
- `grammar/smars.ebnf.md` - Formal EBNF grammar specification
- `sop/smars-sop.md` - Standard operating procedure for symbolic artifacts

### Evolution Documentation
- `fake-podcasts/001-From-Hallucination-to-Integration.md` - Discovery of symbolic hallucination and architectural evolution
- `fake-podcasts/002.md` - Multi-agent substrate transition and missing agency ingredients
- `journal/001-agentic-loop.smars.md` - Meta-level development cycle definition
- `journal/006-self-evolving-workflow-demonstration.md` - Self-evolution milestone achievement
- Journal entries 007-021+ - Continued evolution toward multi-agent substrate

### Multi-Agent Architecture
- `spec/requests/meta-request-management.smars.md` - Symbolic request management workflow
- `spec/patterns/self-evolving-systems.smars.md` - Self-evolution patterns and capabilities
- `spec/patterns/symbolic-agency-constructs.smars.md` - Agency integration patterns
- `spec/patterns/agent-collaboration-protocols.smars.md` - Inter-agent communication
- `spec/automation/artifact-contract-auditing.smars.md` - Reality verification mechanisms

### External Integration
- Multi-agent systems alignment with FIPA, AutoGen, CAMEL frameworks
- Benchmarking integration with AgentBench, Arena, GAIA platforms

### Swift Implementation Bridge
- `mar/Sources/SMARS/` - Swift types corresponding to SMARS symbolic constructs
- `mar/Sources/Host/` - Runtime execution environment for symbolic plans
- `experiments/` - Swift validation experiments for symbolic specifications

## Request Management

**CRITICAL**: All development requests must follow the evolved multi-agent workflow with reality-grounding:

1. **Request Assignment** - Assign REQ-NNN identifier with context analysis
2. **Cue Generation** - Generate symbolic cues from insights
3. **Spec Promotion** - Promote cues to formal specifications with artifact requirements
4. **Implementation** - Create concrete behavior descriptions with validation mechanisms
5. **Reality Verification** - Ensure actual artifact generation (prevent symbolic hallucination)
6. **Journal Analysis** - Create numbered entry with meta-cognitive reflection on outcomes
7. **Multi-Agent Coordination** - Implement validation requests and feedback loops
8. **Traceability** - Maintain full genealogy with confidence metrics

**Symbolic Hallucination Prevention**: Always require concrete artifacts and validation evidence. The system must not claim success without producing verifiable outputs.

This ensures both symbolic consistency and reality-grounded execution in the evolving multi-agent substrate.

## Critical Insights

### Symbolic Hallucination Discovery
- **NEVER** allow the system to claim task completion without producing concrete artifacts
- Always enforce reality verification mechanisms
- Implement confidence-driven validation requests

### Multi-Agent Evolution
- SMARS is a substrate, not a single agent
- Agent memory, goals, and autonomy are essential for true agency
- Inter-agent communication requires structured protocols

### External Integration
- Align with established multi-agent frameworks (FIPA, AutoGen)
- Implement benchmark evaluation for performance measurement
- Support both symbolic reasoning and emergent behavior

### Meta-Cognitive Development
- Synthetic dialogue analysis (fake-podcasts) provides valuable architectural insights
- Self-reflection through multiple perspectives accelerates system evolution
- Document the journey from symbolic planning to agentic substrate

## Memories
=======
1. **Request Capture** - Create formal SMARS specification in `spec/requests/REQ-NNN-name.smars.md`
2. **Analysis** - Record insights in `journal/NNN-analysis-topic.md` (system learning focus)
3. **Cue Generation** - Generate advisory cues in `cues/topic-insights.md` from analysis
4. **Spec Promotion** - Promote valuable cues to formal specs in appropriate `spec/` subdirectory  
5. **Implementation** - Create `.implementation.md` files for concrete behavior
6. **Outcome Tracking** - Record completion in `requests/completed/REQ-NNN-summary.md`

**Key Principle**: Journals are for system evolution insights, not request tracking. Maintain clear separation between journaling (system learning) and request management (workflow execution).

- Always truly validate
- Prevent symbolic hallucination through artifact requirements
- Enable multi-agent collaboration with structured communication
- Bridge symbolic expressiveness with emergent agency capabilities