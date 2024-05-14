class PillarDetail {
  String address;
  double weight;
  double producedMomentums;
  double expectedMomentums;
  double giveMomentumRewardPercentage;
  double giveDelegateRewardPercentage;
  double delegateApr;
  double apr;

  PillarDetail({
    required this.address,
    required this.weight,
    required this.producedMomentums,
    required this.expectedMomentums,
    required this.giveDelegateRewardPercentage,
    required this.giveMomentumRewardPercentage,
    required this.delegateApr,
    required this.apr,
  });

  factory PillarDetail.fromJson(String address, Map<String, dynamic> jsonData) {
    final Map<String, dynamic> valueMapped = jsonData;
    return PillarDetail(
      address: address,
      weight: valueMapped['weight'] as double,
      producedMomentums: valueMapped['producedMomentums'] as double,
      expectedMomentums: valueMapped['expectedMomentums'] as double,
      giveDelegateRewardPercentage:
          valueMapped['giveDelegateRewardPercentage'] as double,
      giveMomentumRewardPercentage:
          valueMapped['giveMomentumRewardPercentage'] as double,
      delegateApr: valueMapped['delegateApr'] as double,
      apr: valueMapped['apr'] as double,
    );
  }
}
