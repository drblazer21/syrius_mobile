import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';

Future<void> showNotificationSnackBar(
  BuildContext context, {
  WalletNotification? walletNotification,
  String? content,
  Duration? duration,
}) async {
  final actionOnPressed = walletNotification != null
      ? _actionOnPressed(
          context: context,
          walletNotification: walletNotification,
        )
      : null;

  final actionLabel =
      actionOnPressed != null ? AppLocalizations.of(context)!.show : null;

  final snackBar = SnackBar(
    duration: duration ?? const Duration(seconds: 30),
    action: actionOnPressed != null
        ? SnackBarAction(
            label: actionLabel!,
            onPressed: () => actionOnPressed(),
          )
        : null,
    content: Text(
      walletNotification?.title ?? (content ?? ''),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

VoidCallback? _actionOnPressed({
  required BuildContext context,
  required WalletNotification walletNotification,
}) {
  if (walletNotification.type == NotificationType.stakeSuccess) {
    return () {
      showStakingScreen(context);
    };
  } else if (walletNotification.type == NotificationType.delegateSuccess) {
    return () {
      showDelegateScreen(context);
    };
  } else if (walletNotification.type == NotificationType.plasmaSuccess) {
    return () {
      showPlasmaListScreen(context);
    };
  }

  return null;
}
