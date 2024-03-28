{
  inputs,
  ...
}: {
  perSystem = {
    config,
    pkgs,
    system,
    ...
  }: let
    inherit (inputs.poetry2nix.lib.mkPoetry2Nix {inherit pkgs;}) mkPoetryApplication;
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


      # Draw SVG images of the keymap
      draw = pkgs.writeShellApplication {
        name = "draw";
        runtimeInputs = [
          pkgs.yq-go
          config.packages.keymap-drawer
        ];
        text = ''
          set +e

          out=./img
          keymap_dir=./config

          cmd() {
            keymap --config "$keymap_dir"/keymap_drawer.yaml "$@"
          }

          for file in "$keymap_dir"/*.keymap
          do
            name="$(basename --suffix=".keymap" "$file")"
            config="$out/$name.yaml"
            echo "Found $name keymap"

            echo "- Removing old images"
            rm "$out"/"$name".yaml
            rm "$out"/"$name".svg
            rm "$out"/"$name"_*.svg

            echo "- Parsing keymap-drawer"
            cmd  parse --zmk-keymap "$file" > "$config"

            echo "- Drawing all layers"
            cmd draw "$config" > "$out"/"$name".svg

            layers=$(yq '.layers | keys | .[]' "$config")
            for layer in $layers
            do
              echo "- Drawing $layer layer"
              cmd draw "$config" --select-layers "$layer" > "$out"/"$name"_"$layer".svg
            done
          done
        '';
      };
    };
  };
}
