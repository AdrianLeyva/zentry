import 'log_level.dart';

class LogRecord {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  LogRecord({
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    final errorText = error != null ? ' | ERROR: $error' : '';
    final stackText = stackTrace != null ? '\nSTACK: $stackTrace' : '';
    return '[${timestamp.toIso8601String()}] [${level.name}] $message$errorText$stackText';
  }
}
