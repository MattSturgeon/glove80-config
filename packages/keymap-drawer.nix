{lib, inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.keymap-drawer = let
      src = inputs.keymap-drawer;
      pyproject = lib.importTOML "${src}/pyproject.toml";
    # TODO: upstream to nixpkgs
    in pkgs.python3Packages.buildPythonApplication {
      pname = pyproject.project.name;
      inherit (pyproject.project) version;
      inherit src;

      pyproject = true;
      build-system = with pkgs.python3Packages; [
        poetry-core
      ];

      dependencies = with pkgs.python3Packages; [
        pcpp
        platformdirs
        pydantic
        pydantic-settings
        pyparsing
        pyyaml
        tree-sitter
        tree-sitter-grammars.tree-sitter-devicetree
      ];

      doCheck = true;
      pythonImportsCheck = [ "keymap_drawer" ];

      doInstallCheck = true;
      nativeInstallCheckInputs = [
        pkgs.versionCheckHook
      ];
      versionCheckProgramArg = "--version";

      meta = {
        mainProgram = "keymap";
        homepage = "https://github.com/caksoylar/keymap-drawer";
      };
    };
  };
}
