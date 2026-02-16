import 'package:flutter/services.dart';
import 'kitty_key_codes.dart';
import 'kitty_modifier_codes.dart';
import 'kitty_flags.dart';

/// Event types per Kitty Keyboard Protocol
enum KittyEventType {
  /// Key down event (type 1)
  keyDown(1),
  /// Key repeat event (type 2)
  keyRepeat(2),
  /// Key up event (type 3)
  keyUp(3);

  final int value;
  const KittyEventType(this.value);
}

/// Simple key event class for testing - wraps LogicalKeyboardKey with modifiers
class SimpleKeyEvent {
  final LogicalKeyboardKey logicalKey;
  final Set<SimpleModifier> modifiers;
  final bool isKeyUp;
  final bool isKeyRepeat;

  const SimpleKeyEvent({
    required this.logicalKey,
    this.modifiers = const {},
    this.isKeyUp = false,
    this.isKeyRepeat = false,
  });

  /// Get the event type for Kitty protocol
  KittyEventType get eventType {
    if (isKeyUp) return KittyEventType.keyUp;
    if (isKeyRepeat) return KittyEventType.keyRepeat;
    return KittyEventType.keyDown;
  }
}

/// Simple modifier enum for key events
enum SimpleModifier {
  shift,
  control,
  alt,
  meta,
}

/// Kitty Encoder - converts Flutter KeyEvent to Kitty escape sequences
///
/// Supports both [KeyEvent] from Flutter and [SimpleKeyEvent] for testing.
class KittyEncoder {
  final KittyEncoderFlags flags;

  const KittyEncoder({this.flags = const KittyEncoderFlags()});

  bool get isExtendedMode => flags.isExtendedMode;

  String encode(SimpleKeyEvent event) {
    final keyCode = KittyKeyCodes.getKeyCode(event.logicalKey);
    if (keyCode == null) {
      return '';
    }

    final modifierFlags = _extractModifiers(event);
    final modifiers = KittyModifierCodes.calculateModifiers(modifierFlags);

    // Handle IME/text editing conflict
    // When deferToSystemOnComplexInput is enabled and we have printable
    // characters with modifiers (like Ctrl+Letter), return empty to let
    // system handle it
    if (flags.deferToSystemOnComplexInput && modifierFlags != 0) {
      if (_isPrintableKey(event.logicalKey)) {
        return '';
      }
    }

    // Apply modifier-specific key code offset per Kitty protocol
    int effectiveKeyCode = keyCode;
    if (modifierFlags & KittyModifierCodes.ctrl != 0) {
      effectiveKeyCode -= 15; // Ctrl offsets key code by -15
    } else if (modifierFlags & KittyModifierCodes.shift != 0) {
      effectiveKeyCode -= 20; // Shift offsets key code by -20
    } else if (modifierFlags & KittyModifierCodes.alt != 0) {
      effectiveKeyCode -= 10; // Alt offsets key code by -10
    }

    // Build the escape sequence
    String sequence;
    if (flags.isExtendedMode) {
      final csiValue = flags.toCSIValue();

      // When reportEventTypes is enabled, include event_type in the sequence
      if (flags.reportEvent) {
        // Format: \x1b[>flags;event_type;key;modifiersu
        sequence = '\x1b[>$csiValue;${event.eventType.value};$effectiveKeyCode;${modifiers}u';
      } else {
        sequence = '\x1b[>$csiValue;$effectiveKeyCode;${modifiers}u';
      }
    } else {
      sequence = '\x1b[$effectiveKeyCode;${modifiers}u';
    }

    // Handle key release events in non-extended mode (using ~ prefix)
    // Note: In extended mode with reportEvent, we use event_type instead
    if (!flags.isExtendedMode && flags.reportEvent && event.isKeyUp) {
      sequence = '~$sequence';
    }

    return sequence;
  }

  bool _isPrintableKey(LogicalKeyboardKey key) {
    // Check if key is a printable character (A-Z, a-z, 0-9, symbols)
    final keyLabel = key.keyLabel;
    if (keyLabel.isEmpty) return false;

    // Check for alphanumeric and common printable characters
    final code = key.keyId;
    // Printable ASCII range: 0x1D (29) to 0x7E (126)
    return (code >= 0x1D && code <= 0x7E);
  }

  int _extractModifiers(SimpleKeyEvent event) {
    int flags = 0;

    if (event.modifiers.contains(SimpleModifier.shift) ||
        event.logicalKey == LogicalKeyboardKey.shiftLeft ||
        event.logicalKey == LogicalKeyboardKey.shiftRight) {
      flags |= KittyModifierCodes.shift;
    }

    if (event.modifiers.contains(SimpleModifier.alt) ||
        event.logicalKey == LogicalKeyboardKey.altLeft ||
        event.logicalKey == LogicalKeyboardKey.altRight) {
      flags |= KittyModifierCodes.alt;
    }

    if (event.modifiers.contains(SimpleModifier.control) ||
        event.logicalKey == LogicalKeyboardKey.controlLeft ||
        event.logicalKey == LogicalKeyboardKey.controlRight) {
      flags |= KittyModifierCodes.ctrl;
    }

    if (event.modifiers.contains(SimpleModifier.meta) ||
        event.logicalKey == LogicalKeyboardKey.metaLeft ||
        event.logicalKey == LogicalKeyboardKey.metaRight) {
      flags |= KittyModifierCodes.superKey;
    }

    return flags;
  }

  KittyEncoder withFlags(KittyEncoderFlags newFlags) {
    return KittyEncoder(flags: newFlags);
  }
}
