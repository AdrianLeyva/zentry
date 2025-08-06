class Port {
  final int port;
  final String protocol;
  final bool isOpen;

  Port({required this.port, this.protocol = 'tcp', this.isOpen = false});
}
