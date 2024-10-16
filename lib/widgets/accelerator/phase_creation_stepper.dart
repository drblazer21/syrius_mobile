import 'package:flutter/material.dart' hide Step, StepState, Stepper;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

enum PhaseCreationStep {
  phaseDetails,
  submitPhase,
}

class PhaseCreationStepper extends StatefulWidget {
  final Project project;

  const PhaseCreationStepper(this.project, {super.key});

  @override
  State<PhaseCreationStepper> createState() => _PhaseCreationStepperState();
}

class _PhaseCreationStepperState extends State<PhaseCreationStepper> {
  PhaseCreationStep _currentStep = PhaseCreationStep.values.first;

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phaseNameController = TextEditingController();
  final TextEditingController _phaseDescriptionController =
      TextEditingController();
  final TextEditingController _phaseUrlController = TextEditingController();
  final TextEditingController _phaseZnnAmountController =
      TextEditingController();
  final TextEditingController _phaseQsrAmountController =
      TextEditingController();

  final GlobalKey<FormState> _phaseNameKey = GlobalKey();
  final GlobalKey<FormState> _phaseDescriptionKey = GlobalKey();
  final GlobalKey<FormState> _phaseUrlKey = GlobalKey();
  final GlobalKey<FormState> _phaseZnnAmountKey = GlobalKey();
  final GlobalKey<FormState> _phaseQsrAmountKey = GlobalKey();

  final CreatePhaseBloc _createPhaseBloc = CreatePhaseBloc();

  @override
  void initState() {
    super.initState();
    _addressController.text = kSelectedAddress!.hex;
    sl.get<BalanceBloc>().get();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: 'Phase Creation',
      withLateralPadding: false,
      withBottomPadding: false,
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
                PhaseCreationStep.values.elementAt(_currentStep.index - 1);
          });
        }
      },
      onStepContinue: () {
        if (_currentStep == PhaseCreationStep.phaseDetails) {
          if (_areInputDetailsValid()) {
            setState(() {
              _currentStep = PhaseCreationStep.submitPhase;
            });
          }
        } else if (_currentStep == PhaseCreationStep.submitPhase) {
          _createPhaseBloc.create(
            widget.project.id,
            _phaseNameController.text,
            _phaseDescriptionController.text,
            _phaseUrlController.text,
            _phaseZnnAmountController.text.extractDecimals(
              coinDecimals,
            ),
            _phaseQsrAmountController.text.extractDecimals(
              coinDecimals,
            ),
          );
          Navigator.pop(context);
        }
      },
      onStepTapped: (int index) {},
      steps: [
        Step(
          title: const Text('Phase details'),
          content: _getPhaseDetailsStepContent(accountInfo),
          subtitle: Text('${_phaseNameController.text} ● '
              '${_phaseZnnAmountController.text} ${kZnnCoin.symbol} ● '
              '${_phaseQsrAmountController.text} ${kQsrCoin.symbol}'),
          state: _handleStepState(0),
        ),
        Step(
          title: const Text('Submit phase'),
          content: _getSubmitPhaseStepContent(),
          subtitle: Text('ID ${widget.project.id.toShortString()}'),
          state: _handleStepState(1),
        ),
      ],
    );
  }

  Widget _getPhaseDetailsStepContent(AccountInfo accountInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('This phase belongs to Project ID '
            '${widget.project.id.toShortString()}'),
        kVerticalSpacer,
        Form(
          key: _phaseNameKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: TextField(
            controller: _phaseNameController,
            decoration: InputDecoration(
              hintText: 'Phase name',
              errorText: Validations.projectName(_phaseNameController.text),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        kVerticalSpacer,
        Form(
          key: _phaseDescriptionKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: TextField(
            controller: _phaseDescriptionController,
            decoration: InputDecoration(
              errorText: Validations.projectDescription(
                _phaseDescriptionController.text,
              ),
              hintText: 'Phase description',
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
                key: _phaseUrlKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: TextField(
                  controller: _phaseUrlController,
                  decoration: InputDecoration(
                    errorText: acceleratorProjectUrlValidator(
                      _phaseUrlController.text,
                    ),
                    hintText: 'Phase URL',
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
            ),
            kIconAndTextHorizontalSpacer,
            const Tooltip(
              message:
                  'Showcase the progress of your project (e.g. Git PR/commit)',
              child: Icon(Icons.help),
            ),
          ],
        ),
        kVerticalSpacer,
        Row(
          children: [
            Text(
              'Total phase budget',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            kIconAndTextHorizontalSpacer,
            const Tooltip(
              message: 'Necessary budget to successfully complete this phase',
              child: Icon(Icons.help),
            ),
          ],
        ),
        kVerticalSpacer,
        Form(
          key: _phaseZnnAmountKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: TextField(
            controller: _phaseZnnAmountController,
            decoration: InputDecoration(
              errorText: correctValueSyrius(
                _phaseZnnAmountController.text,
                widget.project.getRemainingZnnFunds(),
                coinDecimals,
                BigInt.zero,
                canBeEqualToMin: true,
              ),
              hintText: 'ZNN Amount',
              suffixIcon: TextButton(
                onPressed: () {
                  setState(() {
                    _phaseZnnAmountController.text = widget.project
                        .getRemainingZnnFunds()
                        .toStringWithDecimals(coinDecimals);
                  });
                },
                child: Text(
                  AppLocalizations.of(context)!.max.toUpperCase(),
                ),
              ),
            ),
            inputFormatters: generateAmountTextInputFormatters(
              replacementString: _phaseZnnAmountController.text,
              maxDecimals: kZnnCoin.decimals,
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        kVerticalSpacer,
        Form(
          key: _phaseQsrAmountKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: TextField(
            controller: _phaseQsrAmountController,
            decoration: InputDecoration(
              errorText: correctValueSyrius(
                _phaseQsrAmountController.text,
                widget.project.getRemainingQsrFunds(),
                coinDecimals,
                BigInt.zero,
                canBeEqualToMin: true,
              ),
              hintText: 'QSR Amount',
              suffixIcon: TextButton(
                onPressed: () {
                  setState(() {
                    _phaseQsrAmountController.text = widget.project
                        .getRemainingQsrFunds()
                        .toStringWithDecimals(coinDecimals);
                  });
                },
                child: Text(
                  AppLocalizations.of(context)!.max.toUpperCase(),
                ),
              ),
            ),
            inputFormatters: generateAmountTextInputFormatters(
              replacementString: _phaseQsrAmountController.text,
              maxDecimals: kQsrCoin.decimals,
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

  Widget _getSubmitPhaseStepContent() {
    final BigInt remainingZnnBudget = widget.project.getRemainingZnnFunds() -
        (_phaseZnnAmountController.text.isNotEmpty
            ? _phaseZnnAmountController.text.extractDecimals(coinDecimals)
            : BigInt.zero);

    final BigInt remainingQsrBudget = widget.project.getRemainingQsrFunds() -
        (_phaseQsrAmountController.text.isNotEmpty
            ? _phaseQsrAmountController.text.extractDecimals(coinDecimals)
            : BigInt.zero);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WarningWidget(
          iconData: Icons.info,
          fillColor: context.colorScheme.primaryContainer,
          textColor: context.colorScheme.onPrimaryContainer,
          text: 'Remaining budget for the next phases is '
              '${remainingZnnBudget.addDecimals(coinDecimals)} ${kZnnCoin.symbol} and '
              '${remainingQsrBudget.addDecimals(coinDecimals)} ${kQsrCoin.symbol}',
        ),
        kVerticalSpacer,
      ],
    );
  }

  bool _areInputDetailsValid() =>
      Validations.projectName(
            _phaseNameController.text,
          ) ==
          null &&
      Validations.projectDescription(
            _phaseDescriptionController.text,
          ) ==
          null &&
      acceleratorProjectUrlValidator(
            _phaseUrlController.text,
          ) ==
          null &&
      correctValueSyrius(
            _phaseZnnAmountController.text,
            widget.project.getRemainingZnnFunds(),
            coinDecimals,
            BigInt.zero,
            canBeEqualToMin: true,
          ) ==
          null &&
      correctValueSyrius(
            _phaseQsrAmountController.text,
            widget.project.getRemainingQsrFunds(),
            coinDecimals,
            BigInt.zero,
            canBeEqualToMin: true,
          ) ==
          null;

  @override
  void dispose() {
    _addressController.dispose();
    _phaseNameController.dispose();
    _phaseDescriptionController.dispose();
    _phaseUrlController.dispose();
    _phaseZnnAmountController.dispose();
    _phaseQsrAmountController.dispose();
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
