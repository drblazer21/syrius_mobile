import 'dart:async';

import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class UnwrapSignedRequestsBloc extends InfiniteScrollBloc<UnwrapTokenRequest> {
  @override
  Future<List<UnwrapTokenRequest>> getData(int pageKey, int pageSize) async =>
      (await zenon.embedded.bridge.getAllUnwrapTokenRequestsByToAddress(
        kSelectedAddress!.hex,
        pageIndex: pageKey,
        pageSize: pageSize,
      ))
          .list;
}
