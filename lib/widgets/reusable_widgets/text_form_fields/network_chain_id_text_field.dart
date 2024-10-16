import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class NetworkChainIdTextField extends TextField {
  NetworkChainIdTextField({
    required BuildContext context,
    required TextEditingController controller,
    required bool enabled,
    required FocusNode focusNode,
    required FocusNode nextFocusNode,
  }) : super(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.number,
          inputFormatters: onlyIntegersTextInputFormatters(
            replacementString: controller.text,
          ),
          decoration: InputDecoration(
            errorText: chainIdValidator(controller.text),
            hintText: AppLocalizations.of(context)!.chainIdentifier,
            suffixIcon: Visibility(
              visible: controller.text.isNotEmpty,
              child: ClearTextFormFieldButton(
                onTap: () {
                  controller.clear();
                },
              ),
            ),
          ),
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          },
        );
}
