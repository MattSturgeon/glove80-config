{ lib, ... }:
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
    { pkgs, ... }:
    {
      packages = lib.pipe ./. [
        readDir
        (flip removeAttrs [ "flake-module.nix" ])
        (mapAttrs (name: type: if type == "directory" then ./${name}/package.nix else ./${name}))
        (filterAttrs (name: pkg: hasSuffix ".nix" (toString pkg)))
        (filterAttrs (name: lib.pathIsRegularFile))
        (mapAttrs' (name: pkg: lib.nameValuePair (removeSuffix ".nix" name) (pkgs.callPackage pkg { })))
      ];
    };
}
