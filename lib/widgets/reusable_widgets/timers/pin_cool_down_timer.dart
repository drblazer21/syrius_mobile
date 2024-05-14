import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';

class PinCoolDownTimer extends StatelessWidget {
  final Duration duration;

  const PinCoolDownTimer({required this.duration, super.key});

  @override
  Widget build(BuildContext context) {
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);

    final String minutesString = _twoDigits(number: minutes);
    final String secondsString = _twoDigits(number: seconds);

    return Text(
      '$minutesString:$secondsString',
      style: TextStyle(
        fontSize: 30.0,
        color: context.colorScheme.error,
      ),
    );
  }

  String _twoDigits({
    required int number,
  }) =>
      number.toString().padLeft(2, '0');
}
