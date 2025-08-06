package com.viacce.zentry.sniffer

import android.net.VpnService
import android.os.ParcelFileDescriptor
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.*
import java.io.FileInputStream
import java.net.InetAddress

class VpnSnifferService : VpnService() {

    private var vpnInterface: ParcelFileDescriptor? = null
    private var job: Job? = null
    private var eventSink: EventChannel.EventSink? = null

    fun setEventSink(sink: EventChannel.EventSink?) {
        eventSink = sink
    }

    override fun onStartCommand(intent: android.content.Intent?, flags: Int, startId: Int): Int {
        startVpn()
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        stopVpn()
    }

    private fun startVpn() {
        val builder = Builder()
        builder.addAddress("10.0.0.2", 32)
        builder.addRoute("0.0.0.0", 0)
        vpnInterface = builder.setSession("NetScopeSniffer").setBlocking(true).establish()

        vpnInterface?.let { pfd ->
            job = CoroutineScope(Dispatchers.IO).launch {
                val inputStream = FileInputStream(pfd.fileDescriptor)
                val packetBuffer = ByteArray(32767)

                while (isActive) {
                    val length = inputStream.read(packetBuffer)
                    if (length > 0) {
                        try {
                            val packetJson = parsePacket(packetBuffer, length)
                            if (packetJson != null) {
                                withContext(Dispatchers.Main) {
                                    eventSink?.success(packetJson)
                                }
                            }
                        } catch (e: Exception) {
                            e.printStackTrace()
                        }
                    }
                }
            }
        }
    }

    private fun stopVpn() {
        job?.cancel()
        vpnInterface?.close()
    }

    // Parses IPv4 packet and returns JSON string to send to Flutter
    private fun parsePacket(buffer: ByteArray, length: Int): String? {
        if (length < 20) return null // Minimum IPv4 header size

        val version = (buffer[0].toInt() shr 4) and 0xF
        if (version != 4) return null // Only IPv4

        val ihl = (buffer[0].toInt() and 0xF) * 4
        val protocol = buffer[9].toInt() and 0xFF
        val totalLength = ((buffer[2].toInt() and 0xFF) shl 8) or (buffer[3].toInt() and 0xFF)

        if (length < totalLength) return null

        val srcIp = InetAddress.getByAddress(buffer.copyOfRange(12, 16)).hostAddress
        val dstIp = InetAddress.getByAddress(buffer.copyOfRange(16, 20)).hostAddress

        var srcPort = 0
        var dstPort = 0
        var protocolName = "other"

        when (protocol) {
            6 -> { // TCP
                if (length < ihl + 20) return null
                srcPort = ((buffer[ihl].toInt() and 0xFF) shl 8) or (buffer[ihl + 1].toInt() and 0xFF)
                dstPort = ((buffer[ihl + 2].toInt() and 0xFF) shl 8) or (buffer[ihl + 3].toInt() and 0xFF)
                protocolName = "tcp"
            }
            17 -> { // UDP
                if (length < ihl + 8) return null
                srcPort = ((buffer[ihl].toInt() and 0xFF) shl 8) or (buffer[ihl + 1].toInt() and 0xFF)
                dstPort = ((buffer[ihl + 2].toInt() and 0xFF) shl 8) or (buffer[ihl + 3].toInt() and 0xFF)
                protocolName = "udp"
            }
            1 -> { // ICMP
                protocolName = "icmp"
            }
            else -> {
                protocolName = "other"
            }
        }

        val timestamp = System.currentTimeMillis()
        val timestampIso = java.time.Instant.ofEpochMilli(timestamp).toString()

        val maxRawBytes = 50
        val rawBytes = buffer.copyOfRange(0, length.coerceAtMost(maxRawBytes))
        val rawHex = rawBytes.joinToString("") { "%02x".format(it) }

        return """
        {
          "timestamp":"$timestampIso",
          "sourceIP":"$srcIp",
          "destinationIP":"$dstIp",
          "sourcePort":$srcPort,
          "destinationPort":$dstPort,
          "protocol":"$protocolName",
          "size":$length,
          "raw":"$rawHex"
        }
        """.trimIndent()
    }
}