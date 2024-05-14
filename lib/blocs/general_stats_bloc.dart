import 'dart:async';

import 'package:syrius_mobile/blocs/base_bloc_with_refresh_mixin.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/general_stats.dart';
import 'package:syrius_mobile/utils/misc_utils.dart';

class GeneralStatsBloc extends BaseBlocWithRefreshMixin<GeneralStats> {
  @override
  Future<GeneralStats> getDataAsync() async {
    final GeneralStats generalStats = GeneralStats(
      frontierMomentum: await zenon.ledger.getFrontierMomentum(),
      processInfo: await zenon.stats.processInfo(),
      networkInfo: await zenon.stats.networkInfo(),
      osInfo: await zenon.stats.osInfo(),
      appIntegrity: await getAppIntegrityStatus(),
    );

    return generalStats;
  }
}
