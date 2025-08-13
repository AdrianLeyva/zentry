import 'package:zentry/modules/logger/logger.dart';
import 'package:zentry/modules/logger/models/log_config.dart';
import 'package:zentry/modules/logger/models/log_level.dart';
import 'package:zentry/modules/logger/outputs/console_output.dart';

class LoggerProvider {
  static LoggerProvider? _instance;

  LoggerProvider._();

  static LoggerProvider get instance {
    _instance ??= LoggerProvider._();
    return _instance!;
  }

  Future<void> init() async {
    Logger.configure(
      config: LoggerConfig(minimumLevel: LogLevel.info),
      outputs: [ConsoleOutput()],
    );
  }
}
