import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';

class SyriusQrCodeScanner extends AiBarcodeScanner {
  SyriusQrCodeScanner({
    required BuildContext context,
    required void Function(String) onScan,
    required bool Function(String) super.validator,
    super.key,
  }) : super(
          canPop: false,
          controller: MobileScannerController(
            detectionTimeoutMs: 1000,
          ),
          onScan: (value) {
            Navigator.pop(context);
            onScan(value);
          },
        );
}
