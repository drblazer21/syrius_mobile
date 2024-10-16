class EthToZnnQuota {
  final BigInt wei;
  final BigInt znn;

  EthToZnnQuota({required this.wei, required this.znn});

  EthToZnnQuota.fromList(List<dynamic> list)
      : wei = list[0] as BigInt,
        znn = list[1] as BigInt;
}
