package com.viacce.zentry.sniffer

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import android.util.Log
import androidx.core.app.NotificationCompat
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.*
import java.net.InetAddress
import android.system.Os
import android.system.OsConstants
import android.system.StructPollfd

class VpnSnifferService : VpnService() {

    private var vpnInterface: ParcelFileDescriptor? = null
    private var inputStream: ParcelFileDescriptor.AutoCloseInputStream? = null
    private val serviceScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private var job: Job? = null
    @Volatile private var isRunning = false

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: android.content.Intent?, flags: Int, startId: Int): Int {
        return when (intent?.action) {
            ACTION_STOP -> {
                stopVpn()
                stopForeground(true)
                stopSelf()
                START_NOT_STICKY
            }
            else -> {
                startForeground(NOTIF_ID, buildNotification())
                startVpn()
                START_STICKY
            }
        }
    }

    override fun onDestroy() {
        stopVpn()
        serviceScope.cancel()
        super.onDestroy()
    }

    override fun onRevoke() {
        stopVpn()
        stopForeground(true)
        stopSelf()
    }

    private fun startVpn() {
        if (isRunning) return
        isRunning = true
        Log.d("VpnSnifferService", "VPN started")
        val builder = Builder()
        builder.addAddress(VPN_ADDRESS, VPN_PREFIX_LENGTH)
        builder.addRoute(ROUTE_ADDRESS, ROUTE_PREFIX_LENGTH)
        vpnInterface = builder.setSession("NetScopeSniffer").establish()
        vpnInterface?.let { pfd ->
            inputStream = ParcelFileDescriptor.AutoCloseInputStream(pfd)
            job = serviceScope.launch {
                val packetBuffer = ByteArray(PACKET_BUFFER_SIZE)
                val pollFd = StructPollfd().apply {
                    fd = pfd.fileDescriptor
                    events = OsConstants.POLLIN.toShort()
                }
                while (isActive && isRunning) {
                    val ready = try { Os.poll(arrayOf(pollFd), POLL_TIMEOUT_MS) } catch (_: Exception) { 0 }
                    if (!isRunning || !isActive) break
                    if (ready > 0 && (pollFd.revents.toInt() and OsConstants.POLLIN) != 0) {
                        val length = try { inputStream?.read(packetBuffer) ?: -1 } catch (_: Exception) { -1 }
                        if (length <= 0) break
                        try {
                            val packetJson = parsePacket(packetBuffer, length)
                            if (packetJson != null) {
                                withContext(Dispatchers.Main) {
                                    eventSink?.success(packetJson)
                                }
                            }
                        } catch (_: Exception) { }
                    } else {
                        yield()
                    }
                }
            }
        }
    }

    private fun stopVpn() {
        isRunning = false
        try { job?.cancel() } catch (_: Exception) { }
        try { inputStream?.close() } catch (_: Exception) { }
        inputStream = null
        try { vpnInterface?.close() } catch (_: Exception) { }
        vpnInterface = null
        Log.d("VpnSnifferService", "VPN stopped")
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (nm.getNotificationChannel(CHANNEL_ID) == null) {
                nm.createNotificationChannel(
                    NotificationChannel(CHANNEL_ID, "NetScope Sniffer", NotificationManager.IMPORTANCE_LOW)
                )
            }
        }
    }

    private fun buildNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("NetScope activated")
            .setContentText("Analyzing traffic")
            .setSmallIcon(android.R.drawable.stat_sys_download_done)
            .setOngoing(true)
            .build()
    }

    private fun parsePacket(buffer: ByteArray, length: Int): String? {
        if (length < IPV4_HEADER_MIN_LENGTH) return null
        val version = (buffer[0].toInt() shr 4) and 0xF
        if (version != 4) return null
        val ihl = (buffer[0].toInt() and 0xF) * 4
        val protocol = buffer[9].toInt() and 0xFF
        val totalLength = ((buffer[2].toInt() and 0xFF) shl 8) or (buffer[3].toInt() and 0xFF)
        if (length < totalLength) return null
        val srcIp = InetAddress.getByAddress(buffer.copyOfRange(12, 16)).hostAddress
        val dstIp = InetAddress.getByAddress(buffer.copyOfRange(16, 20)).hostAddress
        var srcPort = 0
        var dstPort = 0
        var protocolName = PROTOCOL_OTHER
        when (protocol) {
            PROTOCOL_TCP -> {
                if (length < ihl + TCP_HEADER_MIN_LENGTH) return null
                srcPort = ((buffer[ihl].toInt() and 0xFF) shl 8) or (buffer[ihl + 1].toInt() and 0xFF)
                dstPort = ((buffer[ihl + 2].toInt() and 0xFF) shl 8) or (buffer[ihl + 3].toInt() and 0xFF)
                protocolName = PROTOCOL_TCP_NAME
            }
            PROTOCOL_UDP -> {
                if (length < ihl + UDP_HEADER_MIN_LENGTH) return null
                srcPort = ((buffer[ihl].toInt() and 0xFF) shl 8) or (buffer[ihl + 1].toInt() and 0xFF)
                dstPort = ((buffer[ihl + 2].toInt() and 0xFF) shl 8) or (buffer[ihl + 3].toInt() and 0xFF)
                protocolName = PROTOCOL_UDP_NAME
            }
            PROTOCOL_ICMP -> protocolName = PROTOCOL_ICMP_NAME
        }
        val timestampIso = java.time.Instant.ofEpochMilli(System.currentTimeMillis()).toString()
        val rawBytes = buffer.copyOfRange(0, length.coerceAtMost(MAX_RAW_BYTES))
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

    companion object {
        var eventSink: EventChannel.EventSink? = null
        const val ACTION_START = "com.viacce.zentry.sniffer.ACTION_START"
        const val ACTION_STOP = "com.viacce.zentry.sniffer.ACTION_STOP"
        const val CHANNEL_ID = "netscope_vpn_sniffer"
        const val NOTIF_ID = 1001
        private const val VPN_ADDRESS = "10.0.0.2"
        private const val VPN_PREFIX_LENGTH = 32
        private const val ROUTE_ADDRESS = "0.0.0.0"
        private const val ROUTE_PREFIX_LENGTH = 0
        private const val PACKET_BUFFER_SIZE = 32767
        private const val POLL_TIMEOUT_MS = 250
        private const val IPV4_HEADER_MIN_LENGTH = 20
        private const val TCP_HEADER_MIN_LENGTH = 20
        private const val UDP_HEADER_MIN_LENGTH = 8
        private const val MAX_RAW_BYTES = 50
        private const val PROTOCOL_TCP = 6
        private const val PROTOCOL_UDP = 17
        private const val PROTOCOL_ICMP = 1
        private const val PROTOCOL_TCP_NAME = "tcp"
        private const val PROTOCOL_UDP_NAME = "udp"
        private const val PROTOCOL_ICMP_NAME = "icmp"
        private const val PROTOCOL_OTHER = "other"
    }
}
