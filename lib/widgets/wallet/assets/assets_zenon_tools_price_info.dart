import 'package:flutter/material.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/extensions/extensions.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class AssetsZenonToolsPriceInfo extends StatelessWidget {
  final AccountInfo accountInfo;
  final ZenonToolsPriceInfo zenonToolsPriceInfo;

  const AssetsZenonToolsPriceInfo({
    required this.accountInfo,
    required this.zenonToolsPriceInfo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final BigInt znnAmount = accountInfo.getBalance(
      kZnnCoin.tokenStandard,
    );
    final BigInt qsrAmount = accountInfo.getBalance(
      kQsrCoin.tokenStandard,
    );

    final double znnPriceInUsd = zenonToolsPriceInfo.znnCurrentPriceInUsd;
    final double qsrPriceInUsd = zenonToolsPriceInfo.qsrCurrentPriceInUsd;

    final double znnValueInUsd =
        double.parse(znnAmount.addDecimals(coinDecimals)) * znnPriceInUsd;
    final double qsrValueInUsd =
        double.parse(qsrAmount.addDecimals(coinDecimals)) * qsrPriceInUsd;

    return Column(
      children: [
        AssetListItem(
          iconColor: znnColor,
          bgColor: znnColor.withOpacity(0.2),
          coinAmount: znnAmount,
          coinName: kZnnCoin.symbol,
          usdValue: znnValueInUsd,
          rate: znnPriceInUsd,
        ),
        AssetListItem(
          iconColor: qsrColor,
          bgColor: qsrColor.withOpacity(0.2),
          coinAmount: qsrAmount,
          coinName: kQsrCoin.symbol,
          usdValue: qsrValueInUsd,
          rate: qsrPriceInUsd,
        ),
      ],
    );
  }
}
