import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class OtpManagementScreen extends StatefulWidget {
  const OtpManagementScreen({super.key});

  @override
  State<OtpManagementScreen> createState() => _OtpManagementScreenState();
}

class _OtpManagementScreenState extends State<OtpManagementScreen> {
  late bool _useOtpForTxConfirmation;
  late bool _useOtpForRevealingSeed;
  late bool _useOtpForModifyingBiometryUse;
  late bool _useOtpForDeletingWallet;

  @override
  void initState() {
    super.initState();
    _useOtpForTxConfirmation = sharedPrefsService.get(
      kUseOtpForTxConfirmationKey,
      defaultValue: false,
    )!;
    _useOtpForRevealingSeed = sharedPrefsService.get(
      kUseOtpForRevealingSeedKey,
      defaultValue: false,
    )!;
    _useOtpForModifyingBiometryUse = sharedPrefsService.get<bool>(
      kUseOtpForModifyingBiometryUseKey,
      defaultValue: false,
    )!;
    _useOtpForDeletingWallet = sharedPrefsService.get<bool>(
      kUseOtpForDeletingWalletKey,
      defaultValue: false,
    )!;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        } else {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      },
      child: CustomAppbarScreen(
        appbarTitle: AppLocalizations.of(context)!.otpManagement,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildDescription(),
            _buildUseOtpForTxConfirmationOption(),
            _buildUseOtpForCheckSeedOption(),
            _buildUseOtpForModifyingBiometryUsageOption(),
            _buildUseOtpForDeletingWalletOption(),
          ].addSeparator(kVerticalSpacer),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      AppLocalizations.of(context)!.totpDescription,
    );
  }

  Widget _buildUseOtpForTxConfirmationSwitch() {
    return Switch(
      value: _useOtpForTxConfirmation,
      onChanged: (bool value) {
        sharedPrefsService
            .put(
              kUseOtpForTxConfirmationKey,
              value,
            )
            .then(
              (_) => setState(
                () {
                  _useOtpForTxConfirmation = value;
                },
              ),
            );
      },
    );
  }

  Widget _buildUseOtpForRevealingSeedSwitch() {
    return Switch(
      value: _useOtpForRevealingSeed,
      onChanged: (bool value) {
        sharedPrefsService
            .put(
              kUseOtpForRevealingSeedKey,
              value,
            )
            .then(
              (_) => setState(
                () {
                  _useOtpForRevealingSeed = value;
                },
              ),
            );
      },
    );
  }

  Widget _buildUseOtpForTxConfirmationDescription() {
    return Text(
      AppLocalizations.of(context)!.confirmingTx,
    );
  }

  Widget _buildUseOtpForRevealingSeedDescription() {
    return Text(
      AppLocalizations.of(context)!.revealSeed,
    );
  }

  Widget _buildUseOtpForDeletingWalletDescription() {
    return Text(
      AppLocalizations.of(context)!.deleteWallet,
    );
  }

  Widget _buildUseOtpForTxConfirmationOption() {
    final Widget switchWidget = _buildUseOtpForTxConfirmationSwitch();
    final Widget description = _buildUseOtpForTxConfirmationDescription();

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

  Widget _buildUseOtpForCheckSeedOption() {
    final Widget switchWidget = _buildUseOtpForRevealingSeedSwitch();
    final Widget description = _buildUseOtpForRevealingSeedDescription();

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

  Widget _buildUseOtpForDeletingWalletOption() {
    final Widget switchWidget = _buildUseOtpForDeletingWalletSwitch();
    final Widget description = _buildUseOtpForDeletingWalletDescription();

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

  Widget _buildUseOtpForModifyingBiometryUseSwitch() {
    return Switch(
      value: _useOtpForModifyingBiometryUse,
      onChanged: (bool value) {
        sharedPrefsService
            .put(
              kUseOtpForModifyingBiometryUseKey,
              value,
            )
            .then(
              (_) => setState(
                () {
                  _useOtpForModifyingBiometryUse = value;
                },
              ),
            );
      },
    );
  }

  Widget _buildUseOtpForDeletingWalletSwitch() {
    return Switch(
      value: _useOtpForDeletingWallet,
      onChanged: (bool value) {
        sharedPrefsService
            .put(
              kUseOtpForDeletingWalletKey,
              value,
            )
            .then(
              (_) => setState(
                () {
                  _useOtpForDeletingWallet = value;
                },
              ),
            );
      },
    );
  }

  Widget _buildUseOtpForModifyingBiometryUseDescription() {
    return Text(
      AppLocalizations.of(context)!.modifyBiometrySettings,
    );
  }

  Widget _buildUseOtpForModifyingBiometryUsageOption() {
    final Widget switchWidget = _buildUseOtpForModifyingBiometryUseSwitch();
    final Widget description = _buildUseOtpForModifyingBiometryUseDescription();

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
}
