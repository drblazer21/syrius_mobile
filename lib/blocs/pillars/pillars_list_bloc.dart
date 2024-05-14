import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class PillarsListBloc extends InfiniteScrollBloc<PillarInfo> {
  @override
  Future<List<PillarInfo>> getData(int pageKey, int pageSize) async {
    final PillarInfoList pillarInfoList = await zenon.embedded.pillar.getAll(
      pageIndex: pageKey,
      pageSize: pageSize,
    );

    return pillarInfoList.list;
  }
}
