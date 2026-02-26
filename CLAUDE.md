# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

ZMK firmware configuration for a MoErgo Glove80 split keyboard. The keymap is a customized fork of the **TailorKey 4.2m** layout with modifications for Vim-style navigation and tiling window manager workflows (Hyprland on Linux, GlazeWM on Windows).

## Repository Structure

- `glove80_current.json` — Active keymap in Layout Editor format (primary source of truth)
- `glove80_current.keymap` — ZMK devicetree source, kept for backwards compatibility
- `tailorkey_*.json` / `tailorkey_*.keymap` — Upstream TailorKey reference versions (do not modify)
- `zmk-config/glove80.conf` — ZMK build configuration (sleep, pointing device settings)
- `zmk-config/info.json` — Board metadata for the Layout Editor

## Build Workflow

There is no local build system. Firmware is built through the **MoErgo Glove80 Layout Editor** web tool:

1. Import `glove80_current.json` into the Layout Editor
2. Edit in the web UI or modify the `.json` file directly
3. Export from the Layout Editor, build firmware, and flash via USB

The `.json` files are the primary format — they are imported into and exported from the Layout Editor. The `.keymap` files are the ZMK devicetree source kept for potential backwards compatibility.

## Keymap Architecture

21 layers using **Bilateral Home Row Mods (HRM)** — an advanced HRM variant where home-row modifier keys (Ctrl, Shift, Alt, etc.) only trigger when combined with a key pressed by the opposite hand, minimizing misfires while promoting balanced typing. Per-finger modifier isolation layers enforce this bilateral combination requirement:

| Layer | Purpose |
|-------|---------|
| HRM_WinLinx (0) | Base layer with home row mods |
| Typing (1) | Plain typing without HRM |
| Autoshift (2) | Auto-shift behavior |
| LeftPinky–LeftIndex (3–6) | Left-hand HRM isolation layers |
| RightPinky–RightIndex (7–10) | Right-hand HRM isolation layers |
| Cursor (11) | Navigation/arrows (Vim-style HJKL) |
| Symbol (12) | Symbols |
| Mouse (13) | Mouse emulation |
| MouseSlow/Fast/Warp (14–16) | Mouse speed modifiers |
| Gaming (17) | Gaming without HRM |
| Lower (18) | Function keys and media |
| Magic (19) | Bluetooth, RGB, system controls |
| Numbers (20) | Dedicated number row for Super+N workspace switching |

## Key Design Patterns

- **Bilateral HRM isolation**: Each finger has a dedicated modifier layer enforcing opposite-hand-only activation. The `hold-trigger-key-positions` property restricts which keys can trigger the hold behavior.
- **urob zmk-helpers macros**: The keymap uses helper macros (`ZMK_BEHAVIOR`, `ZMK_TAP_DANCE`, etc.) inlined from urob's zmk-helpers for cleaner behavior definitions.
- **Named constants**: Layers are referenced via `LAYER_*` defines, not raw numbers.
- **Explicit shift expressions**: Shifted symbols use explicit key expressions rather than relying on implicit shift.

## Current Customizations vs Upstream TailorKey

### 1. Esc/Tab swap on base layer (HRM_WinLinx)

TailorKey has Tab on row 3 (Q-row, leftmost) and Esc on row 4 (home row, leftmost). These are swapped so Esc is on the upper row and Tab is on the home row — closer to Vim conventions where Esc is used frequently.

### 2. Arrow keys in Vim order on base layer bottom row

TailorKey's bottom-row thumb cluster has arrows in order: Left, Right, ..., Up, Down (left-to-right across both halves). Changed to Left, Down, ..., Up, Right — matching Vim's HJKL directional convention (left, down, up, right).

### 3. Cursor layer arrows in Vim order

TailorKey's Cursor layer (layer 11) has arrow keys on the right-hand home row in order: Left, Up, Down, Right. Changed to Vim order: Left, Down, Up, Right (HJKL convention). The Copy key (`LC(C)`) that originally occupied the Left position was moved to the right of arrow keys to make room.

### 4. Dedicated Numbers layer (layer 20)

Added a new Numbers layer accessed via hold on the Delete key (using `delete_v3_TKZ` hold-tap behavior). Uses regular number keys (N0–N9), not numpad codes — this is intentional because Super+Number workspace switching in Hyprland and GlazeWM requires standard number keycodes. The layer also includes: media controls on top row, Home/End/PgUp/PgDn navigation, left-hand modifiers (GUI/Alt/Ctrl/Shift) on the home row for easy Super+N combos, numpad operators (+, -, *, /, =, dot, enter), and F1–F3/F13 function keys.
The Super and F13 are used in combination with 0-9 keys for various Hyprland and GlazeWM shortcuts.
