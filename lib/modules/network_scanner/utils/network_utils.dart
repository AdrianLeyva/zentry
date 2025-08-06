import 'dart:io';

class NetworkUtils {
  static Future<String?> getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        includeLinkLocal: false,
      );

      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 &&
              _isPrivateIp(addr.address)) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      print('Error obteniendo IP local: $e');
    }
    return null;
  }

  static String? getSubnet(String ip) {
    final parts = ip.split('.');
    if (parts.length < 3) return null;
    return '${parts[0]}.${parts[1]}.${parts[2]}';
  }

  static bool _isPrivateIp(String ip) {
    final parts = ip.split('.').map(int.parse).toList();
    if (parts[0] == 10) return true;
    if (parts[0] == 192 && parts[1] == 168) return true;
    if (parts[0] == 172 && parts[1] >= 16 && parts[1] <= 31) return true;
    return false;
  }
}
