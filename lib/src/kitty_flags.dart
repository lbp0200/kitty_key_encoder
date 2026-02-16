/// Progressive enhancement flags for Kitty Keyboard Protocol
class KittyEncoderFlags {
  final bool reportEvent;
  final bool reportAlternateKeys;
  final bool reportAllKeysAsEscape;

  const KittyEncoderFlags({
    this.reportEvent = false,
    this.reportAlternateKeys = false,
    this.reportAllKeysAsEscape = false,
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
