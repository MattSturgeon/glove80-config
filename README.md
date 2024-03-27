# My ZMK config for the MoErgo Glove80

![Photo](img/glove80_photo.png)

This repo contains the current config for my Glove80 keyboard. It is based on [MoErgo's official config](https://github.com/moergo-sc/glove80-zmk-config) and [Gaétan Lepage's flake](https://github.com/GaetanLepage/glove80-zmk-config).

The keymap was initially built using MoErgo's [official Layout Editor](https://my.glove80.com), however now it is maintained [Keymap Editor](https://github.com/nickcoutsos/keymap-editor) and occasional manual tweaking.

The keyboard firmware can be built locally using `nix`, which is also used for [automatic builds](https://github.com/MattSturgeon/glove80-config/actions/workflows/build.yml).

[Keymap Drawer](https://github.com/caksoylar/keymap-drawer) is used to render images of each layer (see below).

## Resources
- @nickcoutsos's [Keymap Editor](https://github.com/nickcoutsos/keymap-editor).
- @caksoylar's [Keymap Drawer](https://github.com/caksoylar/keymap-drawer).
- MoErgo's official [Layout Editor](https://my.glove80.com).
- The [official MoErgo Glove80 Support](https://moergo.com/glove80-support) web site. Glove80 documentation and other technical resources.
- The [official MoErgo Discord Server](https://moergo.com/discord). Instant conversations with other Glove80 users.

- The [official ZMK Documentation](https://zmk.dev/docs) web site. Find the answers to many of your questions about ZMK Firmware.
- The [official ZMK Discord Server](https://discord.gg/8cfMkQksSB). Instant conversations with other ZMK developers and users. Great technical resource!

- The [official Glove80 ZMK Distribution](https://github.com/moergo-sc/zmk). Repository for ZMK firmware customized for Glove80.

## Layers

### Base Layers

The default base layer uses Colemak DH. Some punctuation is moved around using Mod Morphs, and useful stuff is placed on the thumb keys.

![Default](img/glove80_default.svg)

There is a secondary Qwerty base layer available as a fallback:

![Qwerty](img/glove80_qwerty.svg)

### Gaming

A gaming layer extends Qwerty, shifting WASD to a more comfortable position.

![Gaming](img/glove80_gaming.svg)

### Symbols

Readily accessible from a thumb key, the symbols layer attempts to find comfortable positions for commonly used programming symbols.

![Symbols](img/glove80_symbols.svg)

### Numbers & Navigation

Also on the thumb keys, a nav layer has a comfortable numpad and navigation keys.

![Numbers & Navigation](img/glove80_navigation.svg)

I may consider switching from a numpad layout to a 2x 4-finger numrow in an attempt to keep everything closer to the home row. Alternatively, moving the `0` key up may have the same effect.

### MoErgo's Magic Layer

As standard on all Glove80 keyboards, a Magic layer provider access to system utilities, such as Bluetooth settings and RGB lighting config.

![Magic Layer](img/glove80_magic.svg)
 
## Flashing Firmware

If nix is installed with flake support, the easiest method is the `flash` command included in the dev shell (`nix develop`).

This can also be run using `nix run . -- flash` without entering the dev shell.

- Ensure `udisk2` is running...
  - [`services.udisks2.enable`](https://nixos.org/manual/nixos/stable/options#opt-services.udisks2.enable) NixOS option
  - `systemctl status udisks2.service`
  - `udisksctl status`
- Enter shell using `nix develop`
- Connect the **right** half (in bootloader mode)
- Run `flash`
- Connect the **left** half (in bootloader mode)
- Run `flash`
- Done!

## Bootloader Mode

Bootloader mode can be entered two ways:

### With the keyboard half powered off

- Hold the outside bottom-row key (traditionally, `<Ctrl>`)
- Hold the middle-finger row-2 key (Colemak `F` or `U`, Qwerty `E` or `I`)
- Power on the keyboard

### With the keyboard half powered on

- Hold the Magic key
- Tap the outside home-row key (traditionally, `<CAPS>` or `'`)

