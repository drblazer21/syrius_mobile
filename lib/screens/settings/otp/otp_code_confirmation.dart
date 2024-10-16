import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/screens/screens.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class OtpCodeConfirmation extends StatefulWidget {
  final VoidCallback onCodeInvalid;
  final void Function(String) onCodeValid;
  final String? secretKey;

  const OtpCodeConfirmation({
    required this.onCodeInvalid,
    required this.onCodeValid,
    super.key,
    this.secretKey,
  });

  @override
  State<OtpCodeConfirmation> createState() => _OtpCodeConfirmationState();
}

class _OtpCodeConfirmationState extends State<OtpCodeConfirmation> {
  final OTPService _otpService = sl.get<OTPService>();

  final TextEditingController _codeController = TextEditingController();

  String get _code => _codeController.text.trim();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        kVerticalSpacer,
        _buildCodeInputField(),
        kVerticalSpacer,
      ],
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Widget _buildCodeInputField() {
    return TextField(
      controller: _codeController,
      decoration: InputDecoration(
        errorText: _minimumLengthValidator(_code),
        hintText: AppLocalizations.of(context)!.code,
        suffixIcon: _buildSuffixIcon(),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(r'^\d{0,6}$'),
          replacementString: _codeController.text,
        ),
      ],
      keyboardType: TextInputType.number,
      onChanged: (String value) {
        setState(() {});
        if (value.length == 6) {
          _onCheckCodeButtonPressed(value)?.call();
        }
      },
    );
  }

  String? _minimumLengthValidator(String? value) {
    return fixedLength(
      invalidErrorText: AppLocalizations.of(context)!.optCodeRequirement,
      fixedLength: 6,
      value: value,
      nullErrorText: AppLocalizations.of(context)!.optCodeValidation,
    );
  }

  VoidCallback? _onCheckCodeButtonPressed(String? code) {
    final String? validatorResult = _minimumLengthValidator(code);

    final VoidCallback? onPressed = validatorResult == null && _code.isNotEmpty
        ? () {
            _getSecretKeyAndValidateCode(
              userCode: code!,
            );
          }
        : null;

    return onPressed;
  }

  Future<void> _getSecretKeyAndValidateCode({
    required String userCode,
  }) async {
    final String secretKey =
        widget.secretKey ?? await secureStorageUtil.read(kOtpSecretKey);

    _validateCodeAndExecuteCallback(userCode, secretKey);
  }

  void _validateCodeAndExecuteCallback(String userCode, String secretKey) {
    final bool isValid = _otpService.validateCode(
      userCode: userCode,
      secretKey: secretKey,
    );

    if (isValid) {
      widget.onCodeValid(secretKey);
    } else {
      widget.onCodeInvalid();
    }
  }

  Widget _buildSuffixIcon() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: _code.isNotEmpty,
          child: ClearTextFormFieldButton(
            onTap: () {
              setState(() {
                _codeController.clear();
              });
            },
          ),
        ),
        Visibility(
          visible: _code.isEmpty,
          child: PasteIntoTextFormFieldButton(
            afterPasteCallback: (String value) {
              setState(() {
                _codeController.text = value;
              });
            },
          ),
        ),
      ],
    );
  }
}
