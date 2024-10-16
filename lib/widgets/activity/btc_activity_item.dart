import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class BtcActivityItem extends StatelessWidget {
  final MempoolTransaction tx;

  const BtcActivityItem({required this.tx, super.key});

  @override
  Widget build(BuildContext context) {
    final Iterable<MempoolVin> inputs = tx.vin.where(
      (vin) => vin.prevOut.scriptPubKeyAddress == selectedAddress.hex,
    );

    BigInt inputsAmount = BigInt.zero;

    for (final input in inputs) {
      inputsAmount += BigInt.from(input.prevOut.value);
    }

    final Iterable<MempoolVout> outputs = tx.vout.where(
          (vout) => vout.scriptPubKeyAddress == selectedAddress.hex,
    );

    BigInt outputsAmount = BigInt.zero;

    for (final output in outputs) {
      outputsAmount += BigInt.from(output.value);
    }

    final bool isSent = inputs.isNotEmpty;

    final BigInt value = outputsAmount - inputsAmount;
    final (hash) = tx.txID;

    final Widget leading = CircleAvatar(
      child: SvgIcon(
        iconFileName: 'btc_icon',
        iconColor: Colors.white,
      ),
    );

    final Widget title = Text(
      isSent ? 'Sent' : 'Receive',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    final Widget trailing = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        BtcExplorerButton(hash: hash),
        Flexible(
          child: Tooltip(
            message: value.toStringWithDecimals(kBtcDecimals),
            child: Text(
              '${kSelectedAppNetworkWithAssets!.network.currencySymbol} ${value.addDecimals(kBtcDecimals).toPlainString()}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: context.listTileTheme.contentPadding!,
          child: _buildTransactionHeader(context, tx),
        ),
        ListTile(
          leading: leading,
          subtitle: _getSubtitle(tx: tx),
          title: title,
          trailing: SizedBox(
            width: 200.0,
            child: trailing,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionHeader(
    BuildContext context,
    MempoolTransaction tx,
  ) {
    String? headerText;
    final bool isConfirmed = tx.status.confirmed;

    if (isConfirmed) {
      final int timestampMs = tx.status.blockTime! * 1000;
      final DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(timestampMs);
      headerText = formatTxsDateTime(dateTime);
    } else {
      headerText = AppLocalizations.of(context)!.pending;
    }

    return Text(style: const TextStyle(color: Colors.grey), headerText);
  }

  Widget _getSubtitle({
    required MempoolTransaction tx,
  }) {
    return Text('Fee: ${tx.fee} sat');
  }
}
