import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

Future<T?> showDialogWithNoAndYesOptions<T>({
  required BuildContext context,
  required String title,
  required VoidCallback onYesButtonPressed,
  bool isBarrierDismissible = false,
  VoidCallback? onNoButtonPressed,
  Widget? content,
  String? description,
}) =>
    showDialog<T>(
      barrierDismissible: isBarrierDismissible,
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: content ?? Text(description!),
        ),
        actions: [
          TextButton(
            onPressed: () {
              onNoButtonPressed?.call();
              Navigator.pop(context, false);
            },
            child: Text(
              AppLocalizations.of(context)!.no,
            ),
          ),
          TextButton(
            onPressed: () {
              onYesButtonPressed.call();
              Navigator.pop(context, true);
            },
            child: Text(
              AppLocalizations.of(context)!.yes,
            ),
          ),
        ],
      ),
    );

void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PopScope(
      canPop: false,
      child: SyriusLoadingWidget(),
    ),
  );
}

void clearLoadingDialog(BuildContext context) {
  Navigator.pop(context);
}
