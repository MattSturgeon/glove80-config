{
  inputs,
  lib,
  ...
}: let
in {
    perSystem = {
      pkgs,
      system,
      ...
    }: let
      inherit (inputs.poetry2nix.lib.mkPoetry2Nix {inherit pkgs;}) mkPoetryApplication;
    in {
      packages = {
        keymap-drawer = mkPoetryApplication {
          projectDir = inputs.keymap-drawer;
          preferWheels = true;
          meta = {
            mainProgram = "keymap";
            homepage = "https://github.com/caksoylar/keymap-drawer";
          };
        };
    };
}
