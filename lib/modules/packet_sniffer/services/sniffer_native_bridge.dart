import 'dart:async';

import 'package:flutter/services.dart';

class SnifferNativeBridge {
  static const MethodChannel _channel =
      MethodChannel('com.viacce.zentry.sniffer/control');
  static const EventChannel _eventChannel =
      EventChannel('com.viacce.zentry.sniffer/stream');

  Stream<String> get packetStream =>
      _eventChannel.receiveBroadcastStream().cast<String>();

  Future<void> startSniffer() async {
    await _channel.invokeMethod('startSniffer');
  }

  Future<void> stopSniffer() async {
    await _channel.invokeMethod('stopSniffer');
  }
}
