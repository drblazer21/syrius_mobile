import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/file_utils.dart';
import 'package:syrius_mobile/utils/utils.dart';

class PinExponentialBackoffService {
  final Duration waitInterval;
  final int maxAttempts;
  final int sequenceAttempts;

  late ValueNotifier<int> countDownDurationNotifier;
  VoidCallback? whenTimerStateToggles;

  int attemptsCounter = 0;

  static Timer? _countDownTimer;
  static late Duration _countDownDuration;

  PinExponentialBackoffService({
    this.maxAttempts = 9,
    this.sequenceAttempts = 3,
    this.waitInterval = const Duration(seconds: 5),
  });

  void increaseCounter() {
    ++attemptsCounter;
    if (attemptsCounter >= maxAttempts) {
      FileUtils.deleteWallet();
    } else {
      if (_shouldStartTimer()) {
        _startTimer();
      }
      secureStorageUtil.write(
        key: kPinLoggingFailedAttemptsKey,
        value: attemptsCounter.toString(),
      );
    }
  }

  Future<void> resetCounter() async {
    if (attemptsCounter > 0) {
      attemptsCounter = 0;
      await secureStorageUtil.write(
        key: kPinLoggingFailedAttemptsKey,
        value: '0',
      );
    }
  }

  void _startTimer({
    Duration? countDownDuration,
}) {
    const Duration oneSecond = Duration(seconds: 1);
    _countDownDuration = countDownDuration ?? _calculateWaitTime();
    countDownDurationNotifier = ValueNotifier(_countDownDuration.inSeconds);
    _countDownTimer = Timer.periodic(
      oneSecond,
      (timer) {
        sharedPrefs.setInt(
          kPinCoolDownSecondsLeftKey,
          _countDownDuration.inSeconds,
        );
        if (_countDownDuration > oneSecond) {
          _countDownDuration = _countDownDuration - oneSecond;
          countDownDurationNotifier.value = _countDownDuration.inSeconds;
        } else {
          sharedPrefs.setInt(
            kPinCoolDownSecondsLeftKey,
            0,
          );
          _cancelTimer();
          whenTimerStateToggles?.call();
        }
      },
    );
    whenTimerStateToggles?.call();
  }

  Duration _calculateWaitTime() {
    final int sequenceNum = attemptsCounter ~/ sequenceAttempts;

    return waitInterval * pow(2, sequenceNum);
  }

  Duration _getSavedCountDownDuration() {
    final int savedCountDownSecondsLeft = sharedPrefs.getInt(
      kPinCoolDownSecondsLeftKey,
    ) ?? 0;

    return Duration(seconds: savedCountDownSecondsLeft);
  }

  void _cancelTimer() => _countDownTimer!.cancel();

  bool _shouldStartTimer() =>
      attemptsCounter > 0 && attemptsCounter % sequenceAttempts == 0;

  bool maxAttemptsReached() => attemptsCounter == maxAttempts;

  bool isTimerActive() => _countDownTimer != null && _countDownTimer!.isActive;

  bool get shouldDisablePinLogging => isTimerActive() || maxAttemptsReached();

  void checkForSavedCountDownDuration() {
    final Duration savedDuration = _getSavedCountDownDuration();

    if (savedDuration > Duration.zero) {
      _startTimer(countDownDuration: savedDuration);
    }
  }
}
