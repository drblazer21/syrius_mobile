import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class StakingList extends StatefulWidget {
  final StakingListBloc bloc;

  const StakingList(this.bloc, {super.key});

  @override
  State createState() {
    return _StakingListState();
  }
}

class _StakingListState extends State<StakingList> {
  @override
  Widget build(BuildContext context) {
    return PaginatedListView<StakeEntry>(
      bloc: widget.bloc,
      itemBuilder: (_, stakeEntry, __) {
        return StakingListItem(
          stakeEntry: stakeEntry,
          bloc: widget.bloc,
        );
      },
      title: AppLocalizations.of(context)!.stakingListTitle,
    );
  }
}

class StakingListItem extends StatefulWidget {
  final StakeEntry stakeEntry;
  final StakingListBloc bloc;

  const StakingListItem({
    required this.bloc,
    required this.stakeEntry,
    super.key,
  });

  @override
  State<StakingListItem> createState() => _StakingListItemState();
}

class _StakingListItemState extends State<StakingListItem> {
  final List<String> _stakeItemsToBeDeleted = [];
  final CancelStakeBloc _cancelStakeBloc = CancelStakeBloc();


  @override
  void initState() {
    super.initState();
    _cancelStakeBloc.stream.listen(
          (event) {
        if (event != null) {
          widget.bloc.refreshResults();
          setState(() {
            _stakeItemsToBeDeleted.remove(widget.stakeEntry.id.toString());
          });
        }
      },
      onError: (error) {
        setState(() {
          _stakeItemsToBeDeleted.remove(widget.stakeEntry.id.toString());
        });
        if (!mounted) return;
        sendNotificationError(
          AppLocalizations.of(context)!.stakingCancellationError,
          error,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Duration remainingDuration = Duration(
      seconds: (widget.stakeEntry.expirationTimestamp) -
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );

    final isStakeActive = remainingDuration.inSeconds > 0;
    final Duration totalDuration = Duration(
      seconds: widget.stakeEntry.expirationTimestamp -
          widget.stakeEntry.startTimestamp,
    );

    final DateTime stakingStartDateTime =
        timestampToDateTime(widget.stakeEntry.startTimestamp * 1000);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: context.listTileTheme.contentPadding!,
          child: Text(
            formatTxsDateTime(
              stakingStartDateTime,
            ),
            style: context.textTheme.titleSmall,
          ),
        ),
        ListTile(
          leading: _buildStakeIcon(isStakeActive: isStakeActive),
          subtitle: _buildBeneficiary(context, widget.stakeEntry),
          title: _buildStakeAmount(widget.stakeEntry),
          trailing: _buildTrailing(
            stakeEntry: widget.stakeEntry,
            isStakeActive: isStakeActive,
            remainingDuration: remainingDuration,
            totalDuration: totalDuration,
          ),
        ),
      ],
    );
  }

  Widget _buildTrailing({
    required StakeEntry stakeEntry,
    required bool isStakeActive,
    required Duration remainingDuration,
    required Duration totalDuration,
  }) {
    if (isStakeActive) {
      return CancelTimerPercent(
        remainingDuration,
        totalDuration,
        context.colorScheme.error,
        onTimeFinishedCallback: () {
          widget.bloc.refreshResults();
        },
      );
    } else {
      return _getCancelButton(
        _cancelStakeBloc,
        stakeEntry.id.toString(),
      );
    }
  }

  Widget _getCancelButton(
    CancelStakeBloc model,
    String stakeHash,
  ) {
    return _stakeItemsToBeDeleted.contains(stakeHash)
        ? const CircularProgressIndicator(
            color: qsrColor,
          )
        : IconButton(
            color: context.colorScheme.error,
            icon: const Icon(
              Icons.cancel_outlined,
            ),
            onPressed: () {
              model.cancel(stakeHash);
              setState(() {
                _stakeItemsToBeDeleted.add(stakeHash);
              });
            },
          );
  }

  Widget _buildStakeAmount(StakeEntry item) {
    return Text(
      'Staking ${item.amount.toStringWithDecimals(
        kZnnCoin.decimals,
      )} ${kZnnCoin.symbol}',
    );
  }

  Widget _buildBeneficiary(BuildContext context, StakeEntry item) {
    final String prefix = AppLocalizations.of(context)!.beneficiaryAddress;

    final String suffix = item.address.toShortString();

    return RichText(
      text: TextSpan(
        style: context.defaultListTileSubtitleStyle,
        children: [
          TextSpan(
            text: prefix,
          ),
          const TextSpan(
            text: '  ●  ',
            style: TextStyle(
              color: qsrColor,
            ),
          ),
          TextSpan(
            text: suffix,
          ),
        ],
      ),
    );
  }

  Widget _buildStakeIcon({
    required bool isStakeActive,
  }) {
    return CircleAvatar(
      backgroundColor: qsrColor,
      child: SvgPicture.asset(
        getSvgImagePath('staked'),
        colorFilter: ColorFilter.mode(
          context.colorScheme.onSurface,
          BlendMode.srcIn,
        ),
        height: 20.0,
      ),
    );
  }
}
