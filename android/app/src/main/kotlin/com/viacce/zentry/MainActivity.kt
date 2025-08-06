package com.viacce.zentry

import android.content.Intent
import android.net.VpnService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import com.viacce.zentry.sniffer.SnifferEventBridge
import kotlinx.coroutines.*

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.viacce.zentry.sniffer/control"
    private val EVENT_CHANNEL = "com.viacce.zentry.sniffer/stream"

    private var vpnIntent: Intent? = null
    private var job: Job? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startSniffer" -> {
                    startVpnSniffer()
                    result.success(null)
                }
                "stopSniffer" -> {
                    stopVpnSniffer()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                SnifferEventBridge.eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                SnifferEventBridge.eventSink = null
            }
        })
    }

    private fun startVpnSniffer() {
        val intent = VpnService.prepare(this)
        if (intent != null) {
            startActivityForResult(intent, 0)
        } else {
            launchVpnService()
        }
    }

    private fun launchVpnService() {
        vpnIntent = Intent(this, com.viacce.zentry.sniffer.VpnSnifferService::class.java)
        startService(vpnIntent)
    }

    private fun stopVpnSniffer() {
        stopService(vpnIntent)
        job?.cancel()
    }
}