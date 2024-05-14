import 'dart:async';

import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';

class CancelTimerPercent extends StatefulWidget {
  final Duration timerDuration;
  final Duration totalDuration;
  final Color borderColor;
  final VoidCallback onTimeFinishedCallback;

  const CancelTimerPercent(
    this.timerDuration,
    this.totalDuration,
    this.borderColor, {
    required this.onTimeFinishedCallback,
    super.key,
  });

  @override
  State<CancelTimerPercent> createState() => _CancelTimerPercentState();
}

class _CancelTimerPercentState extends State<CancelTimerPercent> {
  late Duration _currentDuration;
  late Timer _countDownTimer;

  @override
  void initState() {
    super.initState();
    _currentDuration = widget.timerDuration;
    _countDownTimer = Timer.periodic(
      const Duration(
        seconds: 1,
      ),
      (v) {
        if (mounted && _currentDuration > Duration.zero) {
          setState(() {
            _currentDuration = _currentDuration -
                const Duration(
                  seconds: 1,
                );
          });
        } else if (mounted) {
          widget.onTimeFinishedCallback();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 48,
          width: 48,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: differenceInPercentage(),
            backgroundColor: context.colorScheme.outline,
            valueColor: const AlwaysStoppedAnimation<Color?>(
              qsrColor,
            ),
          ),
        ),
        if (_currentDuration.inSeconds > 0)
          SizedBox(
            height: 48,
            width: 48,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Tooltip(
                  message: getTimeInString()[1],
                  child: Text(
                    getTimeInString()[0],
                    style: context.textTheme.labelMedium,
                  ),
                ),
              ],
            ),
          )
        else
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.close),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _countDownTimer.cancel();
    super.dispose();
  }

  List<String> getTimeInString() {
    final List<String> time = [];
    if (_currentDuration.inHours >= 24) {
      time.add((_currentDuration.inHours ~/ 24).toString());
      time.add("days");
    } else if (_currentDuration.inHours >= 1) {
      time.add(_currentDuration.inHours.toString());
      time.add("hour");
    } else if (_currentDuration.inMinutes >= 1) {
      time.add(_currentDuration.inMinutes.toString());
      time.add("minute");
    } else {
      time.add(_currentDuration.inSeconds.toString());
      time.add("second");
    }
    return time;
  }

  double differenceInPercentage() {
    final Duration fullDuration = widget.totalDuration;
    double percent = 0;
    if (_currentDuration.inDays > 1) {
      percent = _currentDuration.inDays / fullDuration.inDays;
    } else if (_currentDuration.inHours < 24 && _currentDuration.inHours > 1) {
      percent = _currentDuration.inHours / fullDuration.inHours;
    } else if (_currentDuration.inMinutes < 60 &&
        _currentDuration.inMinutes > 1) {
      percent = _currentDuration.inMinutes / fullDuration.inMinutes;
    } else {
      percent = _currentDuration.inSeconds / fullDuration.inSeconds;
    }
    return 1 - percent;
  }
}
