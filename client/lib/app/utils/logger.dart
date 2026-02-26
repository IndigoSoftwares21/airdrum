import 'package:flutter/foundation.dart';

class Log {
  static void info(dynamic message, [String tag = 'INFO']) {
    _log(tag, '\x1B[34m', message.toString()); // Blue
  }

  static void success(dynamic message, [String tag = 'SUCCESS']) {
    _log(tag, '\x1B[32m', message.toString()); // Green
  }

  static void warning(dynamic message, [String tag = 'WARN']) {
    _log(tag, '\x1B[33m', message.toString()); // Yellow
  }

  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    final errMsg = error != null
        ? '$message\nError: $error'
        : message.toString();
    _log('ERROR', '\x1B[31m', errMsg); // Red
    if (stackTrace != null && kDebugMode) {
      debugPrint('\x1B[31m$stackTrace\x1B[0m');
    }
  }

  static void _log(String level, String colorCode, String message) {
    if (kDebugMode) {
      final now = DateTime.now();
      final timestamp =
          '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')} '
          '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}:'
          '${now.second.toString().padLeft(2, '0')}.'
          '${now.millisecond.toString().padLeft(3, '0')}';

      // Use print directly because debugPrint sometimes strips ansi colors
      // depending on the IDE console.
      print('$colorCode[$timestamp] [$level] $message\x1B[0m');
    }
  }
}
