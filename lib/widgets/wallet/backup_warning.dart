import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';

class BackupWarning extends StatelessWidget {
  String title(BuildContext context) {
    return AppLocalizations.of(context)!.backupWarningTitle;
  }

  String setDescription(BuildContext context) {
    return AppLocalizations.of(context)!.backupWarningDescription;
  }

  Future<void> _backupAction(BuildContext context) async {
    showKeyStoreAuthentication(
      context: context,
      onSuccess: (_) {
        Navigator.pop(context);
        final bool shouldCheckForOtp = sharedPrefsService.get(
          kUseOtpForRevealingSeedKey,
          defaultValue: false,
        )!;
        if (shouldCheckForOtp) {
          showOtpCodeConfirmationScreen(
            context: context,
            onCodeValid: (_) {
              Navigator.pop(context);
              showBackupWalletScreen(
                context,
              );
            },
          );
        } else {
          showBackupWalletScreen(
            context,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color background = context.colorScheme.errorContainer;
    final Color foreground = context.colorScheme.onErrorContainer;

    return GestureDetector(
      onTap: () {
        _backupAction(context);
      },
      child: Card(
        color: background,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20.0,
            horizontal: 27.0,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: foreground,
                  ),
                  kIconAndTextHorizontalSpacer,
                  Text(
                    title(context),
                    style: context.textTheme.titleMedium?.copyWith(
                      color: foreground,
                    ),
                  ),
                ],
              ),
              kVerticalSpacer,
              Text(
                setDescription(context),
                maxLines: 3,
                style: TextStyle(
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
