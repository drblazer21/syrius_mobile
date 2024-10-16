import 'package:big_decimal/big_decimal.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class EthAccountBalanceItemWidget extends StatelessWidget {
  final EthAccountBalanceItem item;
  final PriceInfo priceInfo;

  const EthAccountBalanceItemWidget({
    required this.item,
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
    double? priceInUsd;

    if (kSelectedAppNetworkWithAssets!.network.chainId != 1) {
      priceInUsd = 0;
    } else {
      if (item.ethAsset.isCurrency) {
        priceInUsd = priceInfo.eth;
      } else {
        priceInUsd = priceInfo.ethToken(
          contractAddress: item.ethAsset.contractAddressHex!,
        );
      }
    }

    final BigDecimal balance = item.balance.addDecimals(
      item.ethAsset.decimals,
    );

    final BigDecimal itemUsdBalance =
        balance * BigDecimal.parse((priceInUsd ?? 0.0).toString());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          hideBalance
              ? "••••••"
              : "${kSelectedCurrency.symbol}${priceInUsd == null ? '?' : priceInUsd.toStringAsFixed(2)}",
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
                : "${kSelectedCurrency.symbol}${priceInUsd == null ? '?' : NumberFormat.compact().format(
                    itemUsdBalance.toDouble(),
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
    final int decimals;

    if (item.displayBalance.contains('.')) {
      decimals = item.displayBalance.split('.').last.length;
    } else {
      decimals = 0;
    }

    final String amountString;

    if (decimals > 6) {
      amountString = item.displayBalance;
    } else {
      final double amount = double.parse(item.displayBalance);

      amountString = NumberFormat.compact().format(
        amount,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          item.ethAsset.name ?? item.ethAsset.symbol,
        ),
        Tooltip(
          message: item.displayBalance,
          child: Text(
            hideBalance ? "••••••" : amountString,
          ),
        ),
      ],
    );
  }

  Widget _buildLeading() {
    final Widget ethIcon = SvgIcon(
      iconFileName: 'eth_icon',
    );

    Widget child = ethIcon;

    if (item.ethAsset.logoUrl != null) {
      child = CachedNetworkImage(
        imageUrl: item.ethAsset.logoUrl!,
        errorWidget: (_, __, ___) => ethIcon,
      );
    }

    return CircleAvatar(
      backgroundColor:
          kSelectedAppNetworkWithAssets!.network.blockChain.bgColor,
      child: child,
    );
  }
}
