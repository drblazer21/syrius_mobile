import 'dart:async';

import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class BalanceBloc extends BaseBloc<AccountInfo> with RefreshBlocMixin {
  BalanceBloc() {
    listenToWsRestart(() => get());
  }

  Future<void> get([AppAddress? appAddress]) async {
    try {
      final AccountInfo accountInfo = await _getBalancePerAddress(
        appAddress ?? kSelectedAddress!,
      );
      final List<BalanceInfoListItem> items = accountInfo.balanceInfoList!;

      if (accountInfo.findTokenByTokenStandard(kZnnCoin.tokenStandard) == null) {
        items.add(
          BalanceInfoListItem(token: kZnnCoin, balance: BigInt.zero),
        );
      }

      if (accountInfo.findTokenByTokenStandard(kQsrCoin.tokenStandard) == null) {
        items.add(
          BalanceInfoListItem(token: kQsrCoin, balance: BigInt.zero),
        );
      }

      accountInfo.balanceInfoList = items;

      addEvent(accountInfo);
    } catch (e) {
      addError(e);
    }
  }

  Future<AccountInfo> _getBalancePerAddress(AppAddress address) async {
    return zenon.ledger.getAccountInfoByAddress(
      address.toZnnAddress(),
    );
  }
}
