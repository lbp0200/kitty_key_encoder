# kitty_key_encoder

A Flutter package that encodes Flutter `KeyEvent` to [Kitty Keyboard Protocol](https://sw.kovidgoyal.net/kitty/keyboard-protocol/) escape sequences.

## Why This Library?

Traditional terminal emulators send ambiguous key sequences. For example, `Tab` and `Ctrl+I` both send `\x09`, making it impossible for backend applications to distinguish them.

**Kitty mode** solves this by sending distinct sequences:

| Key Combination | Traditional | Kitty Mode |
|----------------|-------------|------------|
| Tab | `\x09` | `\x1b[29;1u` |
| Ctrl+I | `\x09` | `\x1b[105;5u` |
| Ctrl+Enter | - | `\x1b[13;5u` |
| Shift+Tab | `\x1b[Z` | `\x1b[9;2u` |

This enables full support for complex keyboard shortcuts in Neovim, Emacs, and other terminal applications.

## Features

- **Full key mapping**: F1-F12, arrow keys, navigation keys (Home/End/PageUp/PageDown)
- **Modifier support**: Shift, Alt, Ctrl, Meta with proper bit flag handling
- **Progressive enhancement**: Support for Kitty protocol's extended modes
- **IME handling**: Optional deferral for complex input scenarios
- **Key release events**: Optional reporting of key release events
- **Key repeat support**: Full event type reporting (keyDown, keyRepeat, keyUp)

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

  // Extended mode with event types
  const encoder2 = KittyEncoder(
    flags: KittyEncoderFlags(reportEvent: true),
  );
  print(encoder2.encode(event1)); // \x1b[>1;1;28;1u

  // Key repeat
  const event3 = SimpleKeyEvent(
    logicalKey: LogicalKeyboardKey.arrowUp,
    isKeyRepeat: true,
  );
  print(encoder2.encode(event3)); // \x1b[>1;2;30;1u
}
```

## Integration Guide

### 1. Core Integration (The Bridge)

Connect Flutter's keyboard events to the encoder:

```dart
import 'package:kitty_key_encoder/kitty_key_encoder.dart';

class KeyboardHandler {
  final KittyEncoder encoder;
  final void Function(String) onOutput; // Write to PTY

  KeyboardHandler({
    KittyEncoderFlags? flags,
    required this.onOutput,
  }) : encoder = KittyEncoder(flags: flags ?? const KittyEncoderFlags());

  void onKeyEvent(KeyEvent event) {
    // Convert Flutter KeyEvent to SimpleKeyEvent
    final simpleEvent = SimpleKeyEvent(
      logicalKey: event.logicalKey,
      modifiers: _convertModifiers(event),
      isKeyUp: event is KeyUpEvent,
      isKeyRepeat: event.repeat,
    );

    final sequence = encoder.encode(simpleEvent);
    if (sequence.isNotEmpty) {
      onOutput(sequence);
    } else {
      // Fallback: let system handle unknown keys
    }
  }

  Set<SimpleModifier> _convertModifiers(KeyEvent event) {
    final modifiers = <SimpleModifier>{};
    if (event.modifiers.contains(ModifierKey.shiftModifier)) {
      modifiers.add(SimpleModifier.shift);
    }
    if (event.modifiers.contains(ModifierKey.controlModifier)) {
      modifiers.add(SimpleModifier.control);
    }
    if (event.modifiers.contains(ModifierKey.altModifier)) {
      modifiers.add(SimpleModifier.alt);
    }
    if (event.modifiers.contains(ModifierKey.metaModifier)) {
      modifiers.add(SimpleModifier.meta);
    }
    return modifiers;
  }
}
```

### 2. State Synchronization (The Handshake)

Handle mode changes from backend applications (Neovim, etc.):

```dart
class ModeHandler {
  KittyEncoder _encoder = const KittyEncoder();

  /// Parse CSI > n u sequence from backend
  /// Called when receiving escape sequence from PTY
  void onCsiSequence(String private, List<int> params, String finalChar) {
    if (private == '>' && finalChar == 'u' && params.isNotEmpty) {
      final modeValue = params.first;

      // Update encoder flags based on received mode
      _encoder = _encoder.withFlags(KittyEncoderFlags(
        reportEvent: modeValue & 1 != 0,
        reportAlternateKeys: modeValue & 2 != 0,
        reportAllKeysAsEscape: modeValue & 4 != 0,
      ));
    }
  }

  /// Query current mode (send to backend)
  String queryMode() => '\x1b[>c';

  KittyEncoder get encoder => _encoder;
}
```

### 3. Complete Example

A typical terminal widget integration:

```dart
class TerminalWidget extends StatefulWidget {
  const TerminalWidget({super.key});

  @override
  State<TerminalWidget> createState() => _TerminalWidgetState();
}

class _TerminalWidgetState extends State<TerminalWidget> {
  late final KeyboardHandler _keyboardHandler;
  late final ModeHandler _modeHandler;

  @override
  void initState() {
    super.initState();
    _modeHandler = ModeHandler();
    _keyboardHandler = KeyboardHandler(
      onOutput: (sequence) {
        // Write to PTY process
        pty.write(sequence);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _keyboardHandler.onKeyEvent,
      child: // terminal view
    );
  }
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
- `isKeyRepeat`: Whether this is a key repeat event

### KittyEventType

Event types per Kitty protocol:
- `keyDown`: Event type 1
- `keyRepeat`: Event type 2
- `keyUp`: Event type 3

In extended mode with `reportEvent`, the escape sequence format is:
`\x1b[>flags;event_type;key;modifiersu`

## References

- [Kitty Keyboard Protocol](https://sw.kovidgoyal.net/kitty/keyboard-protocol/)
