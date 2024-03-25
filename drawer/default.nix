{
  inputs,
  lib,
  ...
}:
with builtins;
with lib; {
  perSystem = {
    config,
    pkgs,
    system,
    ...
  }: let
    inherit (inputs.poetry2nix.lib.mkPoetry2Nix {inherit pkgs;}) mkPoetryApplication;

    getKeymapFiles = dir:
      mapAttrsToList (name: _: dir + "/${name}") (filterAttrs (name: type: hasSuffix ".keymap" name && type != "directory") (readDir dir));

    # Nix can't import yaml, so use `yj` to convert to JSON 😢
    importYaml = file: let
      jsonFile = pkgs.runCommandNoCC "converted-yaml.json" {} ''
        ${getExe pkgs.yj} < "${file}" > "$out"
      '';
    in
      importJSON jsonFile;

    pkg = config.packages.keymap-drawer;
    exe = getExe pkg;

    parsedPkg = config.packages.keymap-drawer-parsed;

    # List of parsed keyboard configs, complete with various metadata
    parsedCfgs = mapAttrsToList (fname: type:
      assert hasSuffix ".yaml" fname;
      assert type != "directory"; rec {
        file = parsedPkg + "/${fname}";
        name = removeSuffix ".yaml" fname;
        data = importYaml file;
        layers = attrNames data.layers;
      }) (readDir parsedPkg);

    keymapFiles = getKeymapFiles ../config;
    configFile = ../config/keymap_drawer.yaml;
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

      keymap-drawer-parsed = pkgs.symlinkJoin {
        name = "configs";
        paths = map (file: let
          name = removeSuffix ".keymap" (baseNameOf file);
        in
          pkgs.runCommandNoCC "${name}-parsed" {} ''
            echo "Parsing keymap for ${name}"
            mkdir -p "$out"

            # Create a temp link because keymap-drawer uses the file's stem
            # to guess the keyboard name...
            # Using `file` directly won't work because it has a nar hash prefix.
            # FIXME find workaround upstream
            LINK="$out/${baseNameOf file}"
            ln -s "${file}" "$LINK"

            ${exe} --config "${configFile}" \
              parse --zmk-keymap "$LINK" \
              > "$out/${name}.yaml"

            # Cleanup temp link
            rm "$LINK"
          '')
        keymapFiles;
      };

      keymap-drawer-svgs = pkgs.symlinkJoin {
        name = "keymap-drawer-svgs";
        paths =
          concatMap (
            {
              file,
              name,
              layers,
              ...
            }:
              [
                (pkgs.runCommandNoCC "${name}-all" {} ''
                  echo "Drawing all layers for ${name}"
                  mkdir -p "$out"
                  ${exe} --config "${configFile}" \
                    draw "${file}" \
                    > "$out/${name}.svg"
                '')
              ]
              ++ (map (layer:
                pkgs.runCommandNoCC "${name}-${layer}" {} ''
                  echo "Drawing ${layer} layer for ${name}"
                  mkdir -p "$out"
                  ${exe} --config "${configFile}" \
                    draw "${file}" \
                    --select-layers "${layer}" \
                    > "$out/${name}-${layer}.svg"
                '')
              layers)
          )
          parsedCfgs;
      };
    };
  };
}
