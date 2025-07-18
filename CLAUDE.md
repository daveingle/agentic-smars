# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository implements **Agentic SMARS** - a structured system for symbolic specification and agentic software development using a custom DSL called SMARS (Symbolic Multi-Agent Reasoning System). This is a reference implementation of a symbolic workflow that enables declarative reasoning about plans, tests, branches, and contracts.

**Current State**: The project has achieved **self-evolution milestone** (REQ-006) with fully operational symbolic request management and traceable development workflows.

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
- `journal/` - Numbered symbolic experiments and explorations (001-006+)
- `archive/` - Retired or deprecated symbolic models

### SMARS Language Elements

The SMARS DSL includes these core primitives:
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

This project follows the **Integrated Agentic Development Loop** with symbolic request management:

### Primary Workflow (use for all development requests)
1. **Request Capture** - Assign request ID (REQ-NNN) and capture in symbolic form
2. **Journal Analysis** - Create numbered journal entry analyzing the request
3. **Cue Generation** - Generate symbolic cues from journal insights
4. **Spec Promotion** - Promote valuable cues to formal SMARS specifications
5. **Implementation** - Create `.implementation.md` files for concrete behavior
6. **Validation** - Verify contracts, tests, and plan flows
7. **Traceability** - Maintain genealogy from request to final artifacts

### Traditional Loop (for internal spec development)
1. **Specification Phase** - Create symbolic declarations in `.smars.md`
2. **Implementation Phase** - Interpret symbols in `.implementation.md`  
3. **Validation Phase** - Verify contracts, tests, and plan flows
4. **Cue Declaration Phase** - Capture advisory guidance
5. **Archival** - Retire deprecated artifacts to `archive/`

## Working with SMARS Files

When editing SMARS specifications:
- Validate syntax against `grammar/smars.ebnf.md`
- Follow the SOP defined in `sop/smars-sop.md`
- Ensure all symbols are properly declared before use
- Maintain role-based scoping with `@role(...)` directives
- Use symbolic forms consistently (prefer `maplet` over informal descriptions)
- For new requests, follow the integrated agentic workflow above
- Maintain request traceability through REQ-NNN identifiers

## No Build System

This repository contains no traditional build, test, or lint commands. It's a symbolic specification system focused on declarative reasoning rather than executable code. Validation occurs through symbolic consistency checking and manual verification against the grammar and SOP.

## Key Documents

- `grammar/smars.ebnf.md` - Formal EBNF grammar specification
- `sop/smars-sop.md` - Standard operating procedure for symbolic artifacts
- `spec/requests/meta-request-management.smars.md` - Symbolic request management workflow
- `spec/patterns/self-evolving-systems.smars.md` - Self-evolution patterns and capabilities
- `journal/001-agentic-loop.smars.md` - Meta-level development cycle definition
- `journal/006-self-evolving-workflow-demonstration.md` - Self-evolution milestone achievement

## Request Management

**IMPORTANT**: All development requests should follow the integrated agentic workflow:

1. **Request Capture** - Create formal SMARS specification in `spec/requests/REQ-NNN-name.smars.md`
2. **Analysis** - Record insights in `journal/NNN-analysis-topic.md` (system learning focus)
3. **Cue Generation** - Generate advisory cues in `cues/topic-insights.md` from analysis
4. **Spec Promotion** - Promote valuable cues to formal specs in appropriate `spec/` subdirectory  
5. **Implementation** - Create `.implementation.md` files for concrete behavior
6. **Outcome Tracking** - Record completion in `requests/completed/REQ-NNN-summary.md`

**Key Principle**: Journals are for system evolution insights, not request tracking. Maintain clear separation between journaling (system learning) and request management (workflow execution).

This ensures symbolic consistency and evolutionary capability of the system.