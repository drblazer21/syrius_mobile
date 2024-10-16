import 'package:big_decimal/big_decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class BalanceAndAddressWidget extends StatelessWidget {
  const BalanceAndAddressWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AddressWidget(),
        SizedBox(
          height: 5,
        ),
        Padding(
          padding: EdgeInsets.only(left: 15.0),
          child: _BalanceWidget(),
        ),
      ],
    );
  }
}

class _AddressWidget extends StatelessWidget {
  const _AddressWidget();

  @override
  Widget build(BuildContext context) {
    final Text child = Text(
      selectedAddress.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    void onTap() {
      showManageAddressScreen(context);
    }

    final TextButton textButton = TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: context.colorScheme.onSurface,
        minimumSize: const Size(30.0, 15.0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(
          horizontal: 15.0,
        ),
      ),
      onPressed: onTap,
      child: child,
    );

    return Row(
      children: [
        Flexible(child: textButton),
      ],
    );
  }
}

class _BalanceWidget extends StatefulWidget {
  const _BalanceWidget();

  @override
  State<_BalanceWidget> createState() => _BalanceWidgetState();
}

class _BalanceWidgetState extends State<_BalanceWidget> {
  late bool isHideBalance;

  @override
  Widget build(BuildContext context) {
    isHideBalance = sharedPrefs.getBool(
          kIsHideBalanceKey,
        ) ??
        false;
    switch (kSelectedAppNetworkWithAssets!.network.blockChain) {
      case BlockChain.btc:
        return _btcBalanceWidget();
      case BlockChain.evm:
        return _ethBalanceWidget();
      case BlockChain.nom:
        return _zenonBalanceWidget();
    }
  }

  Widget _ethBalanceWidget() {
    if (kSelectedAppNetworkWithAssets!.network.chainId != 1) {
      return _balanceText('0');
    }
    return AppStreamBuilder<EthAccountBalance>(
      stream: sl.get<EthAccountBalanceBloc>().stream,
      customErrorWidget: (error) {
        return Row(
          children: [
            Text(
              AppLocalizations.of(context)!.noConnection,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 25,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            const Icon(
              Icons.sync_problem,
              color: Colors.white70,
            ),
          ],
        );
      },
      customLoadingWidget: Skeletonizer(
        justifyMultiLineText: false,
        effect: const ShimmerEffect(
          baseColor: Colors.white30,
          highlightColor: Colors.white54,
        ),
        textBoneBorderRadius: const TextBoneBorderRadius.fromHeightFactor(0.5),
        ignoreContainers: true,
        child: Text(
          maxLines: 1,
          AppLocalizations.of(context)!.unavailable,
          style: context.textTheme.bodyLarge,
        ),
      ),
      builder: (ethAccountBalance) {
        return AppStreamBuilder<PriceInfo?>(
          stream: sl.get<PriceInfoBloc>().stream,
          customErrorWidget: (error) {
            return Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.notAvailable,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 25,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                const Icon(
                  Icons.sync_problem,
                  color: Colors.white70,
                ),
              ],
            );
          },
          builder: (snapshot) {
            BigDecimal usdBalance = BigDecimal.zero;

            for (final item in ethAccountBalance.items) {
              double priceInUsd;
              if (item.ethAsset.isCurrency) {
                priceInUsd = snapshot!.eth;
              } else {
                // We are computing the total, so we use zero if we don't know
                // the price of a token
                priceInUsd = snapshot!.ethToken(
                      contractAddress: item.ethAsset.contractAddressHex!,
                    ) ??
                    0.0;
              }

              final BigDecimal balance = item.balance.addDecimals(
                item.ethAsset.decimals,
              );

              final itemUsdBalance =
                  balance * BigDecimal.parse(priceInUsd.toString());

              usdBalance += itemUsdBalance;
            }

            return _balanceText(
              NumberFormat().format(
                usdBalance.toDouble(),
              ),
            );
          },
          customLoadingWidget: Skeletonizer(
            justifyMultiLineText: false,
            effect: const ShimmerEffect(
              baseColor: Colors.white30,
              highlightColor: Colors.white54,
            ),
            textBoneBorderRadius:
                const TextBoneBorderRadius.fromHeightFactor(0.5),
            ignoreContainers: true,
            child: Text(
              maxLines: 1,
              AppLocalizations.of(context)!.unavailable,
              style: context.textTheme.bodyLarge,
            ),
          ),
        );
      },
    );
  }

  Widget _zenonBalanceWidget() {
    if (kSelectedAppNetworkWithAssets!.network.chainId != 1) {
      return _balanceText('0');
    }
    return AppStreamBuilder<AccountInfo>(
      stream: sl.get<BalanceBloc>().stream,
      customErrorWidget: (error) {
        return Row(
          children: [
            Text(
              AppLocalizations.of(context)!.noConnection,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 25,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            const Icon(
              Icons.sync_problem,
              color: Colors.white70,
            ),
          ],
        );
      },
      customLoadingWidget: Skeletonizer(
        justifyMultiLineText: false,
        effect: const ShimmerEffect(
          baseColor: Colors.white30,
          highlightColor: Colors.white54,
        ),
        textBoneBorderRadius: const TextBoneBorderRadius.fromHeightFactor(0.5),
        ignoreContainers: true,
        child: Text(
          maxLines: 1,
          AppLocalizations.of(context)!.unavailable,
          style: context.textTheme.bodyLarge,
        ),
      ),
      builder: (snapshot) {
        final AccountInfo accountInfo = snapshot;
        return AppStreamBuilder<PriceInfo?>(
          stream: sl.get<PriceInfoBloc>().stream,
          customErrorWidget: (error) {
            return Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.notAvailable,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 25,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                const Icon(
                  Icons.sync_problem,
                  color: Colors.white70,
                ),
              ],
            );
          },
          builder: (snapshot) {
            final PriceInfo zenonPrice = snapshot!;
            BigInt znnBalance = BigInt.zero;
            znnBalance = accountInfo.getBalance(
              kZnnCoin.tokenStandard,
            );
            BigInt qsrBalance = BigInt.zero;
            qsrBalance = accountInfo.getBalance(
              kQsrCoin.tokenStandard,
            );
            double znnInUsd = 0;
            znnInUsd = zenonPrice.znn;
            double qsrInUsd = 0;
            qsrInUsd = zenonPrice.qsr;
            final double znnBalanceInUsd =
                double.parse(znnBalance.toStringWithDecimals(coinDecimals)) *
                    znnInUsd;
            final double qsrBalanceInUsd =
                double.parse(qsrBalance.toStringWithDecimals(coinDecimals)) *
                    qsrInUsd;
            final double totalBalanceInUsd = znnBalanceInUsd + qsrBalanceInUsd;
            return _balanceText(
              NumberFormat().format(
                totalBalanceInUsd,
              ),
            );
          },
          customLoadingWidget: Skeletonizer(
            justifyMultiLineText: false,
            effect: const ShimmerEffect(
              baseColor: Colors.white30,
              highlightColor: Colors.white54,
            ),
            textBoneBorderRadius:
                const TextBoneBorderRadius.fromHeightFactor(0.5),
            ignoreContainers: true,
            child: Text(
              maxLines: 1,
              AppLocalizations.of(context)!.unavailable,
              style: context.textTheme.bodyLarge,
            ),
          ),
        );
      },
    );
  }

  Widget _balanceText(String balanceToView) {
    return StreamBuilder<bool>(
      initialData: isHideBalance,
      stream: sl.get<HideBalanceBloc>().stream,
      builder: (context, snapshot) {
        final bool balanceVisibility = snapshot.data!;
        return GestureDetector(
          onTap: () async {
            await sharedPrefs.setBool(
              kIsHideBalanceKey,
              !balanceVisibility,
            );
            sl.get<HideBalanceBloc>().toggleHideBalance();
          },
          child: Text(
            balanceVisibility
                ? "••••••"
                : "${kSelectedCurrency.symbol}$balanceToView",
            style: context.textTheme.displaySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }

  Widget _btcBalanceWidget() {
    if (kSelectedAppNetworkWithAssets!.network.type == NetworkType.testnet) {
      return _balanceText('0.0');
    }
    return AppStreamBuilder<BtcAccountBalance>(
      stream: sl.get<BtcAccountBalanceBloc>().stream,
      customErrorWidget: (error) {
        return Row(
          children: [
            Text(
              AppLocalizations.of(context)!.noConnection,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 25,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            const Icon(
              Icons.sync_problem,
              color: Colors.white70,
            ),
          ],
        );
      },
      customLoadingWidget: Skeletonizer(
        justifyMultiLineText: false,
        effect: const ShimmerEffect(
          baseColor: Colors.white30,
          highlightColor: Colors.white54,
        ),
        textBoneBorderRadius: const TextBoneBorderRadius.fromHeightFactor(0.5),
        ignoreContainers: true,
        child: Text(
          maxLines: 1,
          AppLocalizations.of(context)!.unavailable,
          style: context.textTheme.bodyLarge,
        ),
      ),
      builder: (btcAccountBalance) {
        return AppStreamBuilder<PriceInfo?>(
          stream: sl.get<PriceInfoBloc>().stream,
          customErrorWidget: (error) {
            return Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.notAvailable,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 25,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                const Icon(
                  Icons.sync_problem,
                  color: Colors.white70,
                ),
              ],
            );
          },
          builder: (snapshot) {
            final double btcPriceInUsd = snapshot!.btc;
            final BigDecimal btcBalance =
                btcAccountBalance.confirmed.addDecimals(kBtcDecimals);

            final BigDecimal usdBalance = btcBalance *
                BigDecimal.parse(
                  btcPriceInUsd.toString(),
                );

            return _balanceText(
              NumberFormat().format(
                usdBalance.toDouble(),
              ),
            );
          },
          customLoadingWidget: Skeletonizer(
            justifyMultiLineText: false,
            effect: const ShimmerEffect(
              baseColor: Colors.white30,
              highlightColor: Colors.white54,
            ),
            textBoneBorderRadius:
                const TextBoneBorderRadius.fromHeightFactor(0.5),
            ignoreContainers: true,
            child: Text(
              maxLines: 1,
              AppLocalizations.of(context)!.unavailable,
              style: context.textTheme.bodyLarge,
            ),
          ),
        );
      },
    );
  }
}
