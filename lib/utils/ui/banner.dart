import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/utils/utils.dart';

void showMaterialBanner({
  required BuildContext context,
  required String title,
  required IconData icon,
  String? actionButtonText,
  String? actionButtonUrl,
}) {
  ScaffoldMessenger.of(context).showMaterialBanner(
    MaterialBanner(
      content: Text(title),
      leading: Icon(
        icon,
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            actionButtonText ?? AppLocalizations.of(context)!.dismiss,
          ),
          onPressed: () {
            if (actionButtonUrl != null) {
              launchUrl(actionButtonUrl);
            }
            ScaffoldMessenger.of(context).clearMaterialBanners();
          },
        ),
      ],
    ),
  );
}
