import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/constants.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class NewTokenNameTextField extends TextField {
  NewTokenNameTextField({
    required TextEditingController controller,
    required String? errorText,
    required FocusNode focusNode,
    required void Function(String?) onSubmitted,
  }) : super(
          controller: controller,
          decoration: InputDecoration(
            errorText: errorText,
            hintText: 'Token Name',
            suffixIcon: Visibility(
              visible: controller.text.isNotEmpty,
              child: ClearTextFormFieldButton(
                onTap: () {
                  controller.clear();
                },
              ),
            ),
          ),
          focusNode: focusNode,
          keyboardType: TextInputType.name,
          maxLength: kNetworkAssetNameMaxLength,
          onSubmitted: onSubmitted,
          textInputAction: TextInputAction.next,
        );
}
