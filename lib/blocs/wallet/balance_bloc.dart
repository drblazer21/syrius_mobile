import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class BalanceBloc extends BaseBloc<Map<String, AccountInfo>?>
    with RefreshBlocMixin {
  BalanceBloc() {
    listenToWsRestart(getForAllAddresses);
  }

  Future<void> getForAllAddresses() async {
    try {
      final Map<String, AccountInfo> addressBalanceMap = {};
      final List<AccountInfo> accountInfoList = await Future.wait(
        kDefaultAddressList.map(
          (address) => _getBalancePerAddress(
            address,
          ),
        ),
      );
      for (final accountInfo in accountInfoList) {
        addressBalanceMap[accountInfo.address!] = accountInfo;
      }
      addEvent(addressBalanceMap);
    } catch (e) {
      addError(e);
    }
  }

  Future<AccountInfo> _getBalancePerAddress(String addressString) async {
    final Address address = await compute(Address.parse, addressString);
    return zenon.ledger.getAccountInfoByAddress(
      address,
    );
  }
}
