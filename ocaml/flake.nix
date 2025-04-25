{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/81bbc0eb0b178d014b95fc769f514bedb26a6127";
    flake-utils.url = "github:numtide/flake-utils";
    ocaml-overlays.url = "github:nix-ocaml/nix-overlays/baeae17459e1150426334f7be3bfe83ec0d752c9";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ocaml-overlays,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          ocaml-overlays.overlays.default
          (final: prev: {ocamlPackages = prev.ocaml-ng.ocamlPackages_5_3;})
          (import ./nix/overlay.nix)
        ];
      };
    in rec {
      packages.default = with pkgs.ocamlPackages;
        buildDunePackage {
          pname = "ocaml-project";
          version = "0.0.1";

          buildInputs = [
            eio_main
          ];
        };

      devShells.default = pkgs.mkShell {
        inputsFrom = [packages.default];
        buildInputs = with pkgs; [
          alejandra
          ocamlPackages.ocaml-lsp
          ocamlformat
        ];
      };
    });
}
