import 'dart:async';

import 'package:syrius_mobile/blocs/base_bloc.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/electrum_btc_node_stats.dart';

class BtcNodeStatsBloc extends BaseBloc<ElectrumBtcNodeStats> {
  Future<void> fetch() async {
    try {
      final ElectrumBtcNodeStats nodeStats = await btc.getNodeStats();

      addEvent(nodeStats);
    } on Exception catch (e) {
      addError(e);
    }
  }
}
