// For the moment only USD pairs available
class PriceInfo {
  final double btc;
  final double eth;
  final double qsr;
  final double znn;
  final Map<String, dynamic>? ethTokens;

  PriceInfo({
    required this.btc,
    required this.eth,
    required this.qsr,
    required this.znn,
    this.ethTokens,
  });

  factory PriceInfo.fromJson(Map<String, dynamic> json) => PriceInfo(
        btc: (json['btc'] as Map)['usd'] as double,
        eth: (json['eth'] as Map)['usd'] as double,
        qsr: (json['qsr'] as Map)['usd'] as double,
        znn: (json['znn'] as Map)['usd'] as double,
        ethTokens: (json['eth'] as Map)['tokens'] as Map<String, dynamic>?,
      );

  double? ethToken({required String contractAddress}) {
    if (ethTokens != null) {
      final Map map = ethTokens![contractAddress] as Map;
      return map['usd'] as double;
    }
    return null;
  }
}
