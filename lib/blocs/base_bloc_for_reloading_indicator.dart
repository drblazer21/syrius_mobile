import 'dart:async';

import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

abstract class BaseBlocForReloadingIndicator<T> extends BaseBloc<T?>
    with RefreshBlocMixin {
  Future<T> getDataAsync();

  BaseBlocForReloadingIndicator() {
    updateStream();
    listenToWsRestart(updateStream);
  }

  Future<void> updateStream() async {
    try {
      addEvent(null);
      if (!zenon.wsClient.isClosed()) {
        addEvent(await getDataAsync());
      } else {
        throw noConnectionException;
      }
    } catch (e) {
      addError(e);
    }
  }

  @override
  void dispose() {
    cancelStreamSubscription();
    super.dispose();
  }
}
