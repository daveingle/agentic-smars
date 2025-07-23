# SMARS – Symbolic Multi‑Agent Reasoning System

> ⚠️ **Status: Developer Workbook / Research Notebook**
> This repository captures my exploratory work on SMARS.  Nothing here is production‑ready and APIs may break without notice.  Future commercial editions (hosted runtime, premium agents, etc.) may be released under different terms in separate repositories.

---

## 1 · What is SMARS?

SMARS is a planning engine that pairs **symbolic specifications** with a **deterministic, multi‑agent runtime**.  Think of it as a project manager that writes its own task list, runs “what‑if” simulations, and iterates from feedback – all expressed in a tiny DSL.

* **Autonomous decomposition** – breaks high‑level goals into concrete steps.
* **Multi‑agent reasoning** – agents debate and vote on next actions.
* **Deterministic replay** – same seed ⇒ identical plan, enabling diff‑based validation.

---

## 2 · Current State (Aug 2025)

| Area                   | Status          | Notes                                          |
| ---------------------- | --------------- | ---------------------------------------------- |
| Core runtime loop      | **Prototype**   | Executes sample specs end‑to‑end.              |
| SMARS DSL grammar      | **Implemented** | Edge‑case parsing & IDE tooling pending.       |
| Multi‑agent bus        | **Prototype**   | Local in‑process; distributed bus stubbed.     |
| External tool adapters | **Stub**        | Calls are simulated; no real side‑effects yet. |
| Deterministic RNG      | **Implemented** | Cryptographic seed swap TBD.                   |
| Validation agent       | **Prototype**   | Heuristic checks only, no formal proofs.       |

### Limitations & Known Issues

* Generates **sample artifacts only** – no real code / documents yet.
* **Local‑only** execution; no sandboxing or security hardening.
* Error handling is minimal – malformed specs can crash the run loop.
* No explicit patent license – consider Apache‑2.0 fork if that matters.

---

## 3 · Capabilities vs Work in Progress

### Functional

* ✔️ Parse goals & emit step hierarchy (toy examples)
* ✔️ Agent dialogue & majority vote selection
* ❌ Real file outputs (WIP)
* ❌ UI / dashboard (planned)

### Non‑functional

* ✔️ Deterministic replays (`--seed`)
* ❌ Performance profiling
* ❌ Secure sandboxing
* ❌ Distributed execution

---

## 4 · Roadmap

| Horizon        | Focus                                                                                                                                       |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| **0–4 weeks**  | • Flesh out file‑generation adapter (Markdown → disk)  • Add basic error boundaries & retries  • Mac‑only install script |
| **1–3 months** | • CLI UX polish  • Experimental web dashboard (local SvelteKit)  • Seed corpus of reusable agent libraries                                  |
| **3–6 months** | • Distributed message bus (NATS prototype)  • Hosted SaaS alpha with team projects  • Formal evaluation paper draft & benchmark suite       |

---

## 5 · Install & Quick Start

```bash
# ⚠️ Verified only on macOS 14 (Apple Silicon)
# Build Rust runtime
cd smars-agent && cargo build

# Run examples
cargo run -- runtime --spec examples/test-plan.smars.md --detailed
cargo run -- agent-demo --comprehensive
cargo run -- check --spec spec/*.smars.md --warnings --format pretty
```

Linux builds are **experimental**.  Windows is untested.

---

## 6 · Repository Layout

```
archive/        Historical design docs and early prototypes
cues/           Standardized cue definitions & evaluation methods
examples/       End‑to‑end demo specs, plans, and validation reports
experiments/    Disposable research spikes and PoCs (Swift, Python)
grammar/        EBNF specs, parser, and test corpus for the SMARS DSL
impl/           Living SMARS specifications (agents, plans, registry)
journal/        Daily research logs and milestone reflections
notes/          Design notes, diagnostics, and validation analyses
requests/       Feature / validation request summaries
smars-agent/    Rust reference implementation + CLI + tests
LICENSE, README.md, … top‑level docs
```

---

## 7 · License & Contributing · License & Contributing

* Code in this repo is licensed under the **MIT License** (see `LICENSE`).
* At this time external pull requests are not being accepted while the project is in its exploratory phase.
  All code in this repository remains under the MIT License.

---

## 8 · Contact

Questions or ideas?  Open an issue or ping **@daveingle** on GitHub.

