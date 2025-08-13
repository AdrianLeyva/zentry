import 'package:zentry/modules/logger/models/log_level.dart';

class LoggerConfig {
  final LogLevel minimumLevel;
  final bool enableColors;
  final bool includeTimestamp;

  const LoggerConfig({
    this.minimumLevel = LogLevel.debug,
    this.enableColors = true,
    this.includeTimestamp = true,
  });
}
