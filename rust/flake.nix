{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/2fad6eac6077f03fe109c4d4eb171cf96791faa4";
    flake-utils.url = "github:numtide/flake-utils/11707dc2f618dd54ca8739b309ec4fc024de578b";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      packages.default = let
        manifest = (pkgsRust.lib.importTOML ./Cargo.toml).package;
      in
        pkgsRust.rustPlatform.buildRustPackage {
          name = manifest.name;
          version = manifest.version;
          cargoLock.lockFile = ./Cargo.lock;
          src = with pkgsRust.lib.fileset;
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
        inputsFrom = [self.packages.${system}.default];
        buildInputs = with pkgs; [
          rust-analyzer
          rustfmt
          nixfmt-rfc-style
        ];
      };
    });
}
