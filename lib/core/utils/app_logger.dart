import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class AppLogger {
  static final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');

  static String get _timestamp => _dateFormatter.format(DateTime.now());

  static void d(String message, {String tag = 'DEBUG'}) {
    if (kDebugMode) {
      debugPrint('[$_timestamp] [DEBUG] [$tag] $message');
    }
  }

  static void i(String message, {String tag = 'INFO'}) {
    debugPrint('[$_timestamp] [INFO] [$tag] $message');
  }

  static void w(String message, {String tag = 'WARN'}) {
    debugPrint('[$_timestamp] [WARN] [$tag] $message');
  }

  static void e(String message, {String tag = 'ERROR', Object? error, StackTrace? stackTrace}) {
    debugPrint('[$_timestamp] [ERROR] [$tag] $message');
    if (error != null) {
      debugPrint('[$_timestamp] [ERROR] [$tag] Details: $error');
    }
    if (stackTrace != null && kDebugMode) {
      debugPrint('[$_timestamp] [ERROR] [$tag] StackTrace:\n$stackTrace');
    }
  }
}