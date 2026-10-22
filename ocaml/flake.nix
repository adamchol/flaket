{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    dnvr.url = "github:dialohq/dnvr";
    dnvr.inputs.nixpkgs.follows = "nixpkgs";
    ocaml-overlays.inputs.nixpkgs.follows = "nixpkgs";
    ocaml-overlays.url = "github:nix-ocaml/nix-overlays/7c53d7861587897b5bd33056a23a99c18b2716a7";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      imports = [ inputs.dnvr.flakeModule ];

      perSystem =
        {
          config,
          pkgs,
          system,
          ...
        }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              inputs.ocaml-overlays.overlays.default
              (final: prev: { ocamlPackages = prev.ocaml-ng.ocamlPackages_5_4; })
              (import ./nix/overlay.nix)
            ];
          };

          formatter = pkgs.nixfmt;

          packages.default =
            with pkgs.ocamlPackages;
            buildDunePackage {
              pname = "ocaml-project";
              version = "0.0.1";

              buildInputs = [
                eio_main
              ];
            };

          dnvr.shells.default = {
            packages =
              config.packages.default.nativeBuildInputs
              ++ config.packages.default.buildInputs
              ++ (with pkgs; [
                nixfmt
                ocamlPackages.ocaml-lsp
                ocamlformat
              ]);
            shellHook = ''
              export PATH=$PATH:$DNVR_ROOT/_build/install/default/bin
            '';
          };
        };
    };
}
