import 'dart:async';

import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class PlasmaStatsBloc extends BaseBloc<List<PlasmaInfoWrapper>>
    with RefreshBlocMixin {
  PlasmaStatsBloc() {
    listenToWsRestart(get);
  }

  Future<void> get() async {
    try {
      final List<PlasmaInfoWrapper> plasmaInfoWrapper = await Future.wait(
        kDefaultAddressList.map((e) => getPlasma(e)).toList(),
      );
      addEvent(plasmaInfoWrapper);
    } catch (e) {
      addError(e);
    }
  }

  Future<PlasmaInfoWrapper> getPlasma(String address) async {
    try {
      final PlasmaInfo plasmaInfo = await zenon.embedded.plasma.get(
        Address.parse(address),
      );
      return PlasmaInfoWrapper(address: address, plasmaInfo: plasmaInfo);
    } catch (e) {
      addError(e);
      rethrow;
    }
  }
}
