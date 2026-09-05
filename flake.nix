{
  description = "Collection of commonly use flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem = { pkgs, ... }: {
        formatter = pkgs.nixfmt;

        devShells.default = pkgs.mkShell {
          packages = [ pkgs.nixfmt ];
        };
      };

      flake = {
        templates = {
          trivial = {
            path = ./trivial;
            description = "The most common and basic flake";
          };

          ocaml = {
            path = ./ocaml;
            description = "Flake for basic OCaml project with an overlay";
          };

          python = {
            path = ./python;
            description = "UV-based python project starter";
          };

          rust = {
            path = ./rust;
            description = "Basic cargo-based Rust project.";
          };
        };

        defaultTemplate = inputs.self.templates.trivial;
      };
    };
}
