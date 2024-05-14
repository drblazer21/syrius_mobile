import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';

class WarningWidget extends StatelessWidget {
  final Color fillColor;
  final Color textColor;
  final String text;
  final IconData iconData;

  const WarningWidget({
    super.key,
    required this.fillColor,
    required this.textColor,
    required this.text,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: fillColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 15.0,
        ),
        child: Row(
          children: [
            Icon(
              iconData,
              size: 21.0,
              color: textColor,
            ),
            const SizedBox(
              width: 10.0,
            ),
            Expanded(
              child: Text(
                text,
                style: context.textTheme.labelSmall?.copyWith(
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
