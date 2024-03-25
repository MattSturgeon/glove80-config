{
  inputs,
  lib,
  ...
}: let
in {
    perSystem = {
      config,
      pkgs,
      system,
      ...
    }: let
      inherit (inputs.poetry2nix.lib.mkPoetry2Nix {inherit pkgs;}) mkPoetryApplication;

      exe = lib.getExe config.packages.keymap-drawer;
      yq = lib.getExe pkgs.yq-go;
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
    };

      devshells.default.commands = [
        {
          name = "draw";
          command = /*bash*/ ''
            set +e

            out="$PRJ_ROOT"/img
            keymap_dir="$PRJ_ROOT"/config
            cmd="${exe} --config $keymap_dir/keymap_drawer.yaml"

            echo "Removing previous images"
            rm "$out"/*

            for file in "$keymap_dir"/*.keymap
            do
              name="$(basename --suffix=".keymap" "$file")"
              config="$out/$name.yaml"
              echo "Found $name keymap"

              echo "- Parsing keymap-drawer"
              $cmd  parse --zmk-keymap "$file" > "$config"

              echo "- Drawing all layers"
              $cmd draw "$config" > "$out"/"$name".svg

              layers=$(${yq} '.layers | keys | .[]' "$config")
              for layer in $layers
              do
                echo "- Drawing $layer layer"
                $cmd draw "$config" --select-layers "$layer" > "$out"/"$name"_"$layer".svg
              done
            done
          '';
          help = "Draw SVG images of the keymap";
        }
      ];
  };
}
