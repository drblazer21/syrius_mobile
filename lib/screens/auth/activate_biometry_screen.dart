import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logging/logging.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/services/authentication_service.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class ActivateBiometryScreen extends StatefulWidget {
  final bool onboardingFlow;
  final String pin;

  const ActivateBiometryScreen({
    required this.onboardingFlow,
    required this.pin,
    super.key,
  });

  @override
  State<ActivateBiometryScreen> createState() => _ActivateBiometryScreenState();
}

class _ActivateBiometryScreenState extends State<ActivateBiometryScreen> {
  final LocalAuthentication auth = LocalAuthentication();

  late bool _encryptWalletWithBiometry;

  @override
  void initState() {
    super.initState();
    _encryptWalletWithBiometry = _getSavedEncryptWalletWithBiometryValue();
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldShowSecurityInfo = Platform.isIOS || kIsStrongboxSupported;
    final bool savedEncryptWalletWithBiometryValue =
        _getSavedEncryptWalletWithBiometryValue();
    final bool areValuesDifferent =
        savedEncryptWalletWithBiometryValue != _encryptWalletWithBiometry;
    final bool shouldShowContinueButton =
        widget.onboardingFlow || areValuesDifferent;

    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.activateBiometryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (shouldShowSecurityInfo) _buildSecurityInfo(),
          _buildEncryptedWalletWithBiometryOption(),
          const Spacer(),
          if (shouldShowContinueButton) _buildContinueButton(),
        ].addSeparator(kVerticalSpacer),
      ),
    );
  }

  bool _getSavedEncryptWalletWithBiometryValue() {
    return sharedPrefs.getBool(
      kEncryptWalletWithBiometryKey,
    ) ?? true;
  }

  Widget _buildEncryptedWalletWithBiometryOption() {
    final Widget switchWidget = _buildEncryptWalletWithBiometrySwitch();
    final Widget description = _buildEncryptWalletWithBiometryDescription();

    return Row(
      children: [
        switchWidget,
        const SizedBox(
          width: 8.0,
        ),
        description,
      ],
    );
  }

  Widget _buildEncryptWalletWithBiometrySwitch() {
    return Switch(
      value: _encryptWalletWithBiometry,
      onChanged: (bool value) => setState(
        () {
          _encryptWalletWithBiometry = value;
        },
      ),
    );
  }

  Widget _buildEncryptWalletWithBiometryDescription() {
    return Text(
      AppLocalizations.of(context)!.enhancedSecurityCheckbox,
    );
  }

  Widget _buildSecurityDescription({
    required String description,
  }) {
    return Text(
      description,
      style: const TextStyle(
        color: znnColor,
      ),
    );
  }

  Widget _buildSecurityInfo() {
    const String androidSecurityTechnology = 'StrongBox Keymaster';
    const String iPhoneSecurityTechnology = 'Secure Enclave';
    final String securityTechnology = Platform.isAndroid
        ? androidSecurityTechnology
        : iPhoneSecurityTechnology;
    final String description = AppLocalizations.of(context)!
        .enhancedSecurityDescription(securityTechnology);

    final Widget label = _buildSecurityDescription(
      description: description,
    );

    return Row(
      children: [
        const Icon(Icons.security),
        const SizedBox(
          width: 15.0,
        ),
        Expanded(child: label),
      ],
    );
  }

  Widget _buildContinueButton() {
    return SyriusFilledButton(
      text: AppLocalizations.of(context)!.continueButton,
      onPressed: () async {
        if (_encryptWalletWithBiometry) {
          final bool canAuthenticate = await auth.isDeviceSupported();
          if (canAuthenticate) {
            if (await _userAuthenticated(
              options: const AuthenticationOptions(
                biometricOnly: true,
              ),
            )) {
              if (!mounted) return;
              showLoadingDialog(context);
              final AuthenticationService authenticationService =
                  AuthenticationService();
              await authenticationService.encryptPinWithBiometry(widget.pin);
              await _saveEncryptWalletWithBiometryValue();
              _navigate();
            } else {
              setState(() {
                _encryptWalletWithBiometry = false;
              });
            }
          } else {
            showDialogAsBottomSheet();
            setState(() {
              _encryptWalletWithBiometry = false;
            });
          }
        } else {
          showLoadingDialog(context);
          await _saveEncryptWalletWithBiometryValue();
          _navigate();
        }
      },
    );
  }

  Future<dynamic> _navigateToNextScreen() => showBackupWalletScreen(
        context,
        isOnboardingFlow: true,
        routePredicate: (_) => false,
      );

  Future<void> _saveEncryptWalletWithBiometryValue() {
    return sharedPrefs.setBool(
      kEncryptWalletWithBiometryKey,
      _encryptWalletWithBiometry,
    );
  }

  Future<bool> _userAuthenticated({
    AuthenticationOptions options = const AuthenticationOptions(),
  }) async {
    bool didAuthenticate = false;
    try {
      didAuthenticate = await auth.authenticate(
        localizedReason: AppLocalizations.of(context)!.authenticationRequired,
        options: options,
      );
    } on PlatformException catch (e, stackTrace) {
      Logger('ActivateBiometryPage')
          .log(Level.SEVERE, '_userAuthenticated', e, stackTrace);
      if (mounted) {
        sendNotificationError(
          AppLocalizations.of(context)!.authenticationFailed,
          e,
        );
      }
    }
    return didAuthenticate;
  }

  Future<dynamic> showDialogAsBottomSheet() {
    return showModalBottomSheetWithButtons(
      context: context,
      title: AppLocalizations.of(context)!.activateBiometryTitle,
      subTitle: AppLocalizations.of(context)!.activateBiometrySubtitle,
      btn1Text: AppLocalizations.of(context)!.continueButton,
      btn1Action: () {
        Navigator.pop(context);
        AppSettings.openAppSettings(
          type: AppSettingsType.security,
        );
      },
    );
  }

  void _navigate() {
    if (widget.onboardingFlow) {
      _navigateToNextScreen();
    } else {
      Navigator.popUntil(context, (route) {
        return route.isFirst;
      });
    }
  }
}
