import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class PillarUncollectedRewardsBloc
    extends BaseBlocForReloadingIndicator<UncollectedReward> {
  @override
  Future<UncollectedReward> getDataAsync() =>
      zenon.embedded.pillar.getUncollectedReward(
        Address.parse(
          kSelectedAddress!.hex,
        ),
      );
}
