import 'package:flutter/material.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

const List<String> _firstRowCharacters = [
  'q',
  'w',
  'e',
  'r',
  't',
  'y',
  'u',
  'i',
  'o',
  'p',
];

const List<String> _secondRowCharacters = [
  'a',
  's',
  'd',
  'f',
  'g',
  'h',
  'j',
  'k',
  'l',
];

const List<String> _thirdRowCharacters = [
  'z',
  'x',
  'c',
  'v',
  'b',
  'n',
  'm',
];

class AlphaVirtualKeyboard extends StatelessWidget {
  final TextEditingController controller;
  final List<String> disabledCharacters;

  const AlphaVirtualKeyboard({
    required this.controller,
    required this.disabledCharacters,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Widget firstRow = _buildRow(characters: _firstRowCharacters);
    final Widget secondRow = _buildRow(characters: _secondRowCharacters);
    final Widget thirdRow = _buildRow(
      characters: _thirdRowCharacters,
      isThirdLine: true,
    );

    return Column(
      children: [
        firstRow,
        secondRow,
        thirdRow,
      ],
    );
  }

  Widget _buildRow({
    required List<String> characters,
    bool isThirdLine = false,
  }) {
    final int length = isThirdLine ? characters.length + 1 : characters.length;

    final List<AlphaVirtualKeyboardItem> items = List.generate(
      length,
      (index) {
        final bool isBackspace = isThirdLine && index == length - 1;
        final String? content = isBackspace ? null : characters[index];
        final AlphaVirtualKeyboardItemType type = isBackspace
            ? AlphaVirtualKeyboardItemType.backspace
            : AlphaVirtualKeyboardItemType.alpha;
        final bool isEnabled = !disabledCharacters.contains(content ?? '');

        return AlphaVirtualKeyboardItem(
          controller: controller,
          content: content,
          isEnabled: isEnabled,
          type: type,
        );
      },
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items,
    );
  }
}
