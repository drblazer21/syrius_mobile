import 'dart:math';

import 'package:flutter/material.dart';
import 'package:syrius_mobile/blocs/accelerator/accelerator.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class AcceleratorProjectListItem extends StatefulWidget {
  final AcceleratorProject acceleratorProject;
  final PillarInfo? pillarInfo;
  final Project? project;

  const AcceleratorProjectListItem({
    super.key,
    required this.acceleratorProject,
    this.pillarInfo,
    this.project,
  });

  @override
  State<AcceleratorProjectListItem> createState() =>
      _AcceleratorProjectListItemState();
}

class _AcceleratorProjectListItemState
    extends State<AcceleratorProjectListItem> {
  final VoteProjectBloc _voteProjectBloc = VoteProjectBloc();
  final ProjectVoteBreakdownBloc _projectVoteBreakdownBloc =
      ProjectVoteBreakdownBloc();

  @override
  void dispose() {
    _voteProjectBloc.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _projectVoteBreakdownBloc.getVoteBreakdown(
      widget.pillarInfo?.name,
      widget.acceleratorProject.id,
    );
    _projectVoteBreakdownBloc.stream.listen(
      (event) {},
      onError: (error) {
        sendNotificationError(
          'Error while trying to get the vote breakdown',
          error,
        );
      },
    );
    _voteProjectBloc.stream.listen(
      (event) {
        if (event != null) {
          _projectVoteBreakdownBloc.getVoteBreakdown(
            widget.pillarInfo?.name,
            widget.acceleratorProject.id,
          );
        }
      },
      onError: (error) {
        sendNotificationError(
          'Error while voting project',
          error,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(
        10.0,
      ),
      onTap: widget.acceleratorProject is Project
          ? () {
              showAcceleratorProjectDetailsScreen(
                context: context,
                pillarInfo: widget.pillarInfo,
                project: widget.acceleratorProject,
              );
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 10.0,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          borderRadius: BorderRadius.circular(
            10.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _getProjectTitle(context),
            const SizedBox(
              height: 10.0,
            ),
            AcceleratorProjectDetails(
              owner: widget.acceleratorProject is Project
                  ? (widget.acceleratorProject as Project).owner
                  : null,
              hash: widget.acceleratorProject.id,
              creationTimestamp: widget.acceleratorProject.creationTimestamp,
              acceleratorProjectStatus: widget.acceleratorProject.status,
            ),
            const SizedBox(
              height: 10.0,
            ),
            _getProjectDescription(context),
            const SizedBox(
              height: 10.0,
            ),
            _getProjectStatuses(context),
            const SizedBox(
              height: 10.0,
            ),
            _getProjectVoteBreakdownViewModel(context),
          ],
        ),
      ),
    );
  }

  Widget _getVotingRow(
    BuildContext context,
    VoteBreakdown voteBreakdown,
    List<PillarVote?>? pillarVoteList,
    ProjectVoteBreakdownBloc projectVoteBreakdownViewModel,
  ) {
    return Column(
      children: [
        Visibility(
          visible: voteBreakdown.total > 0,
          child: _getVotingResults(context, voteBreakdown),
        ),
        kVerticalSpacer,
        _getVotingResultsIcon(
          context,
          pillarVoteList,
          projectVoteBreakdownViewModel,
        ),
      ],
    );
  }

  Widget _getProjectTitle(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.acceleratorProject.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ],
    );
  }

  Widget _getProjectDescription(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.acceleratorProject.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }

  Widget _getProjectStatuses(BuildContext context) {
    final List<Widget> tags = [
      _getProjectStatusTag(),
    ];

    if (widget.acceleratorProject.znnFundsNeeded > BigInt.zero) {
      tags.add(
        _getProjectZnnFundsNeededTag(context),
      );
    }

    if (widget.acceleratorProject.qsrFundsNeeded > BigInt.zero) {
      tags.add(
        _getProjectQsrFundsNeededTag(context),
      );
    }

    if (widget.acceleratorProject is Project &&
        (widget.acceleratorProject as Project).phases.isNotEmpty &&
        (widget.acceleratorProject as Project).phases.last.status ==
            AcceleratorProjectStatus.voting) {
      tags.add(
        Chip(
          label: const Text('Phase needs voting'),
          backgroundColor: znnColor.withOpacity(0.7),
        ),
      );
    }

    return Wrap(
      spacing: 5.0,
      children: tags,
    );
  }

  Widget _getProjectStatusTag() {
    if (widget.acceleratorProject.status == AcceleratorProjectStatus.closed) {
      return Chip(
        label: Text(
          'Rejected',
          style: TextStyle(
            color: context.colorScheme.surface,
          ),
        ),
        backgroundColor: context.colorScheme.error,
      );
    }
    if (widget.acceleratorProject.status == AcceleratorProjectStatus.active) {
      return const Chip(
        label: Text('Accepted'),
        backgroundColor: znnColor,
      );
    }
    if (widget.acceleratorProject.status == AcceleratorProjectStatus.voting) {
      return Chip(
        avatar: const Icon(Icons.how_to_vote),
        label: const Text('Voting open'),
        backgroundColor: znnColor.withOpacity(0.7),
      );
    }
    if (widget.acceleratorProject.status == AcceleratorProjectStatus.paid) {
      return const Chip(
        label: Text('Paid'),
        backgroundColor: Colors.orange,
      );
    }
    if (widget.acceleratorProject.status ==
        AcceleratorProjectStatus.completed) {
      return const Chip(
        label: Text('Completed'),
        backgroundColor: qsrColor,
      );
    }
    return const Chip(
      label: Text('Wrong status'),
    );
  }

  Widget _getProjectZnnFundsNeededTag(BuildContext context) {
    return Chip(
      label: Text(
          '${widget.acceleratorProject.znnFundsNeeded.addDecimals(coinDecimals)} '
          '${kZnnCoin.symbol}'),
    );
  }

  Widget _getProjectQsrFundsNeededTag(BuildContext context) {
    return Chip(
      label: Text(
        '${widget.acceleratorProject.qsrFundsNeeded.addDecimals(coinDecimals)} ${kQsrCoin.symbol}',
      ),
    );
  }

  Widget _getVotingResults(
    BuildContext context,
    VoteBreakdown voteBreakdown,
  ) {
    final int yesVotes = voteBreakdown.yes;
    final int noVotes = voteBreakdown.no;
    final int quorum = voteBreakdown.total;
    final int abstainVotes = voteBreakdown.total - yesVotes - noVotes;
    final int quorumNeeded = (kNumOfPillars! * 0.33).ceil();
    final int votesToAchieveQuorum = max(0, quorumNeeded - quorum);
    final int pillarsThatCanStillVote = kNumOfPillars! -
        quorum -
        (votesToAchieveQuorum > 0 ? votesToAchieveQuorum : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Voting results'),
          ],
        ),
        kVerticalSpacer,
        Row(
          children: [
            Expanded(
              child: AcceleratorProgressBar(
                spans: [
                  AcceleratorProgressBarSpan(
                    value: yesVotes,
                    color: znnColor,
                    tooltipMessage: '$yesVotes Yes votes',
                  ),
                  AcceleratorProgressBarSpan(
                    value: noVotes,
                    color: context.colorScheme.error,
                    tooltipMessage: '$noVotes No votes',
                  ),
                  AcceleratorProgressBarSpan(
                    value: abstainVotes,
                    color: Colors.white12,
                    tooltipMessage: '$abstainVotes Abstain votes',
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 10.0,
            ),
            Tooltip(
              message: yesVotes > noVotes
                  ? 'More yes than no votes'
                  : 'Not enough yes votes',
              child: Icon(
                Icons.check_circle,
                color: yesVotes > noVotes
                    ? znnColor
                    : Theme.of(context).colorScheme.secondary,
                size: 15.0,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10.0,
        ),
        Row(
          children: [
            Expanded(
              child: AcceleratorProgressBar(
                spans: [
                  AcceleratorProgressBarSpan(
                    value: quorum,
                    color: qsrColor,
                    tooltipMessage: '${voteBreakdown.total} votes in total',
                  ),
                  AcceleratorProgressBarSpan(
                    value: votesToAchieveQuorum,
                    color: Colors.yellow,
                    tooltipMessage:
                        '$votesToAchieveQuorum more votes needed to achieve quorum',
                  ),
                  AcceleratorProgressBarSpan(
                    value: pillarsThatCanStillVote,
                    color: Theme.of(context).colorScheme.secondary,
                    tooltipMessage:
                        '$pillarsThatCanStillVote Pillars that can still cast a vote',
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 10.0,
            ),
            Tooltip(
              message: quorum >= quorumNeeded
                  ? 'Quorum achieved'
                  : 'Quorum not achieved',
              child: Icon(
                Icons.check_circle,
                color: quorum >= quorumNeeded
                    ? znnColor
                    : Theme.of(context).colorScheme.secondary,
                size: 15.0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _getOpenLinkIcon(BuildContext context) {
    return IconButton.filled(
      style: IconButton.styleFrom(
        backgroundColor: Colors.white12,
      ),
      tooltip: 'Visit ${widget.acceleratorProject.url}',
      onPressed: () => launchUrl(widget.acceleratorProject.url),
      icon: const Icon(
        Icons.open_in_new,
      ),
    );
  }

  Widget _getVotingResultsIcon(
    BuildContext context,
    List<PillarVote?>? pillarVoteList,
    ProjectVoteBreakdownBloc projectVoteBreakdownViewModel,
  ) {
    return Row(
      children: [
        if (pillarVoteList != null &&
            ((widget.acceleratorProject is Phase &&
                    (widget.acceleratorProject as Phase).status ==
                        AcceleratorProjectStatus.active) ||
                widget.acceleratorProject.status ==
                    AcceleratorProjectStatus.voting))
          _getVoteProjectViewModel(
            context,
            pillarVoteList,
            projectVoteBreakdownViewModel,
          ),
        if ([
          AcceleratorProjectStatus.voting,
          AcceleratorProjectStatus.active,
          AcceleratorProjectStatus.paid,
        ].contains(widget.acceleratorProject.status))
          Row(
            children: [
              const SizedBox(
                width: 10.0,
              ),
              _getOpenLinkIcon(context),
            ],
          ),
        if (widget.acceleratorProject is Phase &&
            widget.acceleratorProject.status ==
                AcceleratorProjectStatus.voting &&
            widget.project!.owner.toString() == kSelectedAddress?.hex)
          Row(
            children: [
              const SizedBox(
                width: 10.0,
              ),
              _getUpdatePhaseIcon(context),
            ],
          ),
      ],
    );
  }

  Widget _getVotingIcons(
    BuildContext context,
    VoteProjectBloc model,
    List<PillarVote?> pillarVoteList,
  ) {
    final bool userVotedNo = _ifOptionVotedByUser(
      pillarVoteList,
      AcceleratorProjectVote.no,
    );
    final bool userVotedYes = _ifOptionVotedByUser(
      pillarVoteList,
      AcceleratorProjectVote.yes,
    );

    final bool userVotedAbstain = _ifOptionVotedByUser(
      pillarVoteList,
      AcceleratorProjectVote.abstain,
    );

    return Row(
      children: [
        Tooltip(
          message: 'No',
          child: IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor:
                  userVotedNo ? context.colorScheme.error : Colors.white12,
              foregroundColor: userVotedNo ? context.colorScheme.surface : null,
            ),
            onPressed: () {
              model.voteProject(
                widget.acceleratorProject.id,
                AcceleratorProjectVote.no,
              );
            },
            icon: const Icon(
              Icons.close_rounded,
            ),
          ),
        ),
        const SizedBox(
          width: 10.0,
        ),
        Tooltip(
          message: 'Yes',
          child: IconButton(
            style: IconButton.styleFrom(
              backgroundColor: userVotedYes ? znnColor : Colors.white12,
              foregroundColor:
                  userVotedYes ? context.colorScheme.surface : null,
            ),
            onPressed: () {
              model.voteProject(
                widget.acceleratorProject.id,
                AcceleratorProjectVote.yes,
              );
            },
            icon: const Icon(
              Icons.check_rounded,
            ),
          ),
        ),
        const SizedBox(
          width: 10.0,
        ),
        Tooltip(
          message: 'Abstain',
          child: IconButton(
            style: IconButton.styleFrom(
              backgroundColor: userVotedAbstain
                  ? Theme.of(context).primaryColorLight
                  : Colors.white12,
              foregroundColor:
                  userVotedAbstain ? context.colorScheme.surface : null,
            ),
            onPressed: () {
              model.voteProject(
                widget.acceleratorProject.id,
                AcceleratorProjectVote.abstain,
              );
            },
            icon: const Icon(
              Icons.stop,
            ),
          ),
        ),
      ],
    );
  }

  Widget _getUpdatePhaseIcon(BuildContext context) {
    return Tooltip(
      message: 'Update phase',
      child: RawMaterialButton(
        constraints: const BoxConstraints(
          minWidth: 50.0,
          minHeight: 50.0,
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: const CircleBorder(),
        onPressed: () {
          showUpdatePhaseStepper(
            context: context,
            phase: widget.acceleratorProject as Phase,
            project: widget.project!,
          );
        },
        child: Container(
          height: 50.0,
          width: 50.0,
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white12,
          ),
          child: const Icon(
            Icons.edit,
            size: 25.0,
            color: znnColor,
          ),
        ),
      ),
    );
  }

  Widget _getVoteProjectViewModel(
    BuildContext context,
    List<PillarVote?> pillarVoteList,
    ProjectVoteBreakdownBloc projectVoteBreakdownViewModel,
  ) {
    return StreamBuilder<AccountBlockTemplate?>(
      stream: _voteProjectBloc.stream,
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          return _getVotingIcons(context, _voteProjectBloc, pillarVoteList);
        }
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return _getVotingIcons(context, _voteProjectBloc, pillarVoteList);
          }
          return const SyriusLoadingWidget();
        }
        return _getVotingIcons(context, _voteProjectBloc, pillarVoteList);
      },
    );
  }

  Widget _getProjectVoteBreakdownViewModel(BuildContext context) {
    return StreamBuilder<Pair<VoteBreakdown, List<PillarVote?>?>?>(
      stream: _projectVoteBreakdownBloc.stream,
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          return SyriusErrorWidget(snapshot.error!);
        }
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return _getVotingRow(
              context,
              snapshot.data!.first,
              snapshot.data!.second,
              _projectVoteBreakdownBloc,
            );
          }
          return const SyriusLoadingWidget();
        }
        return const SyriusLoadingWidget();
      },
    );
  }

  bool _ifOptionVotedByUser(
    List<PillarVote?> pillarVoteList,
    AcceleratorProjectVote vote,
  ) {
    try {
      final PillarVote? pillarVote = pillarVoteList.firstWhere(
        (pillarVote) => pillarVote?.name == widget.pillarInfo!.name,
      );
      return pillarVote!.vote == vote.index;
    } catch (e) {
      return false;
    }
  }
}
