import 'package:flutter/material.dart'
    hide ControlsDetails, ControlsWidgetBuilder, Step, StepState, Stepper;
import 'package:syrius_mobile/utils/constants.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/syrius_stepper.dart';

Widget stepperControlsBuilder(
  BuildContext context,
  ControlsDetails controlDetails,
) {
  final OutlinedButton continueButton = OutlinedButton(
    onPressed: controlDetails.onStepContinue,
    child: const Text('Continue'),
  );

  final OutlinedButton cancelButton = OutlinedButton(
    onPressed: controlDetails.onStepCancel,
    child: const Text('Cancel'),
  );

  return Row(
    children: [
      cancelButton,
      kHorizontalSpacer,
      continueButton,
    ],
  );
}
