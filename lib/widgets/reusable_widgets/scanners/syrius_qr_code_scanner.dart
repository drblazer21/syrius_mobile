import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';

class SyriusQrCodeScanner extends AiBarcodeScanner {
  SyriusQrCodeScanner({
    required BuildContext context,
    required void Function(String) onScan,
    required bool Function(BarcodeCapture) super.validator,
    super.key,
  }) : super(
          controller: MobileScannerController(
            detectionTimeoutMs: 1000,
          ),
          bottomSheetBuilder: (_, __) => const SizedBox.shrink(),
          onDetect: (value) {
            Navigator.pop(context);
            for (final barcode in value.barcodes) {
              final String? displayValue = barcode.displayValue;
              if (displayValue != null) {
                onScan(displayValue);
                break;
              }
            }
          },
        );
}
