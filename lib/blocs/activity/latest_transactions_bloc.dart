import 'dart:async';

import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class LatestTransactionsBloc extends InfiniteScrollBloc<AccountBlock> {
  @override
  Future<List<AccountBlock>> getData(int pageKey, int pageSize) async =>
      (await zenon.ledger.getAccountBlocksByPage(
        Address.parse(kSelectedAddress!.hex),
        pageIndex: pageKey,
        pageSize: pageSize,
      ))
          .list!;
}
