{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/f98e6d6d045102d2e2cd3c527c6a2eca18386192";
    flake-utils.url = "github:numtide/flake-utils/11707dc2f618dd54ca8739b309ec4fc024de578b";
    ocaml-overlays.url = "github:nix-ocaml/nix-overlays/f98e6d6d045102d2e2cd3c527c6a2eca18386192";
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
        shellHook = ''
          export PATH=$PATH:$(pwd)/_build/install/default/bin
        '';
      };
    });
}
