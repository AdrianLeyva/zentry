import 'dart:developer';

import 'package:zentry/modules/logger/models/log_level.dart';
import 'package:zentry/modules/logger/models/log_record.dart';
import 'package:zentry/modules/logger/outputs/log_output.dart';

class ConsoleOutput implements LogOutput {
  final bool enableColors;

  ConsoleOutput({this.enableColors = true});

  static const _colorMap = {
    LogLevel.debug: '\x1B[37m',
    LogLevel.info: '\x1B[34m',
    LogLevel.warning: '\x1B[33m',
    LogLevel.error: '\x1B[31m',
    LogLevel.critical: '\x1B[41m',
  };

  @override
  void output(LogRecord record) {
    final color = enableColors ? _colorMap[record.level] ?? '' : '';
    final reset = enableColors ? '\x1B[0m' : '';
    log('$color${record.toString()}$reset');
  }
}
