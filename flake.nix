{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    glove80-zmk = {
      url = "github:moergo-sc/zmk";
      flake = false;
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = inputs.nixpkgs.lib.systems.flakeExposed;

      imports = [
        ./flake-pkgs.nix
        ./packages/flake-module.nix
      ];

      perSystem =
        {
          config,
          pkgs,
          ...
        }:
        {
          # `nix run`
          apps.default.program = config.packages.flash;

          # `nix build`
          packages.default = config.packages.firmware;

          formatter = pkgs.nixfmt-tree;
        };
    };
}
