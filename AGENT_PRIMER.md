# Agentic SMARS Agent Primer

@role(developer)
(datum ⟦agent_guide_version⟧ ∷ STRING = "v0.3")

## Quick Start Guide for New Sessions

This document provides essential context for agents working with the Agentic SMARS system - a symbolic specification and agentic development framework.

## Project Overview

**Agentic SMARS** is a structured system for symbolic specification and agentic software development using the SMARS DSL (Symbolic Multi-Agent Reasoning System). The project has achieved **self-evolution milestone** (REQ-006) with operational symbolic request management.

## Core Architecture

### Directory Structure
```
spec/                    # Canonical symbolic specifications
├── automation/          # Agentic automation patterns and DEU specs
├── patterns/           # Reusable symbolic patterns
├── requests/           # Request-driven specifications with traceability
└── smars-dev/          # Meta-specifications (SMARS defines itself)

impl/                   # Implementation interpretations of specs
grammar/                # EBNF grammar for SMARS language
sop/                    # Standard Operating Procedure
cues/                   # Advisory suggestions (non-binding)
journal/                # Numbered experiments and explorations
archive/                # Retired artifacts
```

### SMARS Language Elements

The SMARS DSL provides these symbolic primitives:

- `@role(platform|developer|user)` - Role-scoping declarations
- `kind` - Data type definitions with named fields
- `datum` - Symbolic constants with values in `⟦⟧` brackets
- `maplet` - Typed function declarations using `→`
- `apply` - Function applications using `▸`
- `contract` - Behavioral requirements using `⊨`
- `plan` - Ordered procedures with `§ steps:`
- `branch` - Conditional dispatch using `⎇`
- `test` - Behavioral expectations
- `default` - LLM-specific behavior directives
- `cue` - Advisory suggestions (non-binding)

## Primary Development Workflow

**IMPORTANT**: All development requests should follow the **Integrated Agentic Development Loop**:

1. **Request Capture** - Assign REQ-NNN identifier
2. **Journal Analysis** - Create numbered journal entry (00N-description.md)
3. **Cue Generation** - Generate symbolic cues from insights
4. **Spec Promotion** - Promote valuable cues to formal specifications
5. **Implementation** - Create `.implementation.md` files
6. **Validation** - Verify contracts, tests, and plan flows
7. **Traceability** - Maintain genealogy from request to artifacts

## Key Patterns

### Request Management
- `spec/requests/meta-request-management.smars.md` - Core request handling workflow
- All requests get REQ-NNN identifiers for traceability
- Journal entries analyze and understand requests symbolically
- Cues capture insights and potential directions
- Promoted cues become formal specifications

### Self-Evolution
- `spec/patterns/self-evolving-systems.smars.md` - System modification patterns
- System can create capabilities and immediately apply them
- Recursive validation ensures self-consistency
- Traceability maintained through all evolution steps

### Agentic Patterns
- `spec/agentic-patterns.smars.md` - Emergent composition patterns
- SpecDelta for structured change management
- AgenticCycle for self-referential execution
- Meta-orchestration of symbolic automation

## File Types

### `.smars.md` Files (in `spec/`)
- Formal symbolic declarations following EBNF grammar
- Must include at least one plan, kind, and contract
- Always start with `@role(...)` directive
- Located in appropriate spec subdirectories

### `.implementation.md` Files (in `impl/`)
- Concrete interpretations of symbolic specifications
- Provide representations for all declared symbols
- Must maintain logical consistency with specs

### `.cues.md` Files (in `cues/`)
- Advisory suggestions in format: `(cue identifier ⊨ suggests: explanation)`
- Non-binding guidance for future directions
- Subject to systematic evaluation and promotion

## Cue Handling Policy

Cues are evaluated on four criteria (0.0-1.0 scale):
- **Technical Feasibility** (≥0.6 for promotion)
- **System Alignment** (≥0.6 for promotion)
- **Implementation Complexity** (higher is better)
- **Value Proposition** (impact on system)

**Promotion Criteria**: Combined score ≥0.7 AND no criterion <0.4
**Rejection Criteria**: Technical feasibility <0.4 OR system alignment <0.4 OR combined score <0.5

## Working with SMARS

### Creating Specifications
1. Validate syntax against `grammar/smars.ebnf.md`
2. Follow SOP defined in `sop/smars-sop.md`
3. Ensure all symbols declared before use
4. Use symbolic forms consistently
5. Maintain role-based scoping

### Symbolic Stability
- Treat evolution as **refinement**, not breaking changes
- Preserve core intent while allowing detail enhancement
- Multiple agents can work with different symbolic detail levels
- Essential contracts and plans remain stable

## Symbolic Validation

SMARS is not a compiled system. Validation occurs through symbolic plan coherence, contract satisfaction, and cue integration — not runtime execution.

## Key Documents Reference

- `grammar/smars.ebnf.md` - Formal grammar specification
- `sop/smars-sop.md` - Standard operating procedure
- `spec/requests/meta-request-management.smars.md` - Request workflow
- `spec/patterns/self-evolving-systems.smars.md` - Evolution patterns
- `journal/006-self-evolving-workflow-demonstration.md` - Milestone achievement

## Request Processing Template

When handling new requests:

1. **Capture**: Assign REQ-NNN, document requirements
2. **Analyze**: Create journal/00N-description.md with insights
3. **Cue**: Generate advisory suggestions from analysis
4. **Promote**: Evaluate cues and promote qualified ones to specs
5. **Implement**: Create corresponding implementation files
6. **Validate**: Verify symbolic consistency and contract fulfillment
7. **Trace**: Maintain genealogy from request to final artifacts

## Symbolic Evolution Approach

- **Refinement over replacement**: New understanding enhances symbols
- **Intent preservation**: Core meaning remains constant
- **Agent consensus**: Multiple perspectives can coexist
- **Evolutionary stability**: Planning structure maintains consistency

This primer provides the foundation for effective collaboration with the Agentic SMARS system. The emphasis is on symbolic reasoning, structured workflows, and maintaining traceability throughout the development process.