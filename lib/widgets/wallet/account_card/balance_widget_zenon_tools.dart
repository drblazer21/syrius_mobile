import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/extensions/extensions.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class BalanceAndAddressWidgetZenonTools extends StatelessWidget {
  const BalanceAndAddressWidgetZenonTools({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AddressWidget(),
        SizedBox(
          height: 5,
        ),
        _BalanceWidget(),
      ],
    );
  }
}

class _AddressWidget extends StatelessWidget {
  const _AddressWidget();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            showModalBottomSheetWithBody(
              context: context,
              body: const ReceiveModalBottomSheet(),
            );
          },
          child: Row(
            children: [
              Text(
                shortenWalletAddress(
                  getAddress(),
                  prefixCharactersCount: 4,
                ),
              ),
              kIconAndTextHorizontalSpacer,
              const Icon(
                Icons.qr_code,
                color: Colors.white60,
              ),
            ],
          ),
        ),
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
    isHideBalance = sharedPrefsService.get<bool>(
      kIsHideBalanceKey,
      defaultValue: false,
    )!;
    return _zenonBalanceWidget();
  }

  Widget _zenonBalanceWidget() {
    return AppStreamBuilder<Map<String, AccountInfo>?>(
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
        final AccountInfo accountInfo = snapshot![kSelectedAddress]!;
        return AppStreamBuilder<ZenonToolsPriceInfo?>(
          stream: sl.get<ZenonToolsPriceBloc>().stream,
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
            final ZenonToolsPriceInfo zenonPrice = snapshot!;
            BigInt znnBalance = BigInt.zero;
            znnBalance = accountInfo.getBalance(
              kZnnCoin.tokenStandard,
            );
            BigInt qsrBalance = BigInt.zero;
            qsrBalance = accountInfo.getBalance(
              kQsrCoin.tokenStandard,
            );
            double znnInUsd = 0;
            znnInUsd = zenonPrice.znnCurrentPriceInUsd;
            double qsrInUsd = 0;
            qsrInUsd = zenonPrice.qsrCurrentPriceInUsd;
            final double znnBalanceInUsd =
                double.parse(znnBalance.addDecimals(coinDecimals)) * znnInUsd;
            final double qsrBalanceInUsd =
                double.parse(qsrBalance.addDecimals(coinDecimals)) * qsrInUsd;
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
            await sharedPrefsService.put(
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
}
