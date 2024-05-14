import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class RecipientAddressTextField extends StatelessWidget {
  final BuildContext context;
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String?)? onSubmitted;
  final String hintText;

  const RecipientAddressTextField({
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
          errorText:
              controller.text.isEmpty ? null : checkAddress(controller.text),
          suffixIcon: _SuffixIcons(
            context: context,
            recipientController: controller,
          ),
          hintText: hintText,
        ),
        focusNode: focusNode,
        onSubmitted: onSubmitted,
      ),
    );
  }
}

class _SuffixIcons extends Row {
  _SuffixIcons({
    required BuildContext context,
    required TextEditingController recipientController,
  }) : super(
          mainAxisSize: MainAxisSize.min,
          children: [
            Visibility(
              visible: recipientController.text.isNotEmpty,
              child: ClearTextFormFieldButton(
                onTap: () {
                  recipientController.clear();
                },
              ),
            ),
            Visibility(
              visible: recipientController.text.isEmpty,
              child: PasteIntoTextFormFieldButton(
                afterPasteCallback: (String value) =>
                    recipientController.text = value,
              ),
            ),
            ScanIntoTextFormFieldButton(
              context: context,
              onScan: (String value) => recipientController.text = value,
            ),
          ],
        );
}
