import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class PillarRewardsHistoryBloc
    extends BaseBlocForReloadingIndicator<RewardHistoryList> {
  @override
  Future<RewardHistoryList> getDataAsync() async {
    final RewardHistoryList rewardHistoryList =
        await zenon.embedded.pillar.getFrontierRewardByPage(
      Address.parse(kSelectedAddress!.hex),
      pageSize: kStandardChartNumDays.toInt(),
    );
    if (rewardHistoryList.list.any(_entryHasRewards)) {
      return rewardHistoryList;
    } else {
      throw 'No rewards in the last week';
    }
  }

  bool _entryHasRewards(RewardHistoryEntry entry) =>
      entry.znnAmount > BigInt.zero;
}
