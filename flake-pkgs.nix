{ self, inputs, ... }:
{
  perSystem =
    {
      system,
      self',
      inputs',
      ...
    }:
    let
      overlay = final: prev: {
        # Include attributes from this flake in `pkgs`, allowing packages
        # imported with `callPackage` to access them.
        flake = {
          inherit (self') packages;
          inherit
            self
            self'
            inputs
            inputs'
            ;
        };
      };
    in
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          overlay
        ];
      };
    };
}
