import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';

class PinItem extends StatelessWidget {
  final String? text;
  final bool hidePin;
  final bool isActive;
  final bool isInErrorState;

  const PinItem({
    super.key,
    this.text,
    this.hidePin = true,
    this.isActive = false,
    this.isInErrorState = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeBorderColor = context.colorScheme.primary;
    final Color inactiveBorderColor = context.colorScheme.outline;
    final Color errorBorderColor = context.colorScheme.error;

    final Color borderColor = isInErrorState ? errorBorderColor :
        isActive ? activeBorderColor : inactiveBorderColor;

    return SizedBox.square(
      dimension: 45.0,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7.0),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: CircleAvatar(
          backgroundColor: (text != null && text!.isNotEmpty)
              ? context.colorScheme.onBackground
              : Colors.transparent,
          radius: 5.0,
          child: (text == null)
              ? Container(
                  color: context.colorScheme.primary,
                )
              : Center(
                  child: Text(
                    hidePin ? ' ' : text!,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
