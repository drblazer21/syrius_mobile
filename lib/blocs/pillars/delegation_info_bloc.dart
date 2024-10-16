import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class DelegationInfoBloc extends BaseBlocWithRefreshMixin<DelegationInfo?> {
  @override
  Future<DelegationInfo?> getDataAsync() =>
      zenon.embedded.pillar.getDelegatedPillar(
        Address.parse(kSelectedAddress!.hex),
      );
}
