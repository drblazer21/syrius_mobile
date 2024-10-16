import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/constants.dart';
import 'package:syrius_mobile/utils/navigation/navigation_functions.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class CreatePhase extends StatelessWidget {
  final Project project;

  const CreatePhase({
    required this.project,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        kVerticalSpacer,
        _getWidgetBody(context),
      ],
    );
  }

  Widget _getWidgetBody(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Text(
            'Start the project by creating a phase to unlock funds',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        kHorizontalSpacer,
        ElevatedButton.icon(
          onPressed: _canCreatePhase()
              ? () {
                  showPhaseCreationStepper(
                    context: context,
                    project: project,
                  );
                }
              : null,
          label: const Text('Create phase'),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }

  bool _canCreatePhase() =>
      project.status == AcceleratorProjectStatus.active &&
      (project.phases.isEmpty ||
          project.phases.last.status == AcceleratorProjectStatus.paid);
}
