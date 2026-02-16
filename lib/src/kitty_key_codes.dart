import 'package:flutter/services.dart';

/// Key codes per Kitty Keyboard Protocol spec
class KittyKeyCodes {
  // Function keys
  static const int f1 = 11;
  static const int f2 = 12;
  static const int f3 = 13;
  static const int f4 = 14;
  static const int f5 = 15;
  static const int f6 = 17;
  static const int f7 = 18;
  static const int f8 = 19;
  static const int f9 = 20;
  static const int f10 = 21;
  static const int f11 = 23;
  static const int f12 = 24;

  // Navigation keys
  static const int arrowUp = 30;
  static const int arrowDown = 31;
  static const int arrowRight = 32;
  static const int arrowLeft = 33;
  static const int pageDown = 34;
  static const int pageUp = 35;
  static const int home = 36;
  static const int end = 37;
  static const int insert = 38;

  // Special keys
  static const int enter = 28;
  static const int backspace = 27;
  static const int tab = 29;
  static const int escape = 53;
  static const int space = 44;
  static const int delete = 127;

  // Action keys
  static const int pause = 43;
  static const int printScreen = 45;

  /// Map Flutter LogicalKeyboardKey to Kitty key code
  static int? getKeyCode(LogicalKeyboardKey key) {
    return _keyMap[key];
  }

  static final Map<LogicalKeyboardKey, int> _keyMap = {
    LogicalKeyboardKey.f1: f1,
    LogicalKeyboardKey.f2: f2,
    LogicalKeyboardKey.f3: f3,
    LogicalKeyboardKey.f4: f4,
    LogicalKeyboardKey.f5: f5,
    LogicalKeyboardKey.f6: f6,
    LogicalKeyboardKey.f7: f7,
    LogicalKeyboardKey.f8: f8,
    LogicalKeyboardKey.f9: f9,
    LogicalKeyboardKey.f10: f10,
    LogicalKeyboardKey.f11: f11,
    LogicalKeyboardKey.f12: f12,
    LogicalKeyboardKey.arrowUp: arrowUp,
    LogicalKeyboardKey.arrowDown: arrowDown,
    LogicalKeyboardKey.arrowRight: arrowRight,
    LogicalKeyboardKey.arrowLeft: arrowLeft,
    LogicalKeyboardKey.pageDown: pageDown,
    LogicalKeyboardKey.pageUp: pageUp,
    LogicalKeyboardKey.home: home,
    LogicalKeyboardKey.end: end,
    LogicalKeyboardKey.insert: insert,
    LogicalKeyboardKey.enter: enter,
    LogicalKeyboardKey.backspace: backspace,
    LogicalKeyboardKey.tab: tab,
    LogicalKeyboardKey.escape: escape,
    LogicalKeyboardKey.space: space,
    LogicalKeyboardKey.delete: delete,
    LogicalKeyboardKey.pause: pause,
    LogicalKeyboardKey.printScreen: printScreen,
  };
}
