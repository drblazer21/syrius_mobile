import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

/// Text field used for specifying the address on which to receive the change
/// from an Bitcoin transaction

class ChangeAddressTextField extends StatelessWidget {
  final BuildContext context;
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String?)? onSubmitted;
  final String hintText;

  const ChangeAddressTextField({
    required this.controller,
    required this.context,
    required this.focusNode,
    required this.onSubmitted,
    required this.hintText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (_, __, ___) => TextField(
        controller: controller,
        decoration: InputDecoration(
          errorText: controller.text.isEmpty ? null : checkAddress(controller.text),
          suffixIcon: _SuffixIcons(
            context: context,
            changeAddressController: controller,
          ),
          hintText: hintText,
        ),
        focusNode: focusNode,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.next,
      ),
    );
  }
}

class _SuffixIcons extends Row {
  _SuffixIcons({
    required BuildContext context,
    required TextEditingController changeAddressController,
  }) : super(
    mainAxisSize: MainAxisSize.min,
    children: [
      Visibility(
        visible: changeAddressController.text.isNotEmpty,
        child: ClearTextFormFieldButton(
          onTap: () {
            changeAddressController.clear();
          },
        ),
      ),
      Visibility(
        visible: changeAddressController.text.isEmpty,
        child: PasteIntoTextFormFieldButton(
          afterPasteCallback: (String value) =>
          changeAddressController.text = value,
        ),
      ),
      ScanIntoTextFormFieldButton(
        context: context,
        onScan: (String value) => changeAddressController.text = value,
      ),
    ],
  );
}
