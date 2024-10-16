import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/screens/screens.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class OtpCodeConfirmationScreen extends StatefulWidget {
  final String? secretKey;
  final void Function(String)? onCodeValid;

  const OtpCodeConfirmationScreen({
    this.onCodeValid,
    this.secretKey,
    super.key,
  });

  @override
  State<OtpCodeConfirmationScreen> createState() =>
      _OtpCodeConfirmationScreenState();
}

class _OtpCodeConfirmationScreenState extends State<OtpCodeConfirmationScreen> {
  @override
  Widget build(BuildContext context) {
    void onCodeInvalid() => _sendErrorNotification();

    final void Function(String) onCodeValid = widget.onCodeValid != null
        ? widget.onCodeValid!
        : _saveSecretKeyAndNavigateToNextScreen;

    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.otp,
      child: OtpCodeConfirmation(
        onCodeInvalid: onCodeInvalid,
        onCodeValid: onCodeValid,
        secretKey: widget.secretKey,
      ),
    );
  }

  void _sendErrorNotification() {
    return sendNotificationError(
      AppLocalizations.of(context)!.totpNotificationErrorTitle,
      AppLocalizations.of(context)!.totpError,
    );
  }

  void _saveSecretKeyAndNavigateToNextScreen(String secretKey) {
    final bool wasOtpSecretKeySaved = sharedPrefs.getBool(
      kWasOtpSecretKeyStoredKey,
    ) ?? false;

    if (!wasOtpSecretKeySaved) {
      Future.wait(
        [
          secureStorageUtil.write(
            key: kOtpSecretKey,
            value: secretKey,
          ),
          sharedPrefs.setBool(
            kWasOtpSecretKeyStoredKey,
            true,
          ),
        ],
      ).then((value) => _navigateToNextScreen());
    } else {
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() => showOtpManagementScreen(context: context);
}
