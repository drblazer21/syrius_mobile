import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class NetworkBlockExplorerUrlTextField extends TextField {
  NetworkBlockExplorerUrlTextField({
    required TextEditingController controller,
    required bool enabled,
    required FocusNode focusNode,
    required String hintText,
    required void Function(String?) onSubmitted,
  }) : super(
    controller: controller,
    enabled: enabled,
    focusNode: focusNode,
    textInputAction: TextInputAction.done,
    keyboardType: TextInputType.url,
    decoration: InputDecoration(
      errorText: urlValidator(controller.text),
      hintText: hintText,
      suffixIcon: Visibility(
        visible: controller.text.isNotEmpty,
        child: ClearTextFormFieldButton(
          onTap: () {
            controller.clear();
          },
        ),
      ),
    ),
    onSubmitted: onSubmitted,
  );
}
