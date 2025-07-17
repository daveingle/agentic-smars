# Agentic SMARS

**Agentic SMARS** is a structured system for symbolic specification and agentic software development using **SMARS** — the Symbolic Multi-Agent Reasoning System. This repository serves as both a reference implementation and a working example of using SMARS to define its own development roadmap and coordinate agent behavior.

---

## Purpose

This is a symbolic workflow framework that enables:

- **Declarative reasoning** about plans, tests, branches, and contracts
- **Separation of specification from execution** 
- **Self-auditable planning** by agents or humans
- **Deterministic AI workflows** with symbolic validation
- **Multi-agent coordination** through shared symbolic vocabulary

---

## Directory Structure

| Directory         | Purpose                                                                    |
|-------------------|----------------------------------------------------------------------------|
| `spec/`           | Canonical `.smars.md` symbolic specifications with formal declarations     |
| `spec/automation/` | Agentic automation patterns and DEU (Development Enhancement Unit) specs  |
| `spec/patterns/`   | Reusable symbolic patterns for common agentic behaviors                   |
| `spec/requests/`   | Request-driven specifications with full traceability                      |
| `spec/smars-dev/`  | Meta-specifications where SMARS defines its own development roadmap       |
| `impl/`           | `.implementation.md` files describing how to interpret symbolic specs      |
| `grammar/`        | EBNF grammar defining the SMARS language structure                        |
| `sop/`            | Standard Operating Procedure for creating and using SMARS artifacts       |
| `cues/`           | Advisory symbolic suggestions (non-binding guidance)                      |
| `journal/`        | Numbered explorations and symbolic experiments                             |
| `notes/`          | Meta-reflection and design hypotheses                                      |
| `archive/`        | Retired or deprecated symbolic models                                      |

---

## SMARS Language

SMARS provides symbolic constructs for agent coordination:

- **`kind`** - Data type definitions with named fields
- **`datum`** - Symbolic constants with values  
- **`maplet`** - Typed function declarations
- **`plan`** - Ordered symbolic procedures with steps
- **`contract`** - Behavioral requirements using `⊨` (entails)
- **`branch`** - Conditional dispatch using `⎇`
- **`test`** - Behavioral expectations
- **`cue`** - Advisory suggestions (non-binding)
- **`@role(...)`** - Role-scoping declarations

### Key Symbols
- `▸` - Function application
- `§` - Plan step delimiter  
- `⎇` - Conditional branching
- `⊨` - Contract entailment
- `⟦⟧` - Datum value brackets
- `∷` - Type annotation
- `→` - Function type arrows

---

## File Types

| Extension         | Purpose                                                      |
|-------------------|--------------------------------------------------------------|
| `.smars.md`       | Formal symbolic specifications (must include plan, kind, contract) |
| `.implementation.md` | Concrete interpretations of symbolic specs                |
| `.cues.md`        | Well-formed advisory cues using `(cue id ⊨ suggests: ...)`  |

---

## Development Workflow

This project follows the **Agentic Development Loop**:

1. **Specification Phase** - Create symbolic declarations in `.smars.md`
2. **Implementation Phase** - Interpret symbols in `.implementation.md`
3. **Validation Phase** - Verify contracts, tests, and plan flows
4. **Cue Declaration Phase** - Capture advisory guidance
5. **Archival** - Retire deprecated artifacts

---

## Core Documents

- [`grammar/smars.ebnf.md`](./grammar/smars.ebnf.md) - Formal EBNF grammar
- [`sop/smars-sop.md`](./sop/smars-sop.md) - Standard operating procedure
- [`spec/smars-dev/roadmap.overview.smars.md`](./spec/smars-dev/roadmap.overview.smars.md) - Development roadmap
- [`journal/001-agentic-loop.smars.md`](./journal/001-agentic-loop.smars.md) - Meta-level development cycle

---

## Current State

The repository contains:

- **Comprehensive spec library** with automation patterns, stability mechanisms, and development roadmap
- **Meta-specification approach** where SMARS defines its own evolution in `spec/smars-dev/`
- **Numbered journal entries** documenting key insights and explorations
- **Symbolic self-governance** through formal contracts and validation patterns
- **Self-evolving request management** with full traceability from requests to implementations

### Self-Evolution Milestone ✨

**REQ-006 Achievement**: Successfully demonstrated self-evolving system capabilities by creating and immediately using symbolic request management workflow. The system:

- Created `spec/requests/meta-request-management.smars.md` defining symbolic request handling
- Applied new workflow to process the demonstration request itself (recursive validation)
- Generated traceable artifacts: `journal/006` → `cues/self-evolving-systems.md` → `spec/patterns/self-evolving-systems.smars.md`
- Proved **immediate utility** - specifications become actionable system capabilities the moment they're created
- Established **symbolic bootstrap** - system can evolve its own capabilities and immediately apply them

This milestone demonstrates SMARS's core power: symbolic specifications that immediately become actionable, enabling continuous self-enhancement through symbolic reasoning.

---

## Next Phase

This project is transitioning to use SMARS for:
- **Spec development** - All new specifications will be SMARS-driven
- **Request management** - Traceable symbolic handling of development requests
- **Agentic coordination** - Multi-agent workflows using shared symbolic vocabulary

---

## Feedback

This system is under active symbolic development. Feedback welcome through issues for:

- Language clarification or grammar questions
- Symbolic pattern suggestions
- Agentic workflow improvements

---

## License

Shared for open inspection and experimentation. See `LICENSE` for details.
