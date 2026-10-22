{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    dnvr.url = "github:dialohq/dnvr";
    dnvr.inputs.nixpkgs.follows = "nixpkgs";
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

      perSystem = { config, pkgs, ... }: {
        formatter = pkgs.nixfmt;

        packages.default =
          let
            manifest = (pkgs.lib.importTOML ./Cargo.toml).package;
          in
          pkgs.rustPlatform.buildRustPackage {
            name = manifest.name;
            version = manifest.version;
            cargoLock.lockFile = ./Cargo.lock;
            src =
              with pkgs.lib.fileset;
              toSource {
                root = ./.;
                fileset = unions [
                  ./Cargo.toml
                  ./Cargo.lock
                  ./src
                ];
              };
          };
        dnvr.shells.default = {
          packages = with pkgs; [
            cargo
            rustc
            clippy
            rust-analyzer
            rustfmt
            nixfmt
          ];
        };
      };
    };
}
