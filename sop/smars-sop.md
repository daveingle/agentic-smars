# SMARS Standard Operating Procedure

This document defines the structured process for creating, interpreting, and iterating on symbolic specifications written in SMARS — the Symbolic Multi-Agent Reasoning System.

It is intended for use by agents (human or AI) that reason over plans, contracts, data structures, and tests in a deterministic, verifiable, and context-free way.

This SOP does not assume any specific programming framework or runtime.

---

## 1. Specification Phase

### 1.1 Create a `.smars.md` file in `spec/`

Declare symbolic structure using the SMARS grammar. A complete specification includes:

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

### 2.1 Create a `.implementation.md` file in `impl/`

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

- Validate all `contract` requirements and postconditions in code or test logic
- Implement or simulate all `test` cases
- Confirm `plan` flows execute deterministically from the symbolic spec
- Check that `branch` conditions resolve to correct paths

Validation may be done manually, via interpreters, or through external runtime agents.

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

| Type                  | Location     | Must Include                               |
|-----------------------|-------------|--------------------------------------------|
| `*.smars.md`          | `spec/`     | At least one plan, kind, and contract      |
| `*.implementation.md` | `impl/`     | Interpretation of all declared symbols     |
| `*.cues.md`           | `cues/`     | Well-formed advisory cues only             |
| `*.md`                | `notes/`    | Freeform, unstructured reflection          |
| `*.smars.md`          | `journal/`  | Unstable symbolic explorations             |

---

## Operating Principles

- A valid SMARS spec is structurally complete, even without implementation.
- Implementation must defer to symbolic declarations.
- Cues exist as soft guidance, not as requirements.
- Tests validate behavior symbolically, not through language-specific tools.
- Archives preserve history of symbolic evolution, not just code.

---

## License and Structure Use

This SOP is shared to support the development of agentic, symbolic systems. It may be reused, adapted, or forked under the license in this repository.

---
