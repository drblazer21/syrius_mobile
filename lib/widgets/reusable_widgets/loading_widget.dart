import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';

class SyriusLoadingWidget extends StatelessWidget {
  final double size;
  final double strokeWidth;

  const SyriusLoadingWidget({
    this.size = 50.0,
    this.strokeWidth = 4.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Center(
        child: SizedBox.square(
          dimension: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(
              context.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
