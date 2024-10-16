import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/constants.dart';
import 'package:syrius_mobile/utils/extensions/list_separator.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class AcceleratorZScreen extends StatefulWidget {
  const AcceleratorZScreen({super.key});

  @override
  State<AcceleratorZScreen> createState() => _AcceleratorZScreenState();
}

class _AcceleratorZScreenState extends State<AcceleratorZScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.az,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: <Widget>[
            const PageCard(
              type: PageCardType.acceleratorProjectList,
            ),
            const PageCard(
              type: PageCardType.acceleratorCreateProject,
            ),
            const PageCard(
              type: PageCardType.acceleratorDonate,
            ),
            const PageCard(
              type: PageCardType.acceleratorStats,
            ),
          ].addSeparator(kVerticalSpacer),
        ),
      ),
    );
  }
}
