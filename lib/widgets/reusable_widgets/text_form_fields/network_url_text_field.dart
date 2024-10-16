import 'package:flutter/material.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class NetworkUrlTextField extends TextField {
  NetworkUrlTextField({
    required BlockChain blockChain,
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
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            errorText: blockChain.networkUrlValidator(controller.text),
            hintText: blockChain.networkUrlHintText,
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
