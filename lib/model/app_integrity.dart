class AppIntegrity {
  final String? checksum;
  final String? signature;
  final bool? isNotTrust;
  final bool? isRooted;
  final bool? isRealDevice;
  final bool? isTampered;
  final bool? isOnExternalStorage;

  AppIntegrity({
    required this.checksum,
    required this.signature,
    required this.isNotTrust,
    required this.isRooted,
    required this.isRealDevice,
    required this.isTampered,
    required this.isOnExternalStorage,
  });
}
