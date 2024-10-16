class ElectrumBtcNodeStats {
  final String genesisHash;
  final String serverVersion;
  final String hashFunction;
  final String protocolMax;
  final String protocolMin;

  ElectrumBtcNodeStats({
    required this.genesisHash,
    required this.serverVersion,
    required this.hashFunction,
    required this.protocolMax,
    required this.protocolMin,
  });

  factory ElectrumBtcNodeStats.fromJson(Map<String, dynamic> map) {
    return ElectrumBtcNodeStats(
      genesisHash: map['genesis_hash'] as String,
      serverVersion: map['server_version'] as String,
      hashFunction: map['hash_function'] as String,
      protocolMax: map['protocol_max'] as String,
      protocolMin: map['protocol_min'] as String,
    );
  }
}
