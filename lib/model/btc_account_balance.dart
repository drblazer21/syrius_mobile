class BtcAccountBalance {
  final BigInt confirmed;
  final BigInt unconfirmed;

  BtcAccountBalance({required this.confirmed, required this.unconfirmed});

  factory BtcAccountBalance.fromJson(Map<String, dynamic> json) =>
      BtcAccountBalance(
        confirmed: BigInt.from(json['confirmed'] as int),
        unconfirmed: BigInt.from(json['unconfirmed'] as int),
      );
}
