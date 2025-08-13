enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

extension LogLevelExtension on LogLevel {
  String get name => toString().split('.').last.toUpperCase();

  int get priority {
    switch (this) {
      case LogLevel.debug:
        return 1;
      case LogLevel.info:
        return 2;
      case LogLevel.warning:
        return 3;
      case LogLevel.error:
        return 4;
      case LogLevel.critical:
        return 5;
    }
  }
}
