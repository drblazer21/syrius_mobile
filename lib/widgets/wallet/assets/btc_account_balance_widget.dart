import 'package:big_decimal/big_decimal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class BtcAccountBalanceWidget extends StatelessWidget {
  final BtcAccountBalance accountBalance;
  final PriceInfo priceInfo;

  const BtcAccountBalanceWidget({
    required this.accountBalance,
    required this.priceInfo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isHideBalance = sharedPrefs.getBool(
          kIsHideBalanceKey,
        ) ??
        false;

    return StreamBuilder<bool>(
      initialData: isHideBalance,
      stream: sl.get<HideBalanceBloc>().stream,
      builder: (context, snapshot) {
        final bool hideBalance = snapshot.data!;

        return Column(
          children: [
            _buildBalanceListTile(
              balance: accountBalance.confirmed,
              context: context,
              hideBalance: hideBalance,
            ),
            if (accountBalance.unconfirmed > BigInt.zero)
              Column(
                children: [
                  const Text('Unconfirmed'),
                  _buildBalanceListTile(
                    balance: accountBalance.unconfirmed,
                    context: context,
                    hideBalance: hideBalance,
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  ListTile _buildBalanceListTile({
    required BigInt balance,
    required BuildContext context,
    required bool hideBalance,
  }) {
    return ListTile(
      leading: _buildLeading(),
      subtitle: _buildSubtitle(
        context: context,
        hideBalance: hideBalance,
      ),
      title: _buildTitle(
        balance: balance,
        context: context,
        hideBalance: hideBalance,
      ),
    );
  }

  Widget _buildSubtitle({
    required BuildContext context,
    required bool hideBalance,
  }) {
    double? priceInUsd;

    if (kSelectedAppNetworkWithAssets!.network.type == NetworkType.testnet) {
      priceInUsd = 0;
    } else {
      priceInUsd = priceInfo.btc;
    }

    final BigDecimal balance = accountBalance.confirmed.addDecimals(
      kBtcDecimals,
    );

    final BigDecimal itemUsdBalance =
        balance * BigDecimal.parse((priceInUsd).toString());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          hideBalance
              ? "••••••"
              : "${kSelectedCurrency.symbol}${priceInUsd.toStringAsFixed(2)}",
        ),
        const SizedBox(
          height: 3.0,
        ),
        Tooltip(
          message: NumberFormat().format(
            itemUsdBalance.toDouble(),
          ),
          child: Text(
            hideBalance
                ? "••••••"
                : "${kSelectedCurrency.symbol}${NumberFormat.compact().format(
                    itemUsdBalance.toDouble(),
                  )}",
          ),
        ),
      ],
    );
  }

  Widget _buildTitle({
    required BigInt balance,
    required BuildContext context,
    required bool hideBalance,
  }) {
    final double amount = balance.addDecimals(kBtcDecimals).toDouble();
    final String? name = kSelectedAppNetworkWithAssets!.assets.first.name;
    final String symbol = kSelectedAppNetworkWithAssets!.assets.first.symbol;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name ?? symbol,
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

  Widget _buildLeading() {
    final Widget btcCoin = SvgIcon(
      iconFileName: 'btc_icon',
      iconColor: Colors.white,
    );

    return CircleAvatar(
      backgroundColor: kSelectedAppNetworkWithAssets!.network.blockChain.bgColor,
      child: btcCoin,
    );
  }
}
