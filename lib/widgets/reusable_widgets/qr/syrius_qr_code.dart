import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class SyriusQrCode extends StatelessWidget {
  final String data;
  final Color color;

  const SyriusQrCode({
    required this.color,
    required this.data,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PrettyQrView.data(
      data: data,
      decoration: PrettyQrDecoration(
        shape: PrettyQrSmoothSymbol(
          color: color,
        ),
      ),
    );
  }
}
