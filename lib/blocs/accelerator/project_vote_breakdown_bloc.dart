import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class ProjectVoteBreakdownBloc
    extends BaseBloc<Pair<VoteBreakdown, List<PillarVote?>?>?> {
  Future<void> getVoteBreakdown(String? pillarName, Hash projectId) async {
    try {
      addEvent(null);
      final VoteBreakdown voteBreakdown =
          await zenon.embedded.accelerator.getVoteBreakdown(
        projectId,
      );
      List<PillarVote?>? pillarVoteList;
      if (pillarName != null) {
        pillarVoteList = await zenon.embedded.accelerator.getPillarVotes(
          pillarName,
          [
            projectId.toString(),
          ],
        );
      }
      addEvent(Pair(voteBreakdown, pillarVoteList));
    } catch (e) {
      addError(e);
    }
  }
}
