import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  static final bool _isIOS = defaultTargetPlatform == TargetPlatform.iOS;
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: !_isIOS,
      printEmojis: true,
    ),
    filter: _ReleaseFilter(),
  );

  /// Debug / verbose logs
  static void d(dynamic message) => _logger.d(message);

  /// Info logs (normal flow)
  static void i(dynamic message) => _logger.i(message);

  /// Warnings (unexpected but not fatal)
  static void w(dynamic message) => _logger.w(message);

  /// Errors
  static void e(dynamic message, {Object? error, StackTrace? stackTrace}) => _logger.e(message, error: error, stackTrace: stackTrace);
}

class _ReleaseFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => !kReleaseMode;
}
