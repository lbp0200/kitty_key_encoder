# kitty_key_encoder

A Flutter package that encodes Flutter `KeyEvent` to [Kitty Keyboard Protocol](https://sw.kovidgoyal.net/kitty/keyboard-protocol/) escape sequences.

## Purpose

This package is designed for Flutter terminal emulators. It converts Flutter keyboard events into properly formatted escape sequences that terminal applications (shells, Neovim, etc.) can understand.

## Features

- **Full key mapping**: F1-F12, arrow keys, navigation keys (Home/End/PageUp/PageDown)
- **Modifier support**: Shift, Alt, Ctrl, Meta with proper bit flag handling
- **Progressive enhancement**: Support for Kitty protocol's extended modes
- **IME handling**: Optional deferral for complex input scenarios
- **Key release events**: Optional reporting of key release events

## Installation

```yaml
dependencies:
  kitty_key_encoder: ^1.0.0
```

## Usage

```dart
import 'package:kitty_key_encoder/kitty_key_encoder.dart';

void main() {
  const encoder = KittyEncoder();

  // Simple key
  final event1 = SimpleKeyEvent(logicalKey: LogicalKeyboardKey.enter);
  print(encoder.encode(event1)); // \x1b[28;1u

  // With modifier
  final event2 = SimpleKeyEvent(
    logicalKey: LogicalKeyboardKey.enter,
    modifiers: {SimpleModifier.control},
  );
  print(encoder.encode(event2)); // \x1b[13;5u

  // Extended mode
  const encoder2 = KittyEncoder(
    flags: KittyEncoderFlags(reportEvent: true),
  );
  print(encoder2.encode(event1)); // \x1b[>1;28;1u
}
```

## Key Codes

| Key | Code |
|-----|------|
| F1-F12 | 11-24 |
| Arrow Up/Down/Right/Left | 30-33 |
| Home/End | 36-37 |
| PageUp/PageDown | 34-35 |
| Enter | 28 |
| Tab | 29 |
| Escape | 53 |

## Modifier Codes

| Modifier | Bit | Value (+1 offset) |
|----------|-----|-------------------|
| Shift | 1 | 2 |
| Alt | 2 | 3 |
| Ctrl | 4 | 5 |
| Super/Meta | 8 | 9 |

## API Reference

### KittyEncoder

Main encoder class with `encode(SimpleKeyEvent)` method.

### KittyEncoderFlags

Configuration flags:
- `reportEvent`: Report key release events
- `reportAlternateKeys`: Report alternate key representations
- `reportAllKeysAsEscape`: Report all keys as escape sequences
- `deferToSystemOnComplexInput`: Handle IME/text input conflicts

### SimpleKeyEvent

Key event class with:
- `logicalKey`: The keyboard key
- `modifiers`: Set of modifiers (shift, control, alt, meta)
- `isKeyUp`: Whether this is a key release event

## References

- [Kitty Keyboard Protocol](https://sw.kovidgoyal.net/kitty/keyboard-protocol/)
