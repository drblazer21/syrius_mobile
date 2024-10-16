import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syrius_mobile/utils/utils.dart';

class LockTimeTextField extends StatelessWidget {
  final BuildContext context;
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String?)? onSubmitted;
  final String hintText;

  const LockTimeTextField({
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
          errorText: lockTimeValidator(controller.text),
          hintText: hintText,
        ),
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'^([1-9][0-9]*|0)$')),
        ],
        onSubmitted: onSubmitted,
      ),
    );
  }
}
