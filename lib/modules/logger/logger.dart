import 'package:zentry/modules/logger/models/log_config.dart';
import 'package:zentry/modules/logger/models/log_level.dart';
import 'package:zentry/modules/logger/models/log_record.dart';
import 'package:zentry/modules/logger/outputs/console_output.dart';
import 'package:zentry/modules/logger/outputs/log_output.dart';

class Logger {
  static LoggerConfig _config = LoggerConfig();
  static final List<LogOutput> _outputs = [ConsoleOutput()];

  static void configure({
    LoggerConfig? config,
    List<LogOutput>? outputs,
  }) {
    if (config != null) _config = config;
    if (outputs != null) {
      _outputs
        ..clear()
        ..addAll(outputs);
    }
  }

  static void _log(LogLevel level, String message,
      {Object? error, StackTrace? stackTrace}) {
    if (level.priority < _config.minimumLevel.priority) return;

    final record = LogRecord(
      level: level,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );

    for (var output in _outputs) {
      output.output(record);
    }
  }

  static void debug(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.debug, message, error: error, stackTrace: stackTrace);

  static void info(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.info, message, error: error, stackTrace: stackTrace);

  static void warning(String message,
          {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.warning, message, error: error, stackTrace: stackTrace);

  static void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.error, message, error: error, stackTrace: stackTrace);

  static void critical(String message,
          {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.critical, message, error: error, stackTrace: stackTrace);
}
