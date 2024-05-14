import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';

class ScanIntoTextFormFieldButton extends Material {
  ScanIntoTextFormFieldButton({
    required BuildContext context,
    required void Function(String) onScan,
    super.key,
  }) : super(
          clipBehavior: Clip.hardEdge,
          shape: const CircleBorder(),
          type: MaterialType.transparency,
          child: InkWell(
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.qr_code_scanner_rounded,
                size: 20.0,
              ),
            ),
            onTap: () async {
              await showSyriusAddressScanner(context: context, onScan: onScan);
            },
          ),
        );
}
