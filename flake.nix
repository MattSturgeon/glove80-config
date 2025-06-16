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
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = nixpkgs.lib.systems.flakeExposed;

      imports = [
        ./packages
      ];

      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: {
        # `nix run`
        apps.default = {
          type = "app";
          program = config.packages.flash;
        };

        # `nix build`
        packages.default = config.packages.firmware;

        formatter = pkgs.alejandra;
      };
    };
}
