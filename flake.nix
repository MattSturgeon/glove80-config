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
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    glove80-zmk,
    keymap-drawer,
    poetry2nix,
    flake-parts,
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = nixpkgs.lib.systems.flakeExposed;

      imports = [
        ./drawer
      ];

      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: {
        # `nix build`
        packages.default = let
          firmware = import glove80-zmk {inherit pkgs;};

          keymap = ./config/glove80.keymap;
          kconfig = ./config/glove80.conf;

          glove80_left = firmware.zmk.override {
            inherit keymap kconfig;
            board = "glove80_lh";
          };

          glove80_right = firmware.zmk.override {
            inherit keymap kconfig;
            board = "glove80_rh";
          };
        in
          firmware.combine_uf2 glove80_left glove80_right;

        # `nix run`
        apps.default = {
          type = "app";
          program = config.packages.flash;
        };

        # Builds the firmware and copies it to the plugged-in keyboard half
        packages.flash = pkgs.writeShellApplication {
          name = "flash";
          text = ''
            set +e

            # Disable -u because empty arrays are treated as "unbound"
            set +u

            # Enable nullglob so that non-matching globs have no output
            shopt -s nullglob

            # Indent piped input 4 spaces
            indent() {
              sed -e 's/^/    /'
            }

            # Platform specific disk candidates
            declare -a disks
            if [[ "$OSTYPE" == "linux-gnu"* ]]; then
              # Linux/GNU
              # - /run/media/<user>/<disk>
              disks=(/run/media/"$(whoami)"/GLV80*)
            elif [[ "$OSTYPE" == "darwin"* ]]; then
              # Mac OSX
              # - /Volumes/<disk>
              disks=(/Volumes/GLV80*)
            elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
              # Cygwin or Msys2
              # - /<drive letter>
              disks=(/?)
            elif (grep -sq Microsoft /proc/version); then
              # WSL
              # - /mnt/<drive letter>
              disks=(/mnt/?)
            else
              echo "Error: Unable to detect platform!"
              echo "OSTYPE=$OSTYPE"
              echo "/proc/version"
              indent < /proc/version
              exit 1
            fi

            # Disks that have a matching INFO_UF2
            declare -a matches
            for disk in "''${disks[@]}"; do
              if (grep -sq Glove80 "$disk"/INFO_UF2.TXT); then
                matches+=("$disk")
              fi
            done

            # Assert we found exactly one keyboard
            count="''${#matches[@]}"
            if [[ "$count" -lt 1 ]]; then
              # No matches. Exit
              echo "Error: No Glove80 connected!"
              exit 1
            elif [[ "$count" -gt 1 ]]; then
              # Multiple matches. Print them and exit
              echo "Error: $count Glove80s connected. Expected 1!"
              for i in "''${!matches[@]}"; do
                kb="''${matches[$i]}"
                # Print the relevant lines from INFO_UF2
                echo "$((i + 1)). $kb"
                grep --no-filename --color=never Glove80 "$kb"/INFO_UF2.TXT | indent
              done
              exit 1
            fi

            # We have a winner!
            kb="''${matches[0]}"
            echo "Found keyboard:"
            echo "$kb"
            indent < "$kb"/INFO_UF2.TXT
            echo

            # Flash by copying the firmware package
            echo "Flashing firmware..."
            cp -r "${config.packages.default}" "$kb" \
              && echo "Done!" || echo "Error: Unable to flash firmware!"
          '';
        };

        formatter = pkgs.alejandra;
      };
    };
}
