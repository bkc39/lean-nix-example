# Agent Instructions

This is a Lean 4/mathlib project. Lake is the Lean package source of truth;
Nix pins the outer development and CI environment.

After code changes, run the relevant local checks:

- `nix fmt -- --check .`
- `nix flake check`
- `lake build --wfail`
- `lake lint`
- `lake test`
- `lake exe mk_all --check`
- `leanblueprint web`
- `leanblueprint checkdecls`

Use the mathlib cache before local Lean builds when dependencies are not yet
materialized:

- `lake exe cache get`

For proof planning, prefer current mathlib documentation/search and tools such
as LeanSearch, Moogle, Loogle, LeanExplore, import/dependency graphs, module
docstrings, and Zulip/mathlib community review for large design choices.
