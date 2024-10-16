import 'package:flutter/material.dart' hide Step, StepState, Stepper;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

enum UpdatePhaseStep {
  phaseDetails,
  updatePhase,
}

class UpdatePhaseStepper extends StatefulWidget {
  final Phase phase;
  final Project project;

  const UpdatePhaseStepper(
    this.phase,
    this.project, {
    super.key,
  });

  @override
  State<UpdatePhaseStepper> createState() => _UpdatePhaseStepperState();
}

class _UpdatePhaseStepperState extends State<UpdatePhaseStepper> {
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

  UpdatePhaseStep _currentStep = UpdatePhaseStep.values.first;

  final UpdatePhaseBloc _updatePhaseBloc = UpdatePhaseBloc();

  @override
  void initState() {
    super.initState();
    _addressController.text = kSelectedAddress!.hex;
    _phaseNameController.text = widget.phase.name;
    _phaseDescriptionController.text = widget.phase.description;
    _phaseUrlController.text = widget.phase.url;
    _phaseZnnAmountController.text =
        widget.phase.znnFundsNeeded.toStringWithDecimals(kZnnCoin.decimals);
    _phaseQsrAmountController.text =
        widget.phase.qsrFundsNeeded.toStringWithDecimals(kQsrCoin.decimals);
    sl.get<BalanceBloc>().get();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: 'Update Phase',
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
                UpdatePhaseStep.values.elementAt(_currentStep.index - 1);
          });
        }
      },
      onStepContinue: () {
        if (_currentStep == UpdatePhaseStep.phaseDetails) {
          if (_areInputDetailsValid()) {
            setState(() {
              _currentStep = UpdatePhaseStep.updatePhase;
            });
          }
        } else if (_currentStep == UpdatePhaseStep.updatePhase) {
          _updatePhaseBloc.updatePhase(
            widget.project.id,
            _phaseNameController.text,
            _phaseDescriptionController.text,
            _phaseUrlController.text,
            _phaseZnnAmountController.text.extractDecimals(coinDecimals),
            _phaseQsrAmountController.text.extractDecimals(coinDecimals),
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
          title: const Text('Update phase'),
          content: _getUpdatePhaseStepContent(),
          subtitle: Text('ID ${widget.phase.id.toShortString()}'),
          state: _handleStepState(1),
        ),
      ],
    );
  }

  Widget _getPhaseDetailsStepContent(AccountInfo accountInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This phase belongs to Project ID '
          '${widget.phase.id.toShortString()}',
          style: context.textTheme.titleMedium,
        ),
        kVerticalSpacer,
        Form(
          key: _phaseNameKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: TextField(
            controller: _phaseNameController,
            decoration: InputDecoration(
              errorText: Validations.projectName(_phaseNameController.text),
              hintText: 'Phase name',
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        kVerticalSpacer,
        TextFormField(
          key: _phaseDescriptionKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: _phaseDescriptionController,
          decoration: const InputDecoration(
            hintText: 'Phase description',
          ),
          onChanged: (value) {
            setState(() {});
          },
          validator: Validations.projectDescription,
        ),
        kVerticalSpacer,
        TextFormField(
          key: _phaseUrlKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: _phaseUrlController,
          decoration: const InputDecoration(
            hintText: 'Phase URL',
          ),
          onChanged: (value) {
            setState(() {});
          },
          validator: (value) {
            if (value != null) {
              return acceleratorProjectUrlValidator(value);
            }
            return 'Value is null';
          },
        ),
        kVerticalSpacer,
        Text(
          'Total phase budget',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        kVerticalSpacer,
        TextFormField(
          key: _phaseZnnAmountKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: _phaseZnnAmountController,
          decoration: InputDecoration(
            hintText: 'ZNN Amount',
            suffixIcon: TextButton(
              onPressed: () {
                setState(() {
                  _phaseZnnAmountController.text = widget.project
                      .getRemainingZnnFunds()
                      .toStringWithDecimals(kZnnCoin.decimals);
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
          validator: (value) => correctValueSyrius(
            value,
            widget.project.getRemainingZnnFunds(),
            kZnnCoin.decimals,
            BigInt.zero,
            canBeEqualToMin: true,
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
        kVerticalSpacer,
        TextFormField(
          key: _phaseQsrAmountKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: _phaseQsrAmountController,
          decoration: InputDecoration(
            hintText: 'QSR Amount',
            suffixIcon: TextButton(
              onPressed: () {
                setState(() {
                  _phaseQsrAmountController.text = widget.project
                      .getRemainingQsrFunds()
                      .toStringWithDecimals(kQsrCoin.decimals);
                });
              },
              child: Text(
                AppLocalizations.of(context)!.max.toUpperCase(),
              ),
            ),
          ),
          inputFormatters: generateAmountTextInputFormatters(
            replacementString: _phaseQsrAmountController.text,
            maxDecimals: kZnnCoin.decimals,
          ),
          validator: (value) => correctValueSyrius(
            value,
            widget.project.getRemainingQsrFunds(),
            kQsrCoin.decimals,
            BigInt.zero,
            canBeEqualToMin: true,
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
        kVerticalSpacer,
      ],
    );
  }

  Widget _getUpdatePhaseStepContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WarningWidget(
          iconData: Icons.info,
          fillColor: context.colorScheme.primaryContainer,
          textColor: context.colorScheme.onPrimaryContainer,
          text: 'Updating this phase will reset all current votes',
        ),
        kVerticalSpacer,
      ],
    );
  }

  bool _areInputDetailsValid() =>
      Validations.projectName(_phaseNameController.text) == null &&
      Validations.projectDescription(_phaseDescriptionController.text) ==
          null &&
      acceleratorProjectUrlValidator(_phaseUrlController.text) == null &&
      correctValueSyrius(
            _phaseZnnAmountController.text,
            widget.project.getRemainingZnnFunds(),
            kZnnCoin.decimals,
            BigInt.zero,
            canBeEqualToMin: true,
          ) ==
          null &&
      correctValueSyrius(
            _phaseQsrAmountController.text,
            widget.project.getRemainingQsrFunds(),
            kQsrCoin.decimals,
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
