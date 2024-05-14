import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class AssetsZenonTools extends StatefulWidget {
  const AssetsZenonTools({super.key});

  @override
  State<AssetsZenonTools> createState() => _AssetsZenonToolsState();
}

class _AssetsZenonToolsState extends State<AssetsZenonTools>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _getBalanceStreamBuilder();
  }

  Widget skeleton = Skeletonizer(
    child: Column(
      children: [
        AssetListItem(
          coinName: kZnnCoin.symbol,
          bgColor: Colors.white10,
          coinAmount: BigInt.zero,
          rate: 0,
          usdValue: 0,
          iconColor: Colors.white24,
        ),
        AssetListItem(
          coinName: kQsrCoin.symbol,
          bgColor: Colors.white10,
          coinAmount: BigInt.zero,
          rate: 0,
          usdValue: 0,
          iconColor: Colors.white24,
        ),
      ],
    ),
  );

  Widget _getBalanceStreamBuilder() {
    return StreamBuilder<Map<String, AccountInfo>?>(
      stream: sl.get<BalanceBloc>().stream,
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          return SyriusErrorWidget(snapshot.error!);
        }
        if (snapshot.hasData) {
          Logger('DashboardAssetsZenonTools').log(Level.INFO, snapshot.data);
          return _getBodyAssets(
            snapshot.data![kSelectedAddress]!,
          );
        }
        return skeleton;
      },
    );
  }

  Widget _getBodyAssets(AccountInfo accountInfo) {
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        sl.get<ZenonToolsPriceBloc>().getPrice();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          AppStreamBuilder<ZenonToolsPriceInfo?>(
            stream: sl.get<ZenonToolsPriceBloc>().stream,
            builder: (snapshot) {
              return AssetsZenonToolsPriceInfo(
                accountInfo: accountInfo,
                zenonToolsPriceInfo: snapshot!,
              );
            },
            customErrorWidget: (String error) => SyriusErrorWidget(error),
            customLoadingWidget: skeleton,
          ),
        ],
      ),
    );
  }
}
