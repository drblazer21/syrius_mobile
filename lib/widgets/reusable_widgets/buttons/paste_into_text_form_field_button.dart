import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';

class PasteIntoTextFormFieldButton extends Material {
  PasteIntoTextFormFieldButton({
    required void Function(String) afterPasteCallback,
    super.key,
  }) : super(
          clipBehavior: Clip.hardEdge,
          shape: const CircleBorder(),
          type: MaterialType.transparency,
          child: InkWell(
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.content_paste_rounded,
                size: 20.0,
              ),
            ),
            onTap: () {
              pasteToClipboard(
                (value) {
                  afterPasteCallback(value);
                },
              );
            },
          ),
        );
}
