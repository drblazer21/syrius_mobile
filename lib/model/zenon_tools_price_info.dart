class ZenonToolsPriceInfo {
  final double znnCurrentPriceInUsd;
  final double qsrCurrentPriceInUsd;

  ZenonToolsPriceInfo({
    required this.znnCurrentPriceInUsd,
    required this.qsrCurrentPriceInUsd,
  });

  factory ZenonToolsPriceInfo.fromJson(Map<String, dynamic> json) =>
      ZenonToolsPriceInfo(
        znnCurrentPriceInUsd: json['znnPriceUsd'] as double,
        qsrCurrentPriceInUsd: json['qsrPriceUsd'] as double,
      );
}
