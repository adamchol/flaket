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

      perSystem = { pkgs, ... }: {
        formatter = pkgs.nixfmt;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nixfmt
            uv
            python314
            ruff
            ty
          ];

          env = {
            UV_NO_MANAGED_PYTHON = 1;
            UV_PYTHON_DOWNLOADS = "never";
          };

          shellHook = ''
            if [ ! -d "./.venv" ]; then
              uv venv
            fi

            source .venv/bin/activate
          '';
        };
      };
    };
}
