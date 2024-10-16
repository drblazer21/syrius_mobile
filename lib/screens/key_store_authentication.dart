import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/services/services.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/utils/wallet/wallet_file.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class KeyStoreAuthentication extends StatefulWidget {
  final bool initializeApp;
  final void Function(String) onSuccess;

  const KeyStoreAuthentication({
    required this.onSuccess,
    super.key,
    this.initializeApp = false,
  });

  @override
  State<KeyStoreAuthentication> createState() => _KeyStoreAuthenticationState();
}

class _KeyStoreAuthenticationState extends State<KeyStoreAuthentication>
    with TickerProviderStateMixin {
  final GlobalKey<NumericVirtualKeyboardState> _numberGridKey =
      GlobalKey<NumericVirtualKeyboardState>();

  bool _shouldShowBiometryKey = false;
  bool _showLoading = true;

  @override
  void initState() {
    super.initState();
    _checkForKeyStoreFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: _showLoading
            ? const SyriusLoadingWidget()
            : _buildEnterPinCode(context),
      ),
    );
  }

  Column _buildEnterPinCode(BuildContext context) {
    final PinExponentialBackoffService pinExponentialBackoffService =
        sl.get<PinExponentialBackoffService>();

    pinExponentialBackoffService.whenTimerStateToggles = () {
      setState(() {});
    };

    final int failedAttempts = pinExponentialBackoffService.attemptsCounter;
    final int maxAttempts = pinExponentialBackoffService.maxAttempts;
    final int remainingAttempts = maxAttempts - failedAttempts;

    return Column(
      children: [
        kVerticalSpacer,
        Text(
          AppLocalizations.of(context)!.enterYourPin,
          style: context.textTheme.titleLarge,
        ),
        kVerticalSpacer,
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 32.0,
          ),
          child: Text(
            'You have $remainingAttempts attempts left out of $maxAttempts '
            'before your wallet is deleted',
            textAlign: TextAlign.center,
          ),
        ),
        kVerticalSpacer,
        if (pinExponentialBackoffService.isTimerActive())
          ValueListenableBuilder<int>(
            valueListenable:
                pinExponentialBackoffService.countDownDurationNotifier,
            builder: (context, durationInSeconds, child) {
              final Duration duration = Duration(seconds: durationInSeconds);

              return PinCoolDownTimer(duration: duration);
            },
          ),
        const Spacer(),
        NumericVirtualKeyboard(
          isEnabled: !pinExponentialBackoffService.shouldDisablePinLogging,
          key: _numberGridKey,
          showThumb: _shouldShowBiometryKey,
          thumbTapped: () {
            _triggerBiometricAuthentication();
          },
          onFillPinBoxes: (bool isValid, String pin) async {
            try {
              showLoadingDialog(context);

              final AuthenticationService authenticationService =
                  AuthenticationService();

              final String password =
                  await authenticationService.decryptPassword(
                pin: pin,
              );

              final String keyStorePath = KeyStoreManager(
                walletPath: (await getZnnDefaultWalletDirectory()).absolute,
              ).walletPath.listSync().first.path;

              final WalletFile walletFile = await WalletFile.decrypt(
                File(
                  keyStorePath,
                ).path,
                password,
              );

              final Wallet wallet = await walletFile.open();
              // Set kKeyStore in secureStorageUtil
              await secureStorageUtil.write(
                key: kKeyStoreKey,
                value: (wallet as KeyStore).entropy,
              );

              if (widget.initializeApp) {
                await _initializeApp();
              }
              await pinExponentialBackoffService.resetCounter();
              _popLoadingDialog();
              widget.onSuccess(pin);
            } on IncorrectPasswordException catch (e, stackTrace) {
              Logger('KeyStoreAuthentication')
                  .log(Level.WARNING, 'onFillPinBoxes', e, stackTrace);
              pinExponentialBackoffService.increaseCounter();
              setState(() {});
              _popLoadingDialog();
              if (_numberGridKey.currentState != null) {
                _numberGridKey.currentState!.triggerErrorState();
              }
            } catch (e, stackTrace) {
              Logger('KeyStoreAuthentication')
                  .log(Level.SEVERE, 'onFillPinBoxes', e, stackTrace);
              _popLoadingDialog();
              sendNotificationError(
                e.toString(),
                e,
              );
            } finally {
              Logger('KeyStoreAuthentication')
                  .log(Level.SHOUT, 'onFillPinBoxes', 'finally block');
            }
          },
        ),
      ],
    );
  }

  Future<void> _checkForKeyStoreFiles() async {
    final KeyStoreManager keyStoreWalletManager = KeyStoreManager(
      walletPath: (await getZnnDefaultWalletDirectory()).absolute,
    );

    if (keyStoreWalletManager.walletPath.listSync().isEmpty) {
      if (!mounted) return;
      showAccessWalletScreen(context, isReplace: true);
    } else {
      final bool isWalletEncryptedWithBiometry = sharedPrefs.getBool(
        kEncryptWalletWithBiometryKey,
      ) ?? false;

      final AuthenticationService authenticationService =
          AuthenticationService();

      final bool hasBiometryEnrolled =
          (await authenticationService.getAvailableBiometry()).isNotEmpty;
      _shouldShowBiometryKey =
          isWalletEncryptedWithBiometry && hasBiometryEnrolled;
      final PinExponentialBackoffService pinExponentialBackoffService =
          sl.get<PinExponentialBackoffService>();
      pinExponentialBackoffService.checkForSavedCountDownDuration();
      setState(() {
        _showLoading = false;
      });
      if (isWalletEncryptedWithBiometry) {
        _triggerBiometricAuthentication();
      }
    }
  }

  Future<void> _triggerBiometricAuthentication() async {
    showLoadingDialog(context);
    void onCantAuthenticate() {
      _popLoadingDialog();
    }

    final AuthenticationService authenticationService = AuthenticationService();

    return authenticationService.triggerBiometricAuthentication(
      keyStoreFile: File(
        KeyStoreManager(
          walletPath: (await getZnnDefaultWalletDirectory()).absolute,
        ).walletPath.listSync().first.path,
      ),
      onCantAuthenticate: onCantAuthenticate,
      onSuccess: (pin) async {
        if (widget.initializeApp) {
          await _initializeApp();
        }
        _popLoadingDialog();
        widget.onSuccess(pin);
      },
    );
  }

  void _popLoadingDialog() {
    if (!context.mounted) return;
    Navigator.pop(context);
  }

  Future<void> _initializeApp() async {
    await initWalletAfterDecrypt();
  }
}
