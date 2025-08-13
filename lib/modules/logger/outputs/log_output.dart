import 'package:zentry/modules/logger/models/log_record.dart';

abstract class LogOutput {
  void output(LogRecord record);
}
