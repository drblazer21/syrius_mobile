import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class DelegateScreen extends StatelessWidget {
  DelegateScreen({super.key});

  final PillarRewardsHistoryBloc _pillarRewardsHistoryBloc =
      PillarRewardsHistoryBloc();

  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.delegateAction,
      withLateralPadding: false,
      withBottomPadding: false,
      child: Column(
        children: [
          Padding(
            padding: context.listTileTheme.contentPadding!,
            child: PillarReward(
              pillarRewardsHistoryBloc: _pillarRewardsHistoryBloc,
            ),
          ),
          kVerticalSpacer,
          const Expanded(
            child: PillarsListWidget(),
          ),
        ],
      ),
    );
  }
}
