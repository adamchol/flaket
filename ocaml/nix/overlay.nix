final: prev: let
  inherit (prev) fetchFromGitHub;
in {
  ocamlPackages =
    prev.ocamlPackages.overrideScope (ofinal: oprev: {
    });
}
