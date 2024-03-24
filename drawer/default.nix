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
      pkg = config.packages.keymap-drawer;
      exe = lib.getExe pkg;
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

        keymap-drawer-configs = pkgs.runCommand "configs" {} ''
          echo "writing config to $out"
          mkdir -p $out

          # TODO set generic vars in one place globally
          CONFIG="${../config/keymap_drawer.yaml}"

          # TODO consider running through `parallel`?
          for KEYMAP in ${ ../config }/*.keymap; do
            KEYBOARD=$(basename -s .keymap "$KEYMAP")
            OUTPUT="$out"/"$KEYBOARD".yaml

            echo "Parsing keymap for $KEYBOARD"
            # ${exe} -c "$CONFIG" parse -z "$KEYMAP" > "$OUTPUT"
            ${exe} parse -z "$KEYMAP" > "$OUTPUT"
          done
        '';
      };
    };
}
