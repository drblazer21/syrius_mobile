import 'package:flutter/material.dart';

class RefreshButton extends IconButton {
  const RefreshButton({
    required super.onPressed,
    super.key,
  }) : super(
          icon: const Icon(
            Icons.refresh_rounded,
          ),
        );
}
