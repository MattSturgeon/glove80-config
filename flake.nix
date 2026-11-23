{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-pr.url = "github:nixos/nixpkgs?ref=pull/450602/merge";
    glove80-zmk = {
      # PR#41 `can` → `python-can`
      url = "github:moergo-sc/zmk/pull/41/merge";
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
