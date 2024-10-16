class EvmNodeStats {
  final int blockNumber;
  final String clientVersion;
  final BigInt chainId;
  final int networkId;
  final int peerCount;

  EvmNodeStats({
    required this.blockNumber,
    required this.clientVersion,
    required this.chainId,
    required this.networkId,
    required this.peerCount,
});
}
