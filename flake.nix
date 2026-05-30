{
  description = "Lean 4 incidence geometry project with mathlib and Nix";

  inputs = {
    nixpkgs.follows = "lean4-nix/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    lean4-nix.url = "github:lenianiva/lean4-nix";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      lean4-nix,
      treefmt-nix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      perSystem =
        { system, pkgs, ... }:
        let
          lean430Manifest = {
            tag = "v4.30.0";
            rev = "d024af099ca4bf2c86f649261ebf59565dc8c622";
            toolchain = {
              aarch64-linux = {
                url = "https://github.com/leanprover/lean4/releases/download/v4.30.0/lean-4.30.0-linux_aarch64.tar.zst";
                hash = "sha256-yZxvDt1EaVbUdYxZ1Dg+jmQR/2zHGgH5yqvl66RUEh0=";
              };
              x86_64-linux = {
                url = "https://github.com/leanprover/lean4/releases/download/v4.30.0/lean-4.30.0-linux.tar.zst";
                hash = "sha256-Ta10FBwsEZyhqmJmVr6DuOFCOK+6lycf178es/CBsxk=";
              };
              x86_64-darwin = {
                url = "https://github.com/leanprover/lean4/releases/download/v4.30.0/lean-4.30.0-darwin.tar.zst";
                hash = "sha256-s43YoltbUJbGyQGef/rdvZGiP8tTgnUyJeMxRRV2jKI=";
              };
              aarch64-darwin = {
                url = "https://github.com/leanprover/lean4/releases/download/v4.30.0/lean-4.30.0-darwin_aarch64.tar.zst";
                hash = "sha256-By3KSjj7wNPO25b+qIbMJDtCTyvRYkdZYgC5qauT8PU=";
              };
            };
            inherit (import "${lean4-nix}/manifests/v4.29.1.nix") bootstrap;
            inherit (import "${lean4-nix}/manifests/v4.27.0.nix") buildLeanPackage;
          };
          # lean4-nix's pinned manifest set does not yet include v4.30.0, so this
          # mirrors its binary-toolchain overlay for the version in lean-toolchain.
          lean430Overlay = final: prev: {
            lean =
              (final.callPackage "${lean4-nix}/lib/toolchain.nix" {
                fixDarwinDylibNames = final.writeTextFile {
                  name = "noop-fix-darwin-dylib-names-hook";
                  destination = "/nix-support/setup-hook";
                  text = "";
                };
              }).fetchBinaryLean
                lean430Manifest;
          };
          lake2nix = pkgs.callPackage lean4-nix.lake { };
          leanPackage = lake2nix.mkPackage {
            name = "IncidenceGeometry";
            src = ./.;
          };
          treefmtEval = treefmt-nix.lib.evalModule pkgs {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
            programs.prettier.enable = true;
            settings.formatter.prettier.includes = [
              "*.json"
              "*.md"
              "*.yml"
              "*.yaml"
            ];
          };
        in
        {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            overlays = [ lean430Overlay ];
          };

          packages.default = leanPackage;

          checks = {
            formatting = treefmtEval.config.build.check self;
          }
          // pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
            lean-build = leanPackage;
          };

          formatter = pkgs.writeShellApplication {
            name = "treefmt-check-compatible";
            runtimeInputs = [ treefmtEval.config.build.wrapper ];
            text = ''
              args=()
              for arg in "$@"; do
                if [ "$arg" = "--check" ]; then
                  args+=("--ci")
                else
                  args+=("$arg")
                fi
              done
              exec treefmt "''${args[@]}"
            '';
          };

          devShells.default = pkgs.mkShell {
            packages =
              (with pkgs; [
                elan
                ghostscript
                graphviz
                just
                nixfmt-rfc-style
                nodePackages.prettier
                python3Packages.leanblueprint
                texliveMedium
              ])
              ++ pkgs.lib.optionals pkgs.stdenv.isLinux (
                with pkgs.lean;
                [
                  lean-all
                ]
              );
          };
        };
    };
}
