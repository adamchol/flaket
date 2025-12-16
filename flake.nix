{
  description = "Collection of commonly use flakes";

  outputs = {self}: {
    templates = {
      trivial = {
        path = ./trivial;
        description = "The most common and basic flake";
      };

      ocaml = {
        path = ./ocaml;
        description = "Flake for basic OCaml project with an overlay";
      };

      python = {
        path = ./python;
        description = "UV-based python project starter";
      };

      rust = {
        path = ./rust;
        description = "Basic cargo-based Rust project.";
      };
    };

    defaultTemplate = self.templates.trivial;
  };
}
