import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:syrius_mobile/utils/utils.dart';

class NumericVirtualKeyboardItem extends StatelessWidget {
  final String text;
  final bool isEnabled;
  final bool isZero;
  final bool isThumb;
  final bool isBack;
  final int index;
  final bool backKeyShouldBeVisible;
  final Function(int) tapped;

  const NumericVirtualKeyboardItem({
    required this.index,
    required this.isEnabled,
    required this.backKeyShouldBeVisible,
    required this.tapped,
    required this.text,
    super.key,
    this.isBack = false,
    this.isThumb = false,
    this.isZero = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isBack && !backKeyShouldBeVisible) {
      return const SizedBox.shrink();
    }

    if (isThumb && kBiometricTypeSupport == null) {
      return const SizedBox.shrink();
    }

    return IconButton(
      onPressed: isEnabled
          ? () {
              HapticFeedback.lightImpact();
              tapped(index);
            }
          : null,
      icon: isBack
          ? _buildBackspaceKey(context)
          : (isThumb ? _buildBiometryKey(context) : _buildNumericKey(context)),
    );
  }

  Text _buildNumericKey(BuildContext context) {
    return Text(
      isZero ? '0' : text,
      style: context.textTheme.headlineLarge?.copyWith(
        color: isEnabled
            ? context.colorScheme.onBackground
            : context.colorScheme.outline,
      ),
    );
  }

  Icon _buildBiometryKey(BuildContext context) {
    return (kBiometricTypeSupport == BiometricType.face)
        ? Icon(
            Icons.face,
            size: 45,
            color: isEnabled
                ? context.colorScheme.onBackground
                : context.colorScheme.outline,
          )
        : Icon(
            Icons.fingerprint,
            size: 45,
            color: isEnabled
                ? context.colorScheme.onBackground
                : context.colorScheme.outline,
          );
  }

  Widget _buildBackspaceKey(BuildContext context) {
    return Visibility(
      visible: backKeyShouldBeVisible,
      child: Icon(
        Icons.backspace_outlined,
        color: context.colorScheme.outline,
        size: 30.0,
      ),
    );
  }
}
