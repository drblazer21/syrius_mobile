import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/constants.dart';

class AcceleratorProgressBarSpan extends StatelessWidget {
  final int value;
  final Color color;
  final String tooltipMessage;

  const AcceleratorProgressBarSpan({
    required this.value,
    required this.color,
    required this.tooltipMessage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: value,
      child: Tooltip(
        message: tooltipMessage,
        child: Container(
          height: kAcceleratorProgressBarSize.height,
          decoration: BoxDecoration(
            color: color,
          ),
        ),
      ),
    );
  }
}

class AcceleratorProgressBar extends StatelessWidget {
  final List<Widget> spans;

  const AcceleratorProgressBar({
    required this.spans,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Row(
        children: spans,
      ),
    );
  }
}
