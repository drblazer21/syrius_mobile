import 'dart:async';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class AcceleratorBalanceBloc extends BaseBloc<AccountInfo?> {
  Future<void> getAcceleratorBalance() async {
    try {
      final AccountInfo accountInfo = await zenon.ledger.getAccountInfoByAddress(
        acceleratorAddress,
      );
      if (accountInfo.qsr()! > BigInt.zero ||
          accountInfo.znn()! > BigInt.zero) {
        addEvent(accountInfo);
      } else {
        throw 'Accelerator fund empty';
      }
    } catch (e, _) {
      addError(e);
    }
  }
}
