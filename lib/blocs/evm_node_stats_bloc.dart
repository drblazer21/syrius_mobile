import 'dart:async';

import 'package:syrius_mobile/blocs/base_bloc.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';

class EvmNodeStatsBloc extends BaseBloc<EvmNodeStats> {
  Future<void> fetch() async {
    try {
      final EvmNodeStats evmNodeStats = await eth.getNodeStats();

      addEvent(evmNodeStats);
    } on Exception catch (e) {
      addError(e);
    }
  }
}
