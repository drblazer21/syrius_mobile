import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';

class BtcTxPriorityListTile extends StatelessWidget {
  final BitcoinFeeRateType btcTxPriority;
  final BitcoinFeeRateType? selectedBtcTxPriority;
  final void Function(BitcoinFeeRateType) onChangedCallback;

  const BtcTxPriorityListTile({
    required this.btcTxPriority,
    required this.onChangedCallback,
    required this.selectedBtcTxPriority,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<BitcoinFeeRateType>(
      title: Text(btcTxPriority.name.capitalize()),
      value: btcTxPriority,
      groupValue: selectedBtcTxPriority,
      onChanged: (BitcoinFeeRateType? value) {
        if (value != null) {
          onChangedCallback(value);
        }
      },
    );
  }
}
