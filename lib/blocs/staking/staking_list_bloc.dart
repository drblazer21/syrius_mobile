import 'dart:async';

import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class StakingListBloc extends InfiniteScrollBloc<StakeEntry> {
  @override
  Future<List<StakeEntry>> getData(int pageKey, int pageSize) async =>
      (await zenon.embedded.stake.getEntriesByAddress(
        Address.parse(kSelectedAddress!.hex),
        pageIndex: pageKey,
        pageSize: pageSize,
      ))
          .list;
}
