import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class UtxoWidget extends StatelessWidget {
  final bool isSelected;
  final void Function(bool) onChanged;
  final UtxoWithAddress utxo;

  const UtxoWidget({
    required this.isSelected,
    required this.onChanged,
    required this.utxo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Text subtitle = Text(
      '${utxo.utxo.value.toStringWithDecimals(kBtcDecimals)} ${kSelectedAppNetworkWithAssets!.network.currencySymbol}',
    );

    final Text title = Text(
      shortenWalletAddress(
        utxo.utxo.txHash,
        prefixCharactersCount: 10,
        suffixCharactersCount: 10,
      ),
    );

    return CheckboxListTile.adaptive(
      secondary: BtcExplorerButton(hash: utxo.utxo.txHash),
      subtitle: subtitle,
      title: title,
      value: isSelected,
      onChanged: (bool? changed) {
        if (changed != null) {
          onChanged.call(changed);
        }
      },
    );
  }
}
