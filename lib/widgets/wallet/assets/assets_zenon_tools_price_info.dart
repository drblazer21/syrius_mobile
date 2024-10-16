import 'package:big_decimal/big_decimal.dart';
import 'package:flutter/material.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class AssetsZenonToolsPriceInfo extends StatelessWidget {
  final BalanceInfoListItem balanceItem;
  final PriceInfo zenonToolsPriceInfo;

  const AssetsZenonToolsPriceInfo({
    required this.balanceItem,
    required this.zenonToolsPriceInfo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Token token = balanceItem.token!;
    final Color iconColor = getTokenColor(token);
    final Color bgColor = iconColor.withOpacity(0.2);
    final String coinName = token.name;

    final BigDecimal coinAmount =
        balanceItem.balance!.addDecimals(token.decimals);

    final double rate;

    if (kSelectedAppNetworkWithAssets!.network.type == NetworkType.testnet) {
      rate = 0.0;
    } else if (token.tokenStandard == znnZts) {
      rate = zenonToolsPriceInfo.znn;
    } else if (token.tokenStandard == qsrZts) {
      rate = zenonToolsPriceInfo.qsr;
    } else {
      rate = 0.0;
    }

    final BigDecimal usdValue = coinAmount * BigDecimal.parse(rate.toString());

    return AssetListItem(
      bgColor: bgColor,
      coinAmount: coinAmount,
      coinName: coinName,
      iconColor: iconColor,
      rate: rate,
      usdValue: usdValue,
    );
  }
}
