import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/extensions/extensions.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class AssetListItem extends StatelessWidget {
  final Color iconColor;
  final Color bgColor;
  final String coinName;
  final BigInt coinAmount;
  final double rate;
  final double usdValue;

  const AssetListItem({
    required this.bgColor,
    required this.coinAmount,
    required this.coinName,
    required this.iconColor,
    required this.rate,
    required this.usdValue,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isHideBalance = sharedPrefsService.get<bool>(
      kIsHideBalanceKey,
      defaultValue: false,
    )!;

    return StreamBuilder<bool>(
      initialData: isHideBalance,
      stream: sl.get<HideBalanceBloc>().stream,
      builder: (context, snapshot) {
        final bool hideBalance = snapshot.data!;

        return ListTile(
          leading: _buildLeading(),
          subtitle: _buildSubtitle(
            context: context,
            hideBalance: hideBalance,
          ),
          title: _buildTitle(
            context: context,
            hideBalance: hideBalance,
          ),
        );
      },
    );
  }

  Widget _buildSubtitle({
    required BuildContext context,
    required bool hideBalance,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          hideBalance
              ? "••••••"
              : "${kSelectedCurrency.symbol}${rate.toStringAsFixed(2)}",
        ),
        const SizedBox(
          height: 3.0,
        ),
        Tooltip(
          message: NumberFormat().format(
            usdValue,
          ),
          child: Text(
            hideBalance
                ? "••••••"
                : "${kSelectedCurrency.symbol}${NumberFormat.compact().format(
                    usdValue,
                  )}",
          ),
        ),
      ],
    );
  }

  Widget _buildTitle({
    required BuildContext context,
    required bool hideBalance,
  }) {
    final double amount = double.parse(coinAmount.addDecimals(coinDecimals));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          coinName,
        ),
        Tooltip(
          message: NumberFormat().format(
            amount,
          ),
          child: Text(
            hideBalance
                ? "••••••"
                : NumberFormat.compact().format(
                    amount,
                  ),
          ),
        ),
      ],
    );
  }

  CircleAvatar _buildLeading() {
    return CircleAvatar(
      backgroundColor: bgColor,
      child: SvgIcon(
        iconFileName: 'zn_icon',
        iconColor: iconColor,
      ),
    );
  }
}
