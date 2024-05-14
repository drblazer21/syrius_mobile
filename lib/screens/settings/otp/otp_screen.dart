import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/screens/screens.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final OTPService _otpService = sl.get<OTPService>();

  final TextEditingController _secretKeyController = TextEditingController();
  final TextEditingController _uriController = TextEditingController();

  String get _secretKey => _secretKeyController.text.trim();
  String get _uri => _uriController.text.trim();

  @override
  void initState() {
    super.initState();
    _secretKeyController.text = _otpService.generateSecretKey();
    _uriController.text = _otpService.generateGoogleAuthenticatorUri(
      secretKey: _secretKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.otp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildQrCode(
            data: _uri,
          ),
          ...[
            _buildSecretKeyFieldDescription(),
            _buildSecretKeyField(context),
            _buildUriFieldDescription(),
            _buildUriField(context),
            _buildContinueButton(),
          ].addSeparator(kVerticalSpacer),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _secretKeyController.dispose();
    _uriController.dispose();
    super.dispose();
  }

  Widget _buildQrCode({required String data}) {
    return Flexible(
      child: Center(
        child: SyriusQrCode(
          color: context.colorScheme.primary,
          data: data,
        ),
      ),
    );
  }

  Widget _buildSecretKeyField(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextField(
          controller: _secretKeyController,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.only(
              left: 10.0,
              right: 35.0,
            ),
          ),
          enabled: false,
          style: TextStyle(
            color: context.colorScheme.onBackground,
          ),
        ),
        CopyToClipboardButton(
          text: _secretKey,
        ),
      ],
    );
  }

  Text _buildSecretKeyFieldDescription() {
    return Text(
      AppLocalizations.of(context)!.totpSecretKey,
      style: TextStyle(
        color: context.colorScheme.primary,
      ),
    );
  }

  Widget _buildUriField(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextField(
          controller: _uriController,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.only(
              left: 10.0,
              right: 45.0,
            ),
          ),
          enabled: false,
          style: TextStyle(
            color: context.colorScheme.onBackground,
          ),
        ),
        CopyToClipboardButton(
          text: _uri,
        ),
      ],
    );
  }

  Text _buildUriFieldDescription() {
    return Text(
      AppLocalizations.of(context)!.totpUri,
      style: TextStyle(
        color: context.colorScheme.primary,
      ),
    );
  }

  Widget _buildContinueButton() {
    return SyriusFilledButton(
      text: AppLocalizations.of(context)!.continueButton,
      onPressed: () {
        showOtpCodeConfirmationScreen(
          context: context,
          secretKey: _secretKey,
        );
      },
    );
  }
}
