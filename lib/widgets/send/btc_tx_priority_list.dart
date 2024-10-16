import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:flutter/material.dart';
import 'package:syrius_mobile/widgets/send/btc_tx_priority_list_tile.dart';

class BtcTxPriorityList extends StatelessWidget {
  final void Function(BitcoinFeeRateType) onChangedCallback;
  final BitcoinFeeRateType? selectedBtcTxPriority;

  const BtcTxPriorityList({
    required this.onChangedCallback,
    required this.selectedBtcTxPriority,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> tiles = [];

    for (final btcTxPriority in BitcoinFeeRateType.values) {
      final Widget tile = BtcTxPriorityListTile(
        btcTxPriority: btcTxPriority,
        onChangedCallback: onChangedCallback,
        selectedBtcTxPriority: selectedBtcTxPriority,
      );

      tiles.add(tile);
    }

    return Column(
      children: tiles,
    );
  }
}
