package com.viacce.zentry

import android.content.Intent
import android.net.VpnService
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import com.viacce.zentry.sniffer.VpnSnifferService

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.viacce.zentry.sniffer/control"
    private val EVENT_CHANNEL = "com.viacce.zentry.sniffer/stream"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startSniffer" -> { startVpnSniffer(); result.success(null) }
                "stopSniffer" -> { stopVpnSniffer(); result.success(null) }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                VpnSnifferService.eventSink = events
            }
            override fun onCancel(arguments: Any?) {
                VpnSnifferService.eventSink = null
            }
        })
    }

    private fun startVpnSniffer() {
        val intent = VpnService.prepare(this)
        if (intent != null) startActivityForResult(intent, 100) else launchVpnService()
    }

    private fun launchVpnService() {
        val i = Intent(this, VpnSnifferService::class.java).setAction(VpnSnifferService.ACTION_START)
        ContextCompat.startForegroundService(this, i)
    }

    private fun stopVpnSniffer() {
        val i = Intent(this, VpnSnifferService::class.java).setAction(VpnSnifferService.ACTION_STOP)
        ContextCompat.startForegroundService(this, i)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 100 && resultCode == RESULT_OK) launchVpnService()
    }
}