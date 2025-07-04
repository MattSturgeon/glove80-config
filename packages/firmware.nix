{
  flake,
  pkgs,
}:
let
  inherit (flake.inputs) glove80-zmk;
  firmware = import glove80-zmk { inherit pkgs; };

  keymap = ../config/glove80.keymap;
  kconfig = ../config/glove80.conf;

  left = firmware.zmk.override {
    inherit keymap kconfig;
    board = "glove80_lh";
  };

  right = firmware.zmk.override {
    inherit keymap kconfig;
    board = "glove80_rh";
  };
in
firmware.combine_uf2 left right
