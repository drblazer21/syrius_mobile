import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NoRewardsToCollect extends StatelessWidget {
  const NoRewardsToCollect({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox.square(
          dimension: 32.0,
          child: Icon(Icons.do_not_disturb),
        ),
        Text(
          AppLocalizations.of(context)!.noRewardsToCollect,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
