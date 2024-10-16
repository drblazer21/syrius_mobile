import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class NetworkCurrencySymbolTextField extends TextField {
  NetworkCurrencySymbolTextField({
    required BuildContext context,
    required TextEditingController controller,
    required bool enabled,
    required FocusNode focusNode,
    required FocusNode nextFocusNode,
  }) : super(
          controller: controller,
          enabled: enabled,
          focusNode: focusNode,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            errorText: networkAssetSymbolValidator(controller.text),
            hintText: 'Currency Symbol',
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
