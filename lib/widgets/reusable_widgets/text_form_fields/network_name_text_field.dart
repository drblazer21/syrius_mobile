import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class NetworkNameTextField extends TextField {
  NetworkNameTextField({
    required BuildContext context,
    required TextEditingController controller,
    required bool enabled,
    required FocusNode focusNode,
    required FocusNode nextFocusNode,
    required String? errorText,
  }) : super(
          controller: controller,
          enabled: enabled,
          focusNode: focusNode,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            errorText: errorText,
            hintText: AppLocalizations.of(context)!.name,
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
