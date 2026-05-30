# Playground

A small Lean 4 + mathlib project, pinned with Nix, used as a blueprint demo. It
formalises the classical theorem that `√2` is irrational and wires the proof
into a [leanblueprint](https://github.com/PatrickMassot/leanblueprint)
dependency graph published to GitHub Pages.

## Development

Enter the pinned shell:

```sh
nix develop
```

Fetch the mathlib cache and build:

```sh
lake exe cache get
lake build --wfail
```

Run the full local check suite before larger changes:

```sh
nix fmt -- --check .
nix flake check
lake lint
lake test
lake exe mk_all --check
leanblueprint web
leanblueprint checkdecls
python3 blueprint/source_links.py  # GitHub source links for the "Lean" buttons
```
