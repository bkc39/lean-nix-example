# IncidenceGeometry

A Lean 4 project for incidence geometry, using mathlib and pinned with Nix.

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
```
