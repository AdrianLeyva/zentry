class MacVendorLookup {
  static const Map<String, String> _ouiMap = {
    "00:00:0A": "Xerox Corporation",
    "00:00:0B": "Cisco Systems, Inc",
    "00:00:0C": "Cisco Systems, Inc",
    "00:00:0D": "Cisco Systems, Inc",
    "00:00:0E": "Cisco Systems, Inc",
    "00:00:0F": "Cisco Systems, Inc",
    "00:01:02": "Apple, Inc.",
    "00:01:03": "Apple, Inc.",
    "00:01:04": "Apple, Inc.",
    "00:01:05": "Apple, Inc.",
    "00:01:06": "Apple, Inc.",
    "00:1A:2B": "Cisco Systems",
    "00:1B:63": "Apple, Inc.",
    "00:1C:B3": "Samsung Electronics",
    "00:1D:7E": "Intel Corporate",
    "00:1E:C2": "Sony Corporation",
    "00:1F:3B": "Dell Inc.",
    "00:21:6A": "Hewlett Packard",
    "00:22:68": "Huawei Technologies Co., Ltd",
    "00:23:AE": "LG Electronics",
    "00:24:E8": "Microsoft Corporation",
    "00:25:96": "Belkin International",
    "00:26:08": "Motorola Mobility, Inc.",
    "00:27:10": "Intel Corporate",
    "00:28:55": "Huawei Technologies Co., Ltd",
    "00:30:65": "Apple, Inc.",
    "00:40:96": "Intel Corporate",
    "00:50:56": "VMware, Inc.",
    "00:60:2F": "Apple, Inc.",
    "00:90:4C": "Apple, Inc.",
    "00:A0:C9": "Cisco Systems",
    "00:B0:D0": "Intel Corporate",
    "00:C0:4F": "Samsung Electronics",
    "00:D0:59": "Sony Corporation",
    "00:E0:4C": "Hewlett Packard",
    "00:F0:4B": "Cisco Systems",
    "1C:1B:0D": "Samsung Electronics",
    "3C:5A:B4": "Apple, Inc.",
    "40:16:7E": "Dell Inc.",
    "58:6D:8F": "Huawei Technologies Co., Ltd",
    "64:5A:ED": "Intel Corporate",
    "70:85:C2": "Sony Corporation",
    "88:53:2E": "Microsoft Corporation",
    "A0:99:9B": "LG Electronics",
    "B8:27:EB": "Raspberry Pi Foundation",
    "C8:2A:14": "Belkin International",
    "D4:3D:7E": "Cisco Systems",
    "E0:91:F5": "Apple, Inc.",
    "F4:F5:E8": "Google, Inc.",
  };

  static String? lookupVendor(String macAddress) {
    if (macAddress.length < 8) return null;

    String normalized = macAddress.toUpperCase().replaceAll('-', ':');
    final prefix = normalized.length >= 8 ? normalized.substring(0, 8) : '';

    return _ouiMap[prefix];
  }
}
