# Paste

A macOS menu bar app that types your saved text when you press a key combination, in any app. Everything is stored in one local file and the app never uses the network. See `CONTEXT.md` for the vocabulary (Binding, Combo, Text, Pause) and `.scratch/paste/spec.md` for the spec.

## Build and run

Needs macOS 26 and the Swift toolchain (Command Line Tools are enough).

```sh
./setup-signing.sh   # once: creates a local signing certificate so the Accessibility permission survives rebuilds
./build-app.sh       # builds build/Paste.app
open build/Paste.app
```

On first launch Paste asks for the **Accessibility** permission (System Settings → Privacy & Security → Accessibility).

## Test

```sh
./test.sh
```

`./test.sh` wraps `swift test` with the flags the Command Line Tools need to find Swift Testing. Tests cover `PasteCore`, which has no macOS code. The menu bar, key recorder, typing and permission screens are checked by hand.

## Layout

- `Sources/PasteCore`: Bindings, Pause, duplicate and system-Combo checks, storage.
- `Sources/Paste`: the app (popover, Settings window, key listener, typer).

Bindings are saved in `~/Library/Application Support/Paste/bindings.json`.
