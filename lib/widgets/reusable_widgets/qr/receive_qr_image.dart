import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class ReceiveQrImage extends StatelessWidget {
  final String data;
  final double size;
  final Token token;
  final BuildContext context;

  const ReceiveQrImage({
    required this.data,
    required this.size,
    required this.token,
    required this.context,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        15.0,
      ),
      child: Container(
        padding: const EdgeInsets.all(
          10.0,
        ),
        child: Stack(
          children: [
            SizedBox.square(
              dimension: size,
              child: SyriusQrCode(
                color: getTokenColor(token),
                data: data,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
