import 'package:flutter/material.dart';

class ClearTextFormFieldButton extends Material {
  ClearTextFormFieldButton({
    required VoidCallback onTap,
    super.key,
  }) : super(
          clipBehavior: Clip.hardEdge,
          shape: const CircleBorder(),
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.clear_rounded,
                size: 20.0,
              ),
            ),
          ),
        );
}
