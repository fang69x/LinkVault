import 'package:flutter/foundation.dart';

// Simple logger utility for consistent logging across the app
class Logger {
  final String tag;

  const Logger(this.tag);

  void info(String message) {
    _log('INFO', message);
  }

  void warning(String message) {
    _log('WARNING', message);
  }

  void error(String message) {
    _log('ERROR', message);
  }

  void debug(String message) {
    if (kDebugMode) {
      _log('DEBUG', message);
    }
  }

  void _log(String level, String message) {
    if (kDebugMode) {
      print('[$level] [$tag] $message');
    }
  }
}

// Global logger instance for quick access
final appLogger = Logger('App');
