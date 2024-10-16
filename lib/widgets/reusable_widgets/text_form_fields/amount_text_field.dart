import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/utils/utils.dart';

class AmountTextField extends TextField {
  AmountTextField({
    required BuildContext context,
    required FocusNode super.focusNode,
    required TextEditingController super.controller,
    required int maxDecimals,
    required VoidCallback onMaxPressed,
    required TextInputAction textInputAction,
    required String? Function(String) validator,
    required bool requireInteger,
    super.onChanged,
    super.key,
    FocusNode? recipientFocusNode,
  }) : super(
          decoration: InputDecoration(
            errorText:
                controller.text.isEmpty ? null : validator(controller.text),
            hintText: AppLocalizations.of(context)!.amount,
            suffixIcon: TextButton(
              onPressed: onMaxPressed,
              child: Text(
                AppLocalizations.of(context)!.max.toUpperCase(),
              ),
            ),
          ),
          inputFormatters: requireInteger
              ? [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+$')),
                ]
              : generateAmountTextInputFormatters(
                  replacementString: controller.text,
                  maxDecimals: maxDecimals,
                ),
          keyboardType: TextInputType.number,
          onSubmitted: textInputAction == TextInputAction.next
              ? (_) {
                  FocusScope.of(context).requestFocus(recipientFocusNode);
                }
              : null,
          textInputAction: textInputAction,
        );
}
