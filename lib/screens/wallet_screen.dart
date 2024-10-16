import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/block_chain.dart';
import 'package:syrius_mobile/utils/notifiers/backed_up_seed_notifier.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:web3dart/web3dart.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    sl.get<PriceInfoBloc>().getPrice();
  }

  @override
  Widget build(BuildContext context) {
    const double leadingWidth = 100.0;

    return CustomAppbarScreen(
      appbarTitleWidget: _buildAppNetworkDropdown(),
      leadingWidth: leadingWidth,
      leadingWidget: _buildLeadingWidget(),
      withLateralPadding: false,
      withBottomPadding: false,
      actionWidget: SizedBox(
        width: leadingWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            notificationsIcon(
              context,
            ),
          ],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: context.listTileTheme.contentPadding!,
            child: Consumer<SelectedAddressNotifier>(
              builder: (_, __, ___) {
                return AccountCard(
                  key: UniqueKey(),
                );
              },
            ),
          ),
          kVerticalSpacer,
          Consumer<BackedUpSeedNotifier>(
            builder: (_, notifier, __) {
              return Visibility(
                visible: !notifier.isBackedUp,
                child: Padding(
                  padding: context.listTileTheme.contentPadding!.add(
                    EdgeInsets.only(
                      bottom:
                          !notifier.isBackedUp ? kVerticalSpacer.height! : 0.0,
                    ),
                  ),
                  child: BackupWarning(),
                ),
              );
            },
          ),
          Expanded(
            child: AssetsZenonTools(
              key: UniqueKey(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showPowGenerationStatus() {
    return StreamBuilder<PowStatus>(
      stream: sl.get<PowGeneratingStatusBloc>().stream,
      builder: (_, snapshot) {
        Widget? plasmaIndicator;
        if (snapshot.hasData && snapshot.data == PowStatus.generating) {
          plasmaIndicator = Tooltip(
            message: AppLocalizations.of(context)!.generatingPlasma,
            child: const SyriusLoadingWidget(
              size: 20.0,
              strokeWidth: 2.0,
            ),
          );
        }
        plasmaIndicator ??= Tooltip(
          message: AppLocalizations.of(context)!.plasmaGenerationIdle,
          child: const Icon(
            Icons.flash_on,
          ),
        );

        return Padding(
          padding: const EdgeInsets.only(
            left: 12.0,
          ),
          child: Row(
            children: [plasmaIndicator],
          ),
        );
      },
    );
  }

  Widget _showGasPrice() {
    return StreamBuilder<GasPriceState>(
      initialData: GasPriceInitial(),
      stream: sl.get<GasPriceBloc>().stream,
      builder: (_, snapshot) {
        String message = '? Gwei';

        switch (snapshot.data!) {
          case GasPriceInitial _:
            return Padding(
              padding: const EdgeInsets.only(
                left: 12.0,
              ),
              child: Row(
                children: [
                  Skeletonizer(
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
                      message,
                      style: context.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            );
          case GasPriceLoaded _:
            final GasPriceLoaded gasPriceLoaded =
                snapshot.data! as GasPriceLoaded;
            final double priceInGwei =
                gasPriceLoaded.gasPrice.getValueInUnit(EtherUnit.gwei);
            message = '${priceInGwei.round()} Gwei';
          case GasPriceError _:
            message = 'Error: ${(snapshot.data! as GasPriceError).message}';
        }
        return Padding(
          padding: const EdgeInsets.only(
            left: 12.0,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.local_gas_station,
              ),
              Expanded(
                child: Text(
                  message,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppNetworkDropdown() {
    return TextButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.only(
          left: 18.0,
          right: 2,
        ),
      ),
      icon: const Icon(
        Icons.arrow_drop_down,
      ),
      iconAlignment: IconAlignment.end,
      label: Text(
        kSelectedAppNetworkWithAssets!.network.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          useSafeArea: true,
          builder: (_) => DraggableScrollableSheet(
            expand: false,
            builder: (_, scrollController) => AllNetworks(
              onNetworkChanged: () {
                setState(() {});
              },
              scrollController: scrollController,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeadingWidget() {
    switch (kSelectedAppNetworkWithAssets!.network.blockChain) {
      case BlockChain.nom:
        return _showPowGenerationStatus();
      case BlockChain.evm:
        return _showGasPrice();
      default:
        return const BtcEstimateFeeWidget();
    }
  }
}
