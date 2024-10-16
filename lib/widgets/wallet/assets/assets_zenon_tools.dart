import 'package:big_decimal/big_decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/wallet/assets/eth_account_balance_item_widget.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class AssetsZenonTools extends StatefulWidget {
  const AssetsZenonTools({super.key});

  @override
  State<AssetsZenonTools> createState() => _AssetsZenonToolsState();
}

class _AssetsZenonToolsState extends State<AssetsZenonTools> {
  @override
  Widget build(BuildContext context) {
    switch (kSelectedAppNetworkWithAssets!.network.blockChain) {
      case BlockChain.btc:
        return _getBtcBalanceStreamBuilder();
      case BlockChain.evm:
        return _getEthBalanceStreamBuilder();
      case BlockChain.nom:
        return _getBalanceStreamBuilder();
    }
  }

  Widget skeleton = Skeletonizer(
    child: Column(
      children: [
        AssetListItem(
          coinName: kZnnCoin.symbol,
          bgColor: Colors.white10,
          coinAmount: BigDecimal.zero,
          rate: 0,
          usdValue: BigDecimal.zero,
          iconColor: Colors.white24,
        ),
        AssetListItem(
          coinName: kQsrCoin.symbol,
          bgColor: Colors.white10,
          coinAmount: BigDecimal.zero,
          rate: 0,
          usdValue: BigDecimal.zero,
          iconColor: Colors.white24,
        ),
      ],
    ),
  );

  Widget _getBalanceStreamBuilder() {
    return StreamBuilder<AccountInfo>(
      stream: sl.get<BalanceBloc>().stream,
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          return SyriusErrorWidget(snapshot.error!);
        }
        if (snapshot.hasData) {
          Logger('DashboardAssetsZenonTools').log(Level.INFO, snapshot.data);
          return _getBodyAssets(
            snapshot.data!,
          );
        }
        return skeleton;
      },
    );
  }

  Widget _getEthBalanceStreamBuilder() {
    return StreamBuilder<EthAccountBalance>(
      stream: sl.get<EthAccountBalanceBloc>().stream,
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          return SyriusErrorWidget(snapshot.error!);
        }
        if (snapshot.hasData) {
          Logger('Wallet Screen - ETH Assets').log(Level.INFO, snapshot.data);

          final EthAccountBalance accountBalance = snapshot.data!;

          return Column(
            children: [
              TextButton(
                onPressed: () {
                  showAddNewTokenScreen(context: context);
                },
                child: Text(AppLocalizations.of(context)!.addNewToken),
              ),
              Expanded(
                child: RefreshIndicator.adaptive(
                  onRefresh: () async {
                    sl.get<EthAccountBalanceBloc>().fetch(
                          address: kEthSelectedAddress!.toEthAddress(),
                        );
                    sl.get<PriceInfoBloc>().getPrice();
                  },
                  child: AppStreamBuilder<PriceInfo?>(
                    stream: sl.get<PriceInfoBloc>().stream,
                    builder: (snapshot) {
                      return ListView.builder(
                        itemCount: accountBalance.items.length,
                        itemBuilder: (_, index) => EthAccountBalanceItemWidget(
                          item: accountBalance.items[index],
                          priceInfo: snapshot!,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }
        return skeleton;
      },
    );
  }

  Widget _getBodyAssets(AccountInfo accountInfo) {
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        sl.get<BalanceBloc>().get();
        sl.get<PriceInfoBloc>().getPrice();
      },
      child: AppStreamBuilder<PriceInfo?>(
        stream: sl.get<PriceInfoBloc>().stream,
        builder: (snapshot) {
          final int itemCount = accountInfo.balanceInfoList!.length;

          return ListView.builder(
            itemCount: itemCount,
            itemBuilder: (_, index) {
              final BalanceInfoListItem balanceItem =
                  accountInfo.balanceInfoList![index];

              return AssetsZenonToolsPriceInfo(
                balanceItem: balanceItem,
                zenonToolsPriceInfo: snapshot!,
              );
            },
          );
        },
        customErrorWidget: (String error) => SyriusErrorWidget(error),
        customLoadingWidget: skeleton,
      ),
    );
  }

  Widget _getBtcBalanceStreamBuilder() {
    return StreamBuilder<BtcAccountBalance>(
      stream: sl.get<BtcAccountBalanceBloc>().stream,
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          return SyriusErrorWidget(snapshot.error!);
        }
        if (snapshot.hasData) {
          Logger('Wallet Screen - BTC Assets').log(Level.INFO, snapshot.data);

          final BtcAccountBalance accountBalance = snapshot.data!;

          return RefreshIndicator.adaptive(
            onRefresh: () async {
              sl.get<BtcAccountBalanceBloc>().fetch(
                    addressHex: selectedAddress.hex,
                  );
              sl.get<PriceInfoBloc>().getPrice();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: AppStreamBuilder<PriceInfo?>(
                stream: sl.get<PriceInfoBloc>().stream,
                builder: (snapshot) {
                  return BtcAccountBalanceWidget(
                    accountBalance: accountBalance,
                    priceInfo: snapshot!,
                  );
                },
              ),
            ),
          );
        }
        return skeleton;
      },
    );
  }
}
