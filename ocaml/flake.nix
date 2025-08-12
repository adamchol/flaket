{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/4a7c898ba3992684208d5d64d6077e70c5687314";
    flake-utils.url = "github:numtide/flake-utils/11707dc2f618dd54ca8739b309ec4fc024de578b";
    ocaml-overlays.url = "github:nix-ocaml/nix-overlays/828cc4d2765c6446afa4743678d391152af7e6c5";
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
