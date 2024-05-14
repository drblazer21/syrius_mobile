import 'package:flutter/material.dart';

class EditButton extends IconButton {
  const EditButton({
    super.key,
    super.onPressed,
  }) : super(
          icon: const Icon(
            Icons.edit,
          ),
        );
}
