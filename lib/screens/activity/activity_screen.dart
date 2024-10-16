import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final LatestTransactionsBloc _latestTransactionsBloc =
      sl.get<LatestTransactionsBloc>();
  final EthActivityBloc _ethActivityBloc = EthActivityBloc();
  final BtcActivityBloc _btcActivityBloc = sl.get<BtcActivityBloc>();

  @override
  void initState() {
    super.initState();
    switch (kSelectedAppNetworkWithAssets!.network.blockChain) {
      case BlockChain.btc:
        if (_btcActivityBloc.lastValue == null) {
          _btcActivityBloc.fetch(addressHex: selectedAddress.hex);
        }
      case BlockChain.evm:
        _ethActivityBloc.refreshResults();
      case BlockChain.nom:
        _latestTransactionsBloc.refreshResults();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.activity,
      withLateralPadding: false,
      withBottomPadding: false,
      child: Consumer<SelectedAddressNotifier>(
        builder: (BuildContext context, value, Widget? child) {
          switch (kSelectedAppNetworkWithAssets!.network.blockChain) {
            case BlockChain.btc:
              return _btcActivity();
            case BlockChain.evm:
              return _ethActivity();
            case BlockChain.nom:
              return _znnActivity();
          }
        },
      ),
    );
  }

  PaginatedListView<AccountBlock> _znnActivity() {
    return PaginatedListView<AccountBlock>(
      bloc: _latestTransactionsBloc,
      disposeBloc: false,
      itemBuilder: (_, accountBlock, __) {
        return ActivityItem(
          accountBlock: accountBlock,
        );
      },
    );
  }

  PaginatedListView<EthereumTx> _ethActivity() {
    return PaginatedListView<EthereumTx>(
      bloc: _ethActivityBloc,
      disposeBloc: false,
      itemBuilder: (_, tx, __) => EthActivityItem(tx: tx),
    );
  }

  Widget _btcActivity() {
    return RefreshIndicator.adaptive(
      onRefresh: () => _btcActivityBloc.fetch(
        addressHex: selectedAddress.hex,
      ),
      child: StreamBuilder(
        initialData: BtcActivityInitial(),
        stream: _btcActivityBloc.stream,
        builder: (_, snapshot) {
          switch (snapshot.data!) {
            case BtcActivityInitial():
              return const SyriusLoadingWidget();
            case BtcActivityLoading():
              return const SyriusLoadingWidget();
            case BtcActivityLoaded():
              final BtcActivityLoaded loaded =
                  snapshot.data! as BtcActivityLoaded;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: loaded.txs.length,
                  itemBuilder: (_, index) => BtcActivityItem(
                    tx: loaded.txs[index],
                  ),
                ),
              );
            case BtcActivityError():
              final BtcActivityError error = snapshot.data! as BtcActivityError;
              return SyriusErrorWidget(error.message);
          }
        },
      ),
    );
  }
}
