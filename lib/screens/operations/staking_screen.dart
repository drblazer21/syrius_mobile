import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class StakingScreen extends StatefulWidget {
  const StakingScreen({super.key});

  @override
  State<StakingScreen> createState() => _StakingScreenState();
}

class _StakingScreenState extends State<StakingScreen> {
  final StakingListBloc _stakingListBloc = StakingListBloc();

  @override
  void initState() {
    super.initState();
    _stakingListBloc.getData(1, 10);
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.staking,
      withLateralPadding: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: context.listTileTheme.contentPadding!,
            child: const StakeReward(),
          ),
          kVerticalSpacer,
          Expanded(
            child: StakingList(_stakingListBloc),
          ),
          Padding(
            padding: context.listTileTheme.contentPadding!,
            child: SyriusFilledButton(
              text: AppLocalizations.of(context)!.stake,
              onPressed: () {
                showAddStakingScreen(context, _stakingListBloc);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stakingListBloc.dispose();
    super.dispose();
  }
}
