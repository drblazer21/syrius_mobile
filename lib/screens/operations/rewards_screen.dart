import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.rewards,
      withBottomPadding: false,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: const <Widget>[
          PageCard(
            type: PageCardType.rewardsStaking,
          ),
          PageCard(
            type: PageCardType.rewardsPillar,
          ),
          PageCard(
            type: PageCardType.rewardsSentinel,
          ),
          PageCard(
            type: PageCardType.rewardsDelegate,
          ),
          PageCard(
            type: PageCardType.acceleratorProjectList,
          ),
          PageCard(
            type: PageCardType.acceleratorCreateProject,
          ),
          PageCard(
            type: PageCardType.acceleratorDonate,
          ),
        ].addSeparator(kVerticalSpacer),
      ),
    );
  }
}
