{
  description = "Collection of commonly use flakes";

  outputs = {self}: {
    templates = {
      trivial = {
        path = ./trivial;
        description = "The most common and basic flake";
      };
    };

    defaultTemplate = self.templates.trivial;
  };
}
