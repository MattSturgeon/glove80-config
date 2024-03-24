{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    glove80-zmk = {
      url = "github:moergo-sc/zmk";
      flake = false;
    };
    keymap-drawer = {
      url = "github:caksoylar/keymap-drawer";
      flake = false;
    };
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    glove80-zmk,
    keymap-drawer,
    poetry2nix,
    flake-parts,
    devshell,
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [
        inputs.devshell.flakeModule
      ];

      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: {
        packages.default = let
          firmware = import glove80-zmk {inherit pkgs;};

          keymap = ./config/glove80.keymap;
          kconfig = ./config/glove80.conf;

          glove80_left = firmware.zmk.override {
            inherit keymap kconfig;
            board = "glove80_lh";
          };

          glove80_right = firmware.zmk.override {
            inherit keymap kconfig;
            board = "glove80_rh";
          };
        in
          firmware.combine_uf2 glove80_left glove80_right;

        packages.keymap-drawer = let
          inherit (poetry2nix.lib.mkPoetry2Nix {inherit pkgs;}) mkPoetryApplication;
        in
          mkPoetryApplication {
            projectDir = keymap-drawer;
            preferWheels = true;
          };

        devshells.default.commands = [
          {
            name = "flash";
            command = /*bash*/ ''
              set +e

              root="/run/media/$(whoami)"
              dest_folder_name=$(ls $root | grep GLV80)
              dest="$root"/"$dest_folder_name"

              if [[ -n "$dest_folder_name" && -d "$dest" ]]; then
                echo Flashing to "$dest"
                cp ${config.packages.default}/glove80.uf2 "$dest"/CURRENT.UF2
                exit 0
              else
                echo "Error: Glove80 keyboard is not plugged-in"
                exit 1
              fi
            '';
            help = "builds the firmware and copies it to the plugged-in keybaord half";
          }
        ];

        formatter = pkgs.alejandra;
      };
    };
}
