{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    poetry2nix = inputs.poetry2nix.lib.mkPoetry2Nix {inherit pkgs;};
  in {
    packages.keymap-drawer = poetry2nix.mkPoetryApplication {
      projectDir = inputs.keymap-drawer;
      preferWheels = true;
      meta = {
        mainProgram = "keymap";
        homepage = "https://github.com/caksoylar/keymap-drawer";
      };
    };
  };
}
