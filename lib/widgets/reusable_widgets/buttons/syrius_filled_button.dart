import 'package:flutter/material.dart';

class SyriusFilledButton extends FilledButton {
  SyriusFilledButton({
    required String text,
    required super.onPressed,
    super.key,
  }) : super(
          child: Text(
            text,
          ),
        );

  SyriusFilledButton.color({
    required Color color,
    required String text,
    required super.onPressed,
    super.key,
  }) : super(
          child: Text(
            text,
          ),
          style: FilledButton.styleFrom(
            backgroundColor: color,
          ),
        );
}
