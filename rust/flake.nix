{
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
        devShells.default = pkgs.mkShell {
          inputsFrom = [ config.packages.default ];
          buildInputs = with pkgs; [
            rust-analyzer
            rustfmt
            nixfmt
          ];
        };
      };
    };
}
