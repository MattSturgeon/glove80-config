{
  lib,
  self,
  inputs,
  ...
}:
let
  inherit (builtins)
    mapAttrs
    removeAttrs
    toString
    readDir
    ;
  inherit (lib.trivial)
    flip
    ;
  inherit (lib.attrsets)
    filterAttrs
    mapAttrs'
    ;
  inherit (lib.strings)
    hasSuffix
    removeSuffix
    ;
in
{
  perSystem =
    {
      pkgs,
      self',
      inputs',
      ...
    }:
    let
      # TODO: simplify with an overlay
      callPackage = lib.callPackageWith (
        pkgs
        // {
          flake = {
            inherit (self') packages;
            inherit
              self
              self'
              inputs
              inputs'
              ;
          };
        }
      );
    in
    {
      packages = lib.pipe ./. [
        readDir
        (flip removeAttrs [ "flake-module.nix" ])
        (mapAttrs (name: type: if type == "directory" then ./${name}/package.nix else ./${name}))
        (filterAttrs (name: pkg: hasSuffix ".nix" (toString pkg)))
        (filterAttrs (name: lib.pathIsRegularFile))
        (mapAttrs' (name: pkg: lib.nameValuePair (removeSuffix ".nix" name) (callPackage pkg { })))
      ];
    };
}
