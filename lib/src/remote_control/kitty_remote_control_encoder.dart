/// Kitty Remote Control Encoder - Remote control for Kitty Protocol
///
/// Reference: doc/kitty/docs/rc_protocol.rst
library kitty_protocol_remote_control_encoder;

/// Remote control encoder
///
/// Per protocol lines 8-20:
///
/// Format:
///   <ESC>P@kitty-cmd<JSON object><ESC>\
///
/// Example:
///   <ESC>P@kitty-cmd{"cmd":"ls","version":[0,14,2]}<ESC>\
class KittyRemoteControlEncoder {
  /// DCS code for kitty remote control
  static const String dcsPrefix = '\x1bP@kitty-cmd';

  /// String terminator
  static const String terminator = '\x1b\\';

  /// Current kitty version
  static const List<int> defaultVersion = [0, 14, 2];

  const KittyRemoteControlEncoder();

  /// Build a remote control command
  ///
  /// Per protocol lines 10-20:
  ///   {
  ///     "cmd": "command name",
  ///     "version": [0, 14, 2],
  ///     "no_response": false,
  ///     "kitty_window_id": "...",
  ///     "payload": {...}
  ///   }
  String buildCommand({
    required String command,
    List<int>? version,
    bool noResponse = false,
    String? kittyWindowId,
    Map<String, dynamic>? payload,
  }) {
    final cmd = <String, dynamic>{
      'cmd': command,
      'version': version ?? defaultVersion,
      if (noResponse) 'no_response': true,
      if (kittyWindowId != null) 'kitty_window_id': kittyWindowId,
      if (payload != null) 'payload': payload,
    };

    final json = _encodeJson(cmd);
    return '$dcsPrefix$json$terminator';
  }

  /// Simple JSON encoder (for basic types)
  String _encodeJson(dynamic value) {
    if (value == null) return 'null';
    if (value is bool) return value.toString();
    if (value is num) return value.toString();
    if (value is String) return '"${_escapeString(value)}"';
    if (value is List) {
      return '[${value.map(_encodeJson).join(',')}]';
    }
    if (value is Map) {
      final entries = value.entries.map((e) => '"${e.key}":${_encodeJson(e.value)}');
      return '{${entries.join(',')}}';
    }
    return 'null';
  }

  String _escapeString(String s) {
    return s
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }

  // ============ Common Commands ============

  /// List windows
  String listWindows() {
    return buildCommand(command: 'ls');
  }

  /// Get window information
  String getWindowInfo({int? windowId}) {
    return buildCommand(
      command: 'get_window_info',
      payload: windowId != null ? {'window_id': windowId} : null,
    );
  }

  /// Close a window
  String closeWindow(int windowId, {bool? noResponse}) {
    return buildCommand(
      command: 'close_window',
      payload: {'window_id': windowId},
      noResponse: noResponse ?? true,
    );
  }

  /// Set window title
  String setWindowTitle(String title, {int? windowId}) {
    return buildCommand(
      command: 'set_window_title',
      payload: {
        'title': title,
        if (windowId != null) 'window_id': windowId,
      },
    );
  }

  /// Send text to window
  String sendText(String text, {int? windowId, bool? noResponse}) {
    return buildCommand(
      command: 'send_text',
      payload: {
        'text': text,
        if (windowId != null) 'window_id': windowId,
      },
      noResponse: noResponse ?? true,
    );
  }

  /// Input Unicode text
  String input(String text, {int? windowId}) {
    return buildCommand(
      command: 'input',
      payload: {
        'text': text,
        if (windowId != null) 'window_id': windowId,
      },
    );
  }

  /// Clear screen
  String clearScreen({int? windowId}) {
    return buildCommand(
      command: 'clear_screen',
      payload: windowId != null ? {'window_id': windowId} : null,
    );
  }

  /// Scroll screen
  String scroll(int lines, {int? windowId}) {
    return buildCommand(
      command: 'scroll',
      payload: {
        'lines': lines,
        if (windowId != null) 'window_id': windowId,
      },
    );
  }

  /// Get colors
  String getColors() {
    return buildCommand(command: 'get_colors');
  }

  /// Get configuration
  String getConfig() {
    return buildCommand(command: 'get_config');
  }

  /// Query terminal capability
  String getTerminfo({String? name}) {
    return buildCommand(
      command: 'get_terminal_attribute',
      payload: name != null ? {'attr': name} : null,
    );
  }
}
