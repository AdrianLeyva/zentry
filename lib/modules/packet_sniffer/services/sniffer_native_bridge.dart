import 'dart:async';

import 'package:flutter/services.dart';
import 'package:zentry/modules/logger/logger.dart';

class SnifferNativeBridge {
  static const MethodChannel _channel =
      MethodChannel('com.viacce.zentry.sniffer/control');
  static const EventChannel _eventChannel =
      EventChannel('com.viacce.zentry.sniffer/stream');

  int _packetCount = 0;
  int _totalBytes = 0;

  Stream<String> get packetStream =>
      _eventChannel.receiveBroadcastStream().cast<String>().map((packetJson) {
        _packetCount++;
        final packetSize = _extractPacketSize(packetJson);
        _totalBytes += packetSize;
        Logger.debug(
            "[Packet $_packetCount] Size: $packetSize bytes, Total: $_totalBytes bytes");
        Logger.debug("Packet JSON: $packetJson\n");
        return packetJson;
      });

  Future<void> startSniffer() async {
    await _channel.invokeMethod('startSniffer');
    _packetCount = 0;
    _totalBytes = 0;
  }

  Future<void> stopSniffer() async {
    await _channel.invokeMethod('stopSniffer');
  }

  int _extractPacketSize(String json) {
    try {
      final match = RegExp(r'"size":(\d+)').firstMatch(json);
      if (match != null) return int.parse(match.group(1)!);
    } catch (_) {}
    return 0;
  }
}
