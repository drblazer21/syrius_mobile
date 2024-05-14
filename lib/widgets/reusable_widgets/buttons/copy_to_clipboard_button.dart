import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';

class CopyToClipboardButton extends IconButton {
  CopyToClipboardButton({
    required String text,
    super.key,
    Color? iconColor,
    VoidCallback? afterCopyCallback,
  }) : super(
          onPressed: () {
            copyToClipboard(afterCopying: afterCopyCallback, data: text);
          },
          icon: Icon(
            Icons.content_copy_rounded,
            color: iconColor,
          ),
        );
}
