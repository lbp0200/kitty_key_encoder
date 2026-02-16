/// Progressive enhancement flags for Kitty Keyboard Protocol
class KittyEncoderFlags {
  /// Report key release events (bit 0)
  final bool reportEvent;

  /// Report alternate key representations (bit 1)
  final bool reportAlternateKeys;

  /// Report all keys as escape sequences (bit 2)
  final bool reportAllKeysAsEscape;

  /// When enabled, defer to system for printable characters with modifiers
  /// This helps handle IME/text input conflicts
  final bool deferToSystemOnComplexInput;

  const KittyEncoderFlags({
    this.reportEvent = false,
    this.reportAlternateKeys = false,
    this.reportAllKeysAsEscape = false,
    this.deferToSystemOnComplexInput = false,
  });

  /// Convert flags to CSI > value
  int toCSIValue() {
    int value = 0;
    if (reportEvent) value |= 1;
    if (reportAlternateKeys) value |= 2;
    if (reportAllKeysAsEscape) value |= 4;
    return value;
  }

  /// Check if extended mode is active
  bool get isExtendedMode => toCSIValue() != 0;
}
