import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class PairWithDAppButton extends StatelessWidget {
  const PairWithDAppButton({required this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SyriusFilledButton(
      onPressed: onPressed,
      text: AppLocalizations.of(context)!.walletConnectPair,
    );
  }
}
