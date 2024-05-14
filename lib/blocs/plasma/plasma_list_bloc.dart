import 'dart:async';

import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class PlasmaListBloc extends InfiniteScrollBloc<FusionEntry> {
  int? lastMomentumHeight;

  @override
  Future<List<FusionEntry>> getData(int pageKey, int pageSize) async {
    final List<FusionEntry> results =
        (await zenon.embedded.plasma.getEntriesByAddress(
      Address.parse(kSelectedAddress!),
      pageIndex: pageKey,
      pageSize: pageSize,
    ))
            .list;
    final Momentum lastMomentum = await zenon.ledger.getFrontierMomentum();
    lastMomentumHeight = lastMomentum.height;
    for (final fusionEntry in results) {
      fusionEntry.isRevocable =
          lastMomentum.height > fusionEntry.expirationHeight;
    }
    return results;
  }
}
