import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/database/database.dart';
import 'package:syrius_mobile/database/extensions.dart';
import 'package:syrius_mobile/model/database/database.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class EthActivityItem extends StatefulWidget {
  final EthereumTx tx;
  
  const EthActivityItem({required this.tx, super.key});

  @override
  State<EthActivityItem> createState() => _EthActivityItemState();
}

class _EthActivityItemState extends State<EthActivityItem> {
  LongPressGestureRecognizer? _longPressRecognizer;

  @override
  void dispose() {
    _longPressRecognizer!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (hash, value) = (
    widget.tx.hash,
    widget.tx.value,
    );

    final Widget leading = CircleAvatar(
      child: widget.tx.isContractInteraction
          ? const Icon(Icons.swap_horiz)
          : SvgIcon(
        iconFileName: 'eth_icon',
        iconColor: Colors.white,
      ),
    );

    final Widget title = Text(
      widget.tx.isContractInteraction
          ? 'Contract interaction'
          : widget.tx.to! == selectedAddress.hex
          ? 'Receive'
          : 'Send',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    final Widget trailing = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        EthExplorerButton(hash: hash),
        Flexible(
          child: Tooltip(
            message:
            value.toStringWithDecimals(kEvmCurrencyDecimals),
            child: Text(
              '${kSelectedAppNetworkWithAssets!.network.currencySymbol} ${value.addDecimals(kEvmCurrencyDecimals).toPlainString()}',
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
          child: _buildTransactionHeader(context, widget.tx),
        ),
        ListTile(
          leading: leading,
          subtitle: _getSubtitle(ethTransaction: widget.tx),
          title: title,
          trailing: SizedBox(
            width: 200.0,
            child: trailing,
          ),
        ),
      ],
    );
  }

  Widget _getSubtitle({
    required EthereumTx ethTransaction,
  }) {
    if (ethTransaction.isContractInteraction) {
      return Text(
        'Contract interaction',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.defaultListTileSubtitleStyle,
      );
    }

    final String prefix =
    ethTransaction.to! == selectedAddress.hex ? 'From' : 'To';

    final String address = ethTransaction.to! == selectedAddress.hex
        ? ethTransaction.from
        : ethTransaction.to!;

    _longPressRecognizer ??= LongPressGestureRecognizer()
      ..onLongPress = () => _handlePress(data: address);

    return RichText(
      text: TextSpan(
        style: context.defaultListTileSubtitleStyle,
        children: [
          TextSpan(
            text: prefix,
          ),
          const TextSpan(
            text: '  ●  ',
          ),
          TextSpan(
            recognizer: _longPressRecognizer,
            style: const TextStyle(
              color: znnColor,
            ),
            text: shortenWalletAddress(
              ethTransaction.to! == selectedAddress.hex
                  ? ethTransaction.from
                  : ethTransaction.to!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHeader(
      BuildContext context,
      EthereumTx tx,
      ) {
    String? headerText;
    switch (tx.status) {
      case EthereumTransactionStatus.done:
        headerText = formatTxsDateTime(tx.txDateTime);
      case EthereumTransactionStatus.pending:
        headerText = AppLocalizations.of(context)!.pending;
      case EthereumTransactionStatus.failed:
        headerText = AppLocalizations.of(context)!.failed;
    }

    return Text(style: const TextStyle(color: Colors.grey), headerText);
  }

  void _handlePress({required String data}) {
    HapticFeedback.vibrate();
    copyToClipboard(data: data);
  }
}
