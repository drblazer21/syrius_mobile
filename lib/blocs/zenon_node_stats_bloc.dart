import 'dart:async';

import 'package:syrius_mobile/blocs/base_bloc.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/zenon_node_stats.dart';

class ZenonNodeStatsBloc extends BaseBloc<ZenonNodeStats> {
  Future<void> fetch() async {
    try {
      final ZenonNodeStats generalStats = ZenonNodeStats(
        frontierMomentum: await zenon.ledger.getFrontierMomentum(),
        processInfo: await zenon.stats.processInfo(),
        networkInfo: await zenon.stats.networkInfo(),
        osInfo: await zenon.stats.osInfo(),
      );

      addEvent(generalStats);
    } on Exception catch (e) {
      addError(e);
    }
  }
}
