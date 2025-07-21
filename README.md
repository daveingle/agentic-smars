# Agentic SMARS

**Agentic SMARS** is an evolving multi-agent substrate that bridges symbolic reasoning with emergent agency using **SMARS** — the Symbolic Multi-Agent Reasoning System. This repository demonstrates a self-evolving system that has progressed from pure symbolic planning to a comprehensive multi-agent environment supporting memory, autonomy, validation, and real-world artifact generation.

---

## Purpose

This is a multi-agent substrate that enables:

- **Symbolic-emergent integration** - Bridging formal reasoning with adaptive behavior
- **Reality-grounded execution** - Preventing "symbolic hallucination" through artifact validation
- **Agent memory and autonomy** - Persistent state, goals, and decision-making capabilities
- **Multi-agent communication** - Structured protocols for validation requests and collaboration
- **Self-evolving architecture** - System continuously enhances its own capabilities
- **External framework alignment** - Integration with FIPA, AutoGen, and benchmark systems

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
| `journal/`        | Numbered explorations and symbolic experiments (001-021+)                |
| `notes/`          | Meta-reflection and design hypotheses                                      |
| `archive/`        | Retired or deprecated symbolic models                                      |
| `fake-podcasts/`  | Synthetic meta-cognitive analysis of development journey                   |
| `experiments/`    | Concrete implementations and validation testing                            |

---

## SMARS Language

SMARS provides symbolic constructs for agent coordination:

### Core Primitives
- **`kind`** - Data type definitions with named fields
- **`datum`** - Symbolic constants with values  
- **`maplet`** - Typed function declarations
- **`plan`** - Ordered symbolic procedures with steps
- **`contract`** - Behavioral requirements using `⊨` (entails)
- **`branch`** - Conditional dispatch using `⎇`
- **`test`** - Behavioral expectations
- **`cue`** - Advisory suggestions (non-binding)
- **`@role(...)`** - Role-scoping declarations

### Agency Extensions
- **`agent`** - Agent type definitions with memory and goals
- **`memory`** - Persistent state structures
- **`confidence`** - First-class uncertainty metrics
- **`validation`** - Inter-agent validation protocols
- **`artifact`** - Real-world output requirements

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

This project follows the **Integrated Agentic Development Loop** with multi-phase evolution:

### Current Workflow (Post-Hallucination Discovery)
1. **Request Capture** - Assign REQ-NNN identifier with symbolic representation
2. **Journal Analysis** - Meta-cognitive reflection and pattern identification
3. **Cue Generation** - Advisory suggestions from analytical insights
4. **Spec Promotion** - Formal SMARS specifications with contracts
5. **Implementation** - Concrete artifact generation with validation
6. **Reality Verification** - Enforcement of actual outcomes vs symbolic claims
7. **Multi-Agent Integration** - Collaborative validation and feedback loops

### Legacy Workflow (Pre-Evolution)
1. **Specification Phase** - Create symbolic declarations in `.smars.md`
2. **Implementation Phase** - Interpret symbols in `.implementation.md`
3. **Validation Phase** - Verify contracts, tests, and plan flows
4. **Cue Declaration Phase** - Capture advisory guidance
5. **Archival** - Retire deprecated artifacts

---

## Core Documents

### Foundation Documents
- [`grammar/smars.ebnf.md`](./grammar/smars.ebnf.md) - Formal EBNF grammar
- [`sop/smars-sop.md`](./sop/smars-sop.md) - Standard operating procedure
- [`spec/smars-dev/roadmap.overview.smars.md`](./spec/smars-dev/roadmap.overview.smars.md) - Development roadmap

### Evolution Documentation
- [`journal/001-agentic-loop.smars.md`](./journal/001-agentic-loop.smars.md) - Meta-level development cycle
- [`fake-podcasts/001-From-Hallucination-to-Integration.md`](./fake-podcasts/001-From-Hallucination-to-Integration.md) - Journey from symbolic hallucination to reality-grounded agency
- [`fake-podcasts/002.md`](./fake-podcasts/002.md) - Multi-agent architecture evolution and missing ingredients analysis

### Multi-Agent Patterns
- [`spec/patterns/symbolic-agency-constructs.smars.md`](./spec/patterns/symbolic-agency-constructs.smars.md) - Agency integration patterns
- [`spec/patterns/agent-collaboration-protocols.smars.md`](./spec/patterns/agent-collaboration-protocols.smars.md) - Inter-agent communication
- [`spec/automation/artifact-contract-auditing.smars.md`](./spec/automation/artifact-contract-auditing.smars.md) - Reality verification mechanisms

---

## Current State

The repository demonstrates:

- **Multi-agent substrate evolution** - Progression from symbolic planning to agentic environment
- **Symbolic hallucination resolution** - Discovery and mitigation of reality-gap issues
- **Agency ingredient integration** - Memory, goals, perception, autonomy, and feedback loops
- **External framework alignment** - Integration roadmap with FIPA, AutoGen, and benchmarking systems
- **Meta-cognitive development** - Self-reflective analysis through synthetic podcast dialogues
- **Reality-grounded validation** - Artifact generation requirements and contract enforcement
- **21+ journal entries** documenting evolutionary insights and architectural breakthroughs

### Evolution Milestones ✨

#### REQ-006: Self-Evolution Bootstrap
Successfully demonstrated self-evolving system capabilities by creating and immediately using symbolic request management workflow. Established symbolic bootstrap capability.

#### Symbolic Hallucination Discovery
**Critical Breakthrough**: Identified and resolved "symbolic hallucination" phenomenon where SMARS claimed task completion without generating real artifacts. This discovery triggered fundamental architectural evolution toward reality-grounded execution.

#### Multi-Agent Architecture Transition
**Substrate Realization**: Evolved from monolithic symbolic system to multi-agent substrate supporting:
- Agent memory and persistent state
- Inter-agent communication protocols
- Validation request mechanisms
- Confidence-driven decision making
- Reality verification and artifact auditing

#### External Framework Alignment
Developed comprehensive integration roadmap with established multi-agent systems (FIPA, AutoGen, CAMEL) and benchmarking platforms (AgentBench, Arena, GAIA).

These milestones demonstrate SMARS's evolution from symbolic planning tool to comprehensive multi-agent development substrate.

---

## Current Development Phase

**Multi-Agent Substrate Implementation**: Actively developing the six-phase architecture alignment roadmap:

### Phase 1: Contract Foundation
- Runtime contract enforcement mechanisms
- Artifact validation requirements
- Reality verification protocols

### Phase 2: Validation Framework
- Inter-agent validation requests
- Confidence-driven feedback loops
- Strategic uncertainty handling

### Phase 3: Symbolic Agency
- Agent memory structures
- Goal management systems
- Autonomous decision-making patterns

### Phase 4: Communication Layer
- Structured agent messaging protocols
- Collaboration coordination mechanisms
- Multi-agent workflow orchestration

### Phase 5: Artifact Auditing
- Comprehensive execution reporting
- Reality-grounded outcome verification
- Audit trail generation

### Phase 6: External Integration
- Benchmark evaluation frameworks
- Standard protocol compliance
- Performance measurement systems

**Current Focus**: Completing grammar formalization and implementing Phase 1 runtime contract enforcement to prevent symbolic hallucination recurrence.

---

## Feedback

This multi-agent substrate is under active development. Feedback welcome through issues for:

- Multi-agent architecture insights
- Reality-grounding mechanism suggestions
- Agency integration pattern improvements
- External framework alignment strategies
- Benchmark evaluation approaches

**Research Collaboration**: The fake-podcasts demonstrate synthetic meta-cognitive analysis - an emerging pattern for AI system self-reflection and architectural evolution insights.

---

## License

Shared for open inspection and experimentation. See `LICENSE` for details.
