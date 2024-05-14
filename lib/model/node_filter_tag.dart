import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum NodeFilterTag {
  secured,
  community;

  String localizedTitle(BuildContext context) {
    switch (this) {
      case secured:
        return AppLocalizations.of(context)!.secured;
      case community:
        return AppLocalizations.of(context)!.community;
    }
  }
}
