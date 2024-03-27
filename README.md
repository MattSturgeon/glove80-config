# My ZMK config for the MoErgo Glove80

![Photo](img/glove80_photo.png)

Based on [MoErgo's template](https://github.com/moergo-sc/glove80-zmk-config) and [Gaétan Lepage's flake](https://github.com/GaetanLepage/glove80-zmk-config).

This repo contains the current config for my Glove80 keyboard.
The keymap was initially built using MoErgo's [Layout Editor](https://my.glove80.com),
however it is now maintained using [Keymap Editor] with occasional manual tweaking.

The keyboard firmware can be built locally using `nix`, which is also used for [automatic builds](https://github.com/MattSturgeon/glove80-config/actions/workflows/build.yml).

[Keymap Drawer] is used to render images of each layer (see below).

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

## Resources
- [@nickcoutsos]'s [Keymap Editor].
- [@caksoylar]'s [Keymap Drawer].

- [Glove80 User Guide](https://docs.moergo.com/glove80-user-guide).
- MoErgo's [Glove80 Support](https://moergo.com/glove80-support) page.
- MoErgo's [Discord Server](https://moergo.com/discord).

- [ZMK Documentation](https://zmk.dev/docs).
- ZMK's [Discord Server](https://discord.gg/8cfMkQksSB).

- MoErgo's [ZMK Distribution](https://github.com/moergo-sc/zmk).

[@nickcoutsos]: https://github.com/nickcoutsos
[@caksoylar]: https://github.com/caksoylar
[Keymap Editor]: https://github.com/nickcoutsos/keymap-editor
[Keymap Drawer]: https://github.com/caksoylar/keymap-drawer
