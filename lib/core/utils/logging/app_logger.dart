import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

abstract final class AppLogger {
  static final bool _isIOS = defaultTargetPlatform == TargetPlatform.iOS;
  static final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, errorMethodCount: 8, lineLength: 120, colors: !_isIOS, printEmojis: true),
    filter: _DevelopmentLogFilter(),
  );

  /// Debug / verbose logs
  static void d(Object? message) => _logger.d(message);

  /// Info logs (normal flow)
  static void i(Object? message) => _logger.i(message);

  /// Warnings (unexpected but not fatal)
  static void w(Object? message) => _logger.w(message);

  /// Errors
  static void e(Object? message, {Object? error, StackTrace? stackTrace}) => _logger.e(message, error: error, stackTrace: stackTrace);
}

class _DevelopmentLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => !kReleaseMode;
}
