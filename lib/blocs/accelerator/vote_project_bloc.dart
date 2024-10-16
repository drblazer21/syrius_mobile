import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class VoteProjectBloc extends BaseBloc<AccountBlockTemplate?> {
  Future<void> voteProject(Hash id, AcceleratorProjectVote vote) async {
    try {
      addEvent(null);
      final PillarInfo pillarInfo = (await zenon.embedded.pillar.getByOwner(
        Address.parse(kSelectedAddress!.hex),
      ))
          .first;
      final AccountBlockTemplate transactionParams =
          zenon.embedded.accelerator.voteByName(
        id,
        pillarInfo.name,
        vote.index,
      );
      createAccountBlock(
        transactionParams,
        'vote for project', actionType: ActionType.voteForProject,
      )
          .then(
        (block) => addEvent(block),
      )
          .onError(
        (error, stackTrace) {
          addError(error ?? stackTrace);
        },
      );
    } catch (e) {
      addError(e);
    }
  }
}
