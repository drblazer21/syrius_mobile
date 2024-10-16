import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class StakeDuration extends StatefulWidget {
  final Duration currentValue;
  final Function(Duration) onChange;

  const StakeDuration({
    required this.currentValue,
    required this.onChange,
    super.key,
  });

  @override
  State<StakeDuration> createState() => _StakeDurationState();
}

class _StakeDurationState extends State<StakeDuration> {
  final List<Duration> _durations = List.generate(
    stakeTimeMaxSec ~/ stakeTimeUnitSec,
    (index) => Duration(
      seconds: (index + 1) * stakeTimeUnitSec,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final int numberOfMonths = widget.currentValue.inDays ~/ 30;

    final String monthString = numberOfMonths > 1 ? "months" : "month";
    return SizedBox(
      height: 150.0,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.stakingDuration,
                    style: context.textTheme.titleMedium,
                  ),
                  Container(
                    decoration: ShapeDecoration(
                      color: context.colorScheme.scrim,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 6.0,
                    ),
                    child: Text(
                      '$numberOfMonths $monthString',
                      style: context.textTheme.titleSmall?.copyWith(
                        color: context.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Slider.adaptive(
              min: 1,
              max: 12,
              value: numberOfMonths.toDouble(),
              divisions: 11,
              onChanged: (value) {
                widget.onChange(_durations[value.toInt() - 1]);
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text(
                      '1 month',
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Text(
                      '12 months',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
