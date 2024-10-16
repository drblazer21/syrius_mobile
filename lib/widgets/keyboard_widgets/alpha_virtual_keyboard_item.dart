import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';

enum AlphaVirtualKeyboardItemType {
  alpha,
  backspace,
}

class AlphaVirtualKeyboardItem extends StatelessWidget {
  final String? content;
  final TextEditingController controller;
  final bool isEnabled;
  final AlphaVirtualKeyboardItemType type;

  const AlphaVirtualKeyboardItem({
    required this.controller,
    required this.isEnabled,
    required this.type,
    super.key,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    final Widget child =
        content != null ? _buildText(context) : _buildBackSpaceIcon(context);
    final double height = MediaQuery.of(context).size.height * 0.1;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(7.0),
        onTap: isEnabled ? _onTap : null,
        child: SizedBox(
          height: height,
          child: Center(
            child: child,
          ),
        ),
      ),
    );
  }

  Icon _buildBackSpaceIcon(BuildContext context) {
    return Icon(
      Icons.backspace_outlined,
      color: context.colorScheme.onSurface,
    );
  }

  Text _buildText(BuildContext context) {
    final Color color = isEnabled
        ? context.colorScheme.onSurface
        : context.colorScheme.outline;
    return Text(
      content!,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: color,
        fontSize: 25.0,
      ),
    );
  }

  void _onTap() {
    void addText() {
      controller.text += content!;
    }

    void deleteText() {
      final int length = controller.text.length;
      final int? end = length >= 1 ? length - 1 : null;
      controller.text = controller.text.substring(0, end);
    }

    switch (type) {
      case AlphaVirtualKeyboardItemType.alpha:
        addText();
      case AlphaVirtualKeyboardItemType.backspace:
        deleteText();
    }
  }
}
