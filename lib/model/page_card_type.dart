import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/utils/ui/modal_bottom_sheets.dart';
import 'package:syrius_mobile/utils/utils.dart';

enum PageCardType {
  acceleratorCreateProject,
  acceleratorDonate,
  acceleratorProjectList,
  acceleratorStats,
  rewardsDelegate,
  rewardsPillar,
  rewardsSentinel,
  rewardsStaking;

  String description(BuildContext context) {
    switch (this) {
      case acceleratorCreateProject:
        return AppLocalizations.of(context)!.createProjectDescription;
      case acceleratorDonate:
        return AppLocalizations.of(context)!.donateDescription;
      case acceleratorProjectList:
        return AppLocalizations.of(context)!.projectListDescription;
      case acceleratorStats:
        return AppLocalizations.of(context)!.acceleratorStats;
      case rewardsDelegate:
        return AppLocalizations.of(context)!.delegateDescription;
      case rewardsPillar:
        return AppLocalizations.of(context)!.pillarDescription;
      case rewardsSentinel:
        return AppLocalizations.of(context)!.sentinelDescription;
      case rewardsStaking:
        return AppLocalizations.of(context)!.stakingDescription;
    }
  }

  String title(BuildContext context) {
    switch (this) {
      case acceleratorCreateProject:
        return AppLocalizations.of(context)!.createProjectTitle;
      case acceleratorDonate:
        return AppLocalizations.of(context)!.donate;
      case acceleratorProjectList:
        return AppLocalizations.of(context)!.projectsListTitle;
      case acceleratorStats:
        return AppLocalizations.of(context)!.acceleratorStats;
      case rewardsDelegate:
        return AppLocalizations.of(context)!.delegateAction;
      case rewardsPillar:
        return AppLocalizations.of(context)!.pillar;
      case rewardsSentinel:
        return AppLocalizations.of(context)!.sentinel;
      case rewardsStaking:
        return AppLocalizations.of(context)!.staking;
    }
  }

  String get svgPath {
    switch (this) {
      case acceleratorCreateProject:
        return getSvgImagePath('rewards/createproject');
      case acceleratorDonate:
        return getSvgImagePath('rewards/donate');
      case acceleratorProjectList:
        return getSvgImagePath('rewards/projectlist');
      // TODO: to replace
      case acceleratorStats:
        return getSvgImagePath('rewards/projectlist');
      case rewardsDelegate:
        return getSvgImagePath('rewards/delegate');
      case rewardsPillar:
        return getSvgImagePath('rewards/pillar');
      case rewardsSentinel:
        return getSvgImagePath('rewards/sentinel');
      case rewardsStaking:
        return getSvgImagePath('rewards/staking');
    }
  }

  VoidCallback onClick(BuildContext context) {
    switch (this) {
      case acceleratorCreateProject:
        return () {
          showProjectCreationStepper(context);
        };
      case acceleratorDonate:
        return () {
          showAcceleratorDonationStepper(context);
        };
      case acceleratorProjectList:
        return () {
          showAcceleratorProjectListScreen(context);
        };
      case acceleratorStats:
        return () {
          showAcceleratorStatsScreen(context);
        };
      case rewardsPillar:
        return () async {
          showModalBottomSheetWithButtons(
            btn1Text: AppLocalizations.of(context)!.downloadButton,
            btn1Action: () async {
              Navigator.pop(context);
              await launchUrl(kSyriusDesktopGithub);
            },
            context: context,
            subTitle: AppLocalizations.of(context)!.pillarModalDescription,
            title: title(context),
          );
        };
      case rewardsSentinel:
        return () {
          showModalBottomSheetWithButtons(
            btn1Text: AppLocalizations.of(context)!.downloadButton,
            btn1Action: () async {
              Navigator.pop(context);
              await launchUrl(kSyriusDesktopGithub);
            },
            context: context,
            subTitle: AppLocalizations.of(context)!.sentinelModalDescription,
            title: title(context),
          );
        };
      case rewardsDelegate:
        return () {
          showDelegateScreen(context);
        };
      case rewardsStaking:
        return () {
          showStakingScreen(context);
        };
    }
  }

  double get rightMargin {
    switch (this) {
      case acceleratorCreateProject ||
            acceleratorDonate ||
            acceleratorProjectList ||
            acceleratorStats:
        return kDefaultPageCardLateralPadding;
      case rewardsDelegate ||
            rewardsPillar ||
            rewardsSentinel ||
            rewardsStaking:
        return -19.0;
    }
  }

  double get svgWidth {
    switch (this) {
      case acceleratorCreateProject:
        return 57.0;
      case acceleratorDonate:
        return 50.0;
      case acceleratorProjectList:
        return 67.0;
      case acceleratorStats:
        return 67.0;
      case rewardsDelegate ||
            rewardsPillar ||
            rewardsSentinel ||
            rewardsStaking:
        return 100.0;
    }
  }
}
