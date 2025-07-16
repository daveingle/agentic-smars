# SMARS Standard Operating Procedure

This document defines the structured process for creating, interpreting, and iterating on symbolic specifications written in SMARS — the Symbolic Multi-Agent Reasoning System.

It is intended for use by agents (human or AI) that reason over plans, contracts, data structures, and tests in a deterministic, verifiable, and context-free way.

This SOP does not assume any specific programming framework or runtime.

---

## 1. Feature Specification Structure

### 1.1 Canonical Feature Directory Layout

Each feature or domain must follow this standardized structure in `spec/`:

```
spec/feature-name/
├── declaration.smars.md    # Single SMARS specification
├── implementation.md       # How to fulfill the spec
├── review.md              # Validation and feedback
└── summary.md             # Overview and status
```

### 1.2 Create `declaration.smars.md`

This is the single source of truth for the feature's symbolic specification. It must include:

- `@role(...)` — defines context (e.g. `developer`, `agent`)
- `kind` — data types with named fields
- `datum` — symbolic constants
- `maplet` — typed function declarations
- `contract` — behavioral requirements and guarantees
- `plan` — ordered symbolic procedures
- Optionally:
  - `branch` — conditional dispatch
  - `test` — behavioral expectations

Each block must be valid SMARS syntax, following the grammar defined in `grammar/smars.ebnf.md`.

---

## 2. Implementation Phase

### 2.1 Create `implementation.md` in the feature directory

This file describes how an interpreter (agent, developer, runtime) can fulfill the symbolic spec.

It must include:

- Concrete representations of each `kind`
- Functional scaffolds for each `maplet`
- Notes or logic that enforce each `contract` pre/postcondition
- An interpretation of each `plan` as sequential or reactive behavior
- Handling logic for each `branch`
- Binding or test implementation matching each `test` expectation

The implementation must remain logically consistent with its specification.

---

## 3. Validation Phase

### 3.1 Create `review.md` in the feature directory

Document validation results and feedback:

- Validate all `contract` requirements and postconditions in code or test logic
- Implement or simulate all `test` cases
- Confirm `plan` flows execute deterministically from the symbolic spec
- Check that `branch` conditions resolve to correct paths
- **Cross-feature symbol validation**: Detect duplicate `datum` and `kind` declarations across features
- **Agentic conflict resolution**: Generate `SpecDelta` proposals for symbol consolidation
- Record validation outcomes, issues found, and resolutions

Validation may be done manually, via interpreters, or through external runtime agents.

### 3.2 Agentic Symbol Conflict Resolution

When validation detects duplicate or inconsistent symbols across features:

1. **Detection**: Agent identifies duplicate `datum` or `kind` declarations
2. **Analysis**: Agent determines authoritative source and consolidation strategy
3. **Proposal**: Agent generates `SpecDelta` for moving shared symbols to `spec/shared/`
4. **Resolution**: Agent applies consolidation and updates dependent features
5. **Validation**: Agent re-validates to ensure consistency

This reactive approach allows natural symbol evolution while maintaining system consistency.

### 3.3 Symbolic Evolution as Refinement

When agents detect symbolic evolution, they should distinguish between:

- **Symbolic refinement**: Enhanced understanding that preserves core intent (e.g., `User` gains `mfa_enabled` field)
- **Intent preservation**: Changes that maintain essential contracts and behavioral meaning
- **Implementation details**: Surface-level changes that don't affect planning structure

Agents should treat most evolution as **refinement** rather than breaking changes, maintaining symbolic stability while allowing natural learning and adaptation.

### 3.4 Create `summary.md` in the feature directory

Provide high-level overview:

- Current implementation status
- Key decisions and trade-offs
- Next steps and dependencies
- Links to related features

---

## 4. Cue Declaration Phase

### 4.1 Use `cue` entries to capture non-binding symbolic guidance

Create `.cues.md` files in the `cues/` directory. Each `cue` must follow the symbolic form:

```smars
(cue cue_identifier
  ⊨ suggests: explanation or possible structure)
```

Cues are:
- Advisory, not mandatory
- Symbolically inspectable
- Used to mark future directions, unresolved tensions, or soft hypotheses

Cues should never affect execution directly. They may later be promoted to plan, contract, or test.

---

## 5. Journal and Notes

Use:
- `journal/` to explore ideas and structure symbolically
- `notes/` to reflect on modeling, theory, edge cases, or meta-level questions

Neither folder is part of the active runtime model but provides context and continuity.

---

## 6. Archival

Retire deprecated, unstable, or exploratory designs to the `archive/` directory. Do not delete symbolic artifacts unless they are invalid; archive instead.

---

## Symbolic Artifact Expectations

| Type                  | Location                    | Must Include                               |
|-----------------------|-----------------------------|--------------------------------------------|
| `declaration.smars.md`| `spec/feature-name/`       | At least one plan, kind, and contract      |
| `implementation.md`   | `spec/feature-name/`       | Interpretation of all declared symbols     |
| `review.md`           | `spec/feature-name/`       | Validation results and cross-feature conflicts |
| `summary.md`          | `spec/feature-name/`       | Status overview and next steps             |
| `*.smars.md`          | `spec/shared/`             | Common symbols used across features        |
| `*.cues.md`           | `cues/`                    | Well-formed advisory cues only             |
| `*.md`                | `notes/`                   | Freeform, unstructured reflection          |
| `*.smars.md`          | `journal/`                 | Unstable symbolic explorations             |

---

## Operating Principles

- A valid SMARS spec is structurally complete, even without implementation.
- Implementation must defer to symbolic declarations.
- Cues exist as soft guidance, not as requirements.
- Tests validate behavior symbolically, not through language-specific tools.
- Archives preserve history of symbolic evolution, not just code.

### Symbolic Stability and Intent Preservation

SMARS operates at the **symbolic planning level**, where specifications evolve through **refinement**, not breaking changes:

- **Symbolic refinement**: New understanding refines existing symbols rather than invalidating them
- **Intent preservation**: Core symbolic meaning (authentication, user identity, data flow) remains constant across evolution
- **Implementation abstraction**: Details like `password` vs `password_hash` are implementation concerns, not planning concerns
- **Agent consensus**: Multiple agents can work with different levels of symbolic detail simultaneously
- **Evolutionary stability**: Essential contracts and plans remain valid as implementation details evolve

When agents detect symbolic evolution, they should treat it as **learning** rather than **breaking changes**. The fundamental planning structure maintains stability while allowing natural refinement of understanding.

---

## License and Structure Use

This SOP is shared to support the development of agentic, symbolic systems. It may be reused, adapted, or forked under the license in this repository.

---
