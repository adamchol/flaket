{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/3a27eb4be1a058b1218aa06775bf1ac077adbba2";
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
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          alejandra
          uv
          python314
          ruff
          pyright
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
    });
}
