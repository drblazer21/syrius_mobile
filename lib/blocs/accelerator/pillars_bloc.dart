import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/global.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

/// This bloc initializes the number of pillars on the network and adds to
/// the stream a list of the owned streams by the user
class PillarsBloc extends BaseBloc<List<PillarInfo>> {
  Future<void> fetchInfo() async {
    try {
      final int numOfPillars = (await zenon.embedded.pillar.getAll()).list.length;
      kNumOfPillars = numOfPillars;
      final List<PillarInfo> ownedPillars = await zenon.embedded.pillar.getByOwner(
        Address.parse(kSelectedAddress!.hex),
      );
      addEvent(ownedPillars);
    } on Exception catch (e) {
      addError(e);
    }
  }
}
