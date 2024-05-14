import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class CreatePincodeScreen extends StatefulWidget {
  @override
  State<CreatePincodeScreen> createState() => _CreatePincodeScreenState();
}

class _CreatePincodeScreenState extends State<CreatePincodeScreen> {
  final GlobalKey<NumericVirtualKeyboardState> formOneKey =
      GlobalKey<NumericVirtualKeyboardState>();

  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.setPinTitle,
      withBottomPadding: false,
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.setPinDescription,
            style: context.textTheme.titleMedium,
          ),
          const Spacer(),
          WarningWidget(
            iconData: Icons.info,
            fillColor: context.colorScheme.primaryContainer,
            textColor: context.colorScheme.onPrimaryContainer,
            text: AppLocalizations.of(context)!.setPinInfo,
          ),
          const Spacer(),
          NumericVirtualKeyboard(
            key: formOneKey,
            onFillPinBoxes: (bool isValid, String pin) async {
              await showConfirmPincodeScreen(
                context: context,
                pin: pin,
              );
              if (formOneKey.currentState != null) {
                formOneKey.currentState!.clearPin();
              }
            },
          ),
        ],
      ),
    );
  }
}
