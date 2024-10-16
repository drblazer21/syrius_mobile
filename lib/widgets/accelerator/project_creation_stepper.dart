import 'package:flutter/material.dart' hide Step, StepState, Stepper;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

enum ProjectCreationStep {
  projectCreation,
  projectDetails,
  submitProject,
}

class ProjectCreationStepper extends StatefulWidget {
  const ProjectCreationStepper({super.key});

  @override
  State<ProjectCreationStepper> createState() => _ProjectCreationStepperState();
}

class _ProjectCreationStepperState extends State<ProjectCreationStepper> {
  ProjectCreationStep _currentStep = ProjectCreationStep.values.first;

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _projectDescriptionController =
      TextEditingController();
  final TextEditingController _projectUrlController = TextEditingController();
  final TextEditingController _projectZnnAmountController =
      TextEditingController();
  final TextEditingController _projectQsrAmountController =
      TextEditingController();

  final GlobalKey<FormState> _projectNameKey = GlobalKey();
  final GlobalKey<FormState> _projectDescriptionKey = GlobalKey();
  final GlobalKey<FormState> _projectUrlKey = GlobalKey();
  final GlobalKey<FormState> _projectZnnKey = GlobalKey();
  final GlobalKey<FormState> _projectQsrKey = GlobalKey();

  final CreateProjectBloc _createProjectBloc = CreateProjectBloc();

  @override
  void initState() {
    super.initState();
    _addressController.text = kSelectedAddress!.hex;
    sl.get<BalanceBloc>().get();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: 'Project Creation',
      withBottomPadding: false,
      withLateralPadding: false,
      child: StreamBuilder<AccountInfo>(
        stream: sl.get<BalanceBloc>().stream,
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            return SyriusErrorWidget(snapshot.error!);
          }
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              return _getMaterialStepper(
                context,
                snapshot.data!,
              );
            }
            return const SyriusLoadingWidget();
          }
          return const SyriusLoadingWidget();
        },
      ),
    );
  }

  Widget _getMaterialStepper(BuildContext context, AccountInfo accountInfo) {
    return SyriusStepper(
      controlsBuilder: stepperControlsBuilder,
      currentStep: _currentStep.index,
      onStepCancel: () {
        if (_currentStep.index == 0) {
          Navigator.pop(context);
        } else {
          setState(() {
            _currentStep =
                ProjectCreationStep.values.elementAt(_currentStep.index - 1);
          });
        }
      },
      onStepContinue: () {
        if (_currentStep == ProjectCreationStep.projectCreation) {
          final bool hasEnoughBalance = accountInfo.getBalance(
                kZnnCoin.tokenStandard,
              ) >=
              projectCreationFeeInZnn;
          if (hasEnoughBalance) {
            setState(() {
              _currentStep = ProjectCreationStep.projectDetails;
            });
          }
        } else if (_currentStep == ProjectCreationStep.projectDetails) {
          if (_areInputDetailsValid()) {
            setState(() {
              _currentStep = ProjectCreationStep.submitProject;
            });
          }
        } else {
          _createProjectBloc.createProject(
            _projectNameController.text,
            _projectDescriptionController.text,
            _projectUrlController.text,
            _projectZnnAmountController.text.extractDecimals(
              coinDecimals,
            ),
            _projectQsrAmountController.text.extractDecimals(
              coinDecimals,
            ),
          );
          Navigator.pop(context);
        }
      },
      onStepTapped: (int index) {},
      steps: [
        Step(
          title: const Text('Project creation'),
          content: _getProjectCreationStepContent(accountInfo),
          subtitle: Text(_addressController.text),
          state: _handleStepState(0),
        ),
        Step(
          title: const Text('Project details'),
          content: _getProjectDetailsStepContent(accountInfo),
          subtitle: Text('${_projectNameController.text} ● '
              '${_projectZnnAmountController.text} ${kZnnCoin.symbol} ● '
              '${_projectQsrAmountController.text} ${kQsrCoin.symbol}'),
          state: _handleStepState(1),
        ),
        Step(
          title: const Text('Submit project'),
          content: _getSubmitProjectStepContent(),
          state: _handleStepState(2),
        ),
      ],
    );
  }

  Widget _getProjectCreationStepContent(AccountInfo accountInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('This will be your project owner address'),
        TextField(
          controller: _addressController,
          enabled: false,
        ),
        AvailableBalance(kZnnCoin, accountInfo),
        WarningWidget(
          iconData: Icons.info,
          fillColor: context.colorScheme.primaryContainer,
          textColor: context.colorScheme.onPrimaryContainer,
          text:
              'Creating a project consumes ${projectCreationFeeInZnn.addDecimals(coinDecimals)} ${kZnnCoin.symbol} that goes to the Accelerator',
        ),
      ].addSeparator(
        kVerticalSpacer,
        addAfterLastItem: true,
      ),
    );
  }

  Widget _getProjectDetailsStepContent(AccountInfo accountInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Form(
          key: _projectNameKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: TextField(
            controller: _projectNameController,
            decoration: InputDecoration(
              errorText: Validations.projectName(_projectNameController.text),
              hintText: 'Project name',
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        kVerticalSpacer,
        Form(
          key: _projectDescriptionKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: TextField(
            controller: _projectDescriptionController,
            decoration: InputDecoration(
              errorText: Validations.projectDescription(
                _projectDescriptionController.text,
              ),
              hintText: 'Project description',
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        kVerticalSpacer,
        Row(
          children: [
            Expanded(
              child: Form(
                key: _projectUrlKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: TextField(
                  controller: _projectUrlController,
                  decoration: InputDecoration(
                    errorText: acceleratorProjectUrlValidator(
                      _projectUrlController.text,
                    ),
                    hintText: 'Project URL',
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
            ),
            kIconAndTextHorizontalSpacer,
            const Tooltip(
              message: 'Link to project article',
              child: Icon(Icons.help),
            ),
          ],
        ),
        kVerticalSpacer,
        Row(
          children: [
            Text(
              'Total project budget',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            kIconAndTextHorizontalSpacer,
            const Tooltip(
              message: 'Set a budget for the project',
              child: Icon(Icons.help),
            ),
          ],
        ),
        kVerticalSpacer,
        Form(
          key: _projectZnnKey,
          child: TextField(
            inputFormatters: generateAmountTextInputFormatters(
              replacementString: _projectZnnAmountController.text,
              maxDecimals: kZnnCoin.decimals,
            ),
            controller: _projectZnnAmountController,
            decoration: InputDecoration(
              errorText: correctValueSyrius(
                _projectZnnAmountController.text,
                kZnnProjectMaximumFunds,
                kZnnCoin.decimals,
                kZnnProjectMinimumFunds,
                canBeEqualToMin: true,
              ),
              hintText: 'ZNN Amount',
              suffixIcon: TextButton(
                onPressed: () {
                  final BigInt maxZnn = kZnnProjectMaximumFunds;
                  if (_projectZnnAmountController.text.isEmpty ||
                      _projectZnnAmountController.text
                              .extractDecimals(kZnnCoin.decimals) <
                          maxZnn) {
                    setState(() {
                      _projectZnnAmountController.text =
                          maxZnn.toStringWithDecimals(kZnnCoin.decimals);
                    });
                  }
                },
                child: Text(
                  AppLocalizations.of(context)!.max.toUpperCase(),
                ),
              ),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        kVerticalSpacer,
        Form(
          key: _projectQsrKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: TextField(
            inputFormatters: generateAmountTextInputFormatters(
              replacementString: _projectQsrAmountController.text,
              maxDecimals: kQsrCoin.decimals,
            ),
            controller: _projectQsrAmountController,
            decoration: InputDecoration(
              errorText: correctValueSyrius(
                _projectQsrAmountController.text,
                kQsrProjectMaximumFunds,
                kQsrCoin.decimals,
                kQsrProjectMinimumFunds,
                canBeEqualToMin: true,
              ),
              hintText: 'QSR Amount',
              suffixIcon: TextButton(
                onPressed: () {
                  final BigInt maxQsr = kQsrProjectMaximumFunds;
                  if (_projectQsrAmountController.text.isEmpty ||
                      _projectQsrAmountController.text
                              .extractDecimals(coinDecimals) <
                          maxQsr) {
                    setState(() {
                      _projectQsrAmountController.text =
                          maxQsr.toStringWithDecimals(coinDecimals);
                    });
                  }
                },
                child: Text(
                  AppLocalizations.of(context)!.max.toUpperCase(),
                ),
              ),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        kVerticalSpacer,
      ],
    );
  }

  Widget _getSubmitProjectStepContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            WarningWidget(
              iconData: Icons.info,
              fillColor: context.colorScheme.primaryContainer,
              textColor: context.colorScheme.onPrimaryContainer,
              text:
                  'Consume ${projectCreationFeeInZnn.addDecimals(coinDecimals)} ${kZnnCoin.symbol} to submit the project',
            ),
          ],
        ),
        kVerticalSpacer,
      ],
    );
  }

  bool _areInputDetailsValid() =>
      Validations.projectName(
            _projectNameController.text,
          ) ==
          null &&
      Validations.projectDescription(
            _projectDescriptionController.text,
          ) ==
          null &&
      acceleratorProjectUrlValidator(
            _projectUrlController.text,
          ) ==
          null &&
      correctValueSyrius(
            _projectZnnAmountController.text,
            kZnnProjectMaximumFunds,
            kZnnCoin.decimals,
            kZnnProjectMinimumFunds,
            canBeEqualToMin: true,
          ) ==
          null &&
      correctValueSyrius(
            _projectQsrAmountController.text,
            kQsrProjectMaximumFunds,
            kZnnCoin.decimals,
            kQsrProjectMinimumFunds,
            canBeEqualToMin: true,
          ) ==
          null;

  @override
  void dispose() {
    _addressController.dispose();
    _projectNameController.dispose();
    _projectDescriptionController.dispose();
    _projectUrlController.dispose();
    _projectZnnAmountController.dispose();
    _projectQsrAmountController.dispose();
    super.dispose();
  }

  StepState _handleStepState(int stepIndex) {
    if (_currentStep.index == stepIndex) {
      return StepState.editing;
    } else {
      return StepState.disabled;
    }
  }
}
