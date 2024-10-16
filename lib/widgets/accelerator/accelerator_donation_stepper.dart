import 'package:flutter/material.dart' hide Step, StepState, Stepper;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

enum AcceleratorDonationStep {
  donationAddress,
  donationDetails,
  submitDonation,
}

class AcceleratorDonationStepper extends StatefulWidget {
  const AcceleratorDonationStepper({super.key});

  @override
  State<AcceleratorDonationStepper> createState() =>
      _AcceleratorDonationStepperState();
}

class _AcceleratorDonationStepperState
    extends State<AcceleratorDonationStepper> {
  AcceleratorDonationStep _currentStep = AcceleratorDonationStep.values.first;

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _znnAmountController = TextEditingController();
  final TextEditingController _qsrAmountController = TextEditingController();

  final GlobalKey<FormState> _znnAmountKey = GlobalKey();
  final GlobalKey<FormState> _qsrAmountKey = GlobalKey();

  BigInt _znnAmount = BigInt.zero;
  BigInt _qsrAmount = BigInt.zero;

  final SubmitDonationBloc _submitDonationBloc = SubmitDonationBloc();

  @override
  void initState() {
    super.initState();
    _addressController.text = kSelectedAddress!.hex;
    sl.get<BalanceBloc>().get();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: 'Accelerator Donation',
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
    return Theme(
      data: Theme.of(context).copyWith(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: SyriusStepper(
        controlsBuilder: stepperControlsBuilder,
        currentStep: _currentStep.index,
        onStepCancel: () {
          if (_currentStep.index == 0) {
            Navigator.pop(context);
          } else {
            setState(() {
              _currentStep = AcceleratorDonationStep.values
                  .elementAt(_currentStep.index - 1);
            });
          }
        },
        onStepContinue: () {
          if (_currentStep == AcceleratorDonationStep.donationAddress) {
            final bool hasEnoughBalance = accountInfo.znn()! > BigInt.zero;
            if (hasEnoughBalance) {
              setState(() {
                _currentStep = AcceleratorDonationStep.donationDetails;
              });
            }
          } else if (_currentStep == AcceleratorDonationStep.donationDetails) {
            if (_ifInputValid(accountInfo)) {
              setState(() {
                _currentStep = AcceleratorDonationStep.submitDonation;
              });
            }
          } else {
            _submitDonationBloc.submitDonation(
              _znnAmount,
              _qsrAmount,
            );
            Navigator.pop(context);
          }
        },
        onStepTapped: (int index) {},
        steps: [
          Step(
            title: const Text('Donation address'),
            content: _getDonationAddressStepContent(accountInfo),
            subtitle: Text(_addressController.text),
            state: _handleStepState(0),
          ),
          Step(
            title: const Text('Donation details'),
            content: _getDonationDetailsStepContent(accountInfo),
            subtitle: Text(_getDonationDetailsStepSubtitle()),
            state: _handleStepState(1),
          ),
          Step(
            title: const Text('Submit donation'),
            content: _getSubmitDonationStepContent(),
            state: _handleStepState(2),
          ),
        ],
      ),
    );
  }

  String _getDonationDetailsStepSubtitle() {
    final String znnPrefix = _znnAmountController.text.isNotEmpty
        ? '${_znnAmountController.text} ${kZnnCoin.symbol}'
        : '';
    final String qsrSuffix = _qsrAmountController.text.isNotEmpty
        ? '${_qsrAmountController.text} ${kQsrCoin.symbol}'
        : '';
    final String splitter =
        znnPrefix.isNotEmpty && qsrSuffix.isNotEmpty ? ' ● ' : '';

    return znnPrefix + splitter + qsrSuffix;
  }

  Widget _getDonationAddressStepContent(AccountInfo accountInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _addressController,
          enabled: false,
        ),
        AvailableBalance(kZnnCoin, accountInfo),
        WarningWidget(
          iconData: Icons.info,
          fillColor: context.colorScheme.primaryContainer,
          textColor: context.colorScheme.onPrimaryContainer,
          text: 'All donated funds go directly into the Accelerator address',
        ),
      ].addSeparator(
        kVerticalSpacer,
        addAfterLastItem: true,
      ),
    );
  }

  Widget _getDonationDetailsStepContent(AccountInfo accountInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Total donation budget'),
            Tooltip(
              message: 'Your donation matters',
              child: Icon(Icons.help),
            ),
          ],
        ),
        Form(
          key: _znnAmountKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: TextField(
            controller: _znnAmountController,
            decoration: InputDecoration(
              errorText: correctValueSyrius(
                _znnAmountController.text,
                accountInfo.znn()!,
                coinDecimals,
                BigInt.zero,
                canBeEqualToMin: true,
                canBeBlank: true,
              ),
              hintText: 'ZNN Amount',
              suffixIcon: TextButton(
                onPressed: () {
                  final BigInt maxZnn = accountInfo.getBalance(
                    kZnnCoin.tokenStandard,
                  );
                  if (_znnAmountController.text.isEmpty ||
                      _znnAmountController.text
                              .extractDecimals(kZnnCoin.decimals) <
                          maxZnn) {
                    setState(() {
                      _znnAmountController.text =
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
            inputFormatters: generateAmountTextInputFormatters(
              replacementString: _znnAmountController.text,
              maxDecimals: kZnnCoin.decimals,
            ),
          ),
        ),
        AvailableBalance(kZnnCoin, accountInfo),
        Form(
          key: _qsrAmountKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: TextField(
            controller: _qsrAmountController,
            decoration: InputDecoration(
              errorText: correctValueSyrius(
                _qsrAmountController.text,
                accountInfo.qsr()!,
                coinDecimals,
                BigInt.zero,
                canBeEqualToMin: true,
                canBeBlank: true,
              ),
              hintText: 'QSR Amount',
              suffixIcon: TextButton(
                onPressed: () {
                  final BigInt maxQsr = accountInfo.getBalance(
                    kQsrCoin.tokenStandard,
                  );
                  if (_qsrAmountController.text.isEmpty ||
                      _qsrAmountController.text
                              .extractDecimals(kQsrCoin.decimals) <
                          maxQsr) {
                    setState(() {
                      _qsrAmountController.text =
                          maxQsr.toStringWithDecimals(kQsrCoin.decimals);
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
            inputFormatters: generateAmountTextInputFormatters(
              replacementString: _qsrAmountController.text,
              maxDecimals: kQsrCoin.decimals,
            ),
          ),
        ),
        AvailableBalance(kQsrCoin, accountInfo),
      ].addSeparator(
        kVerticalSpacer,
        addAfterLastItem: true,
      ),
    );
  }

  bool _ifInputValid(AccountInfo accountInfo) {
    try {
      _znnAmount = _znnAmountController.text.isNotEmpty
          ? _znnAmountController.text.extractDecimals(coinDecimals)
          : BigInt.zero;
      _qsrAmount = _qsrAmountController.text.isNotEmpty
          ? _qsrAmountController.text.extractDecimals(coinDecimals)
          : BigInt.zero;
    } catch (_) {}

    return correctValueSyrius(
              _znnAmountController.text,
              accountInfo.znn()!,
              coinDecimals,
              BigInt.zero,
              canBeEqualToMin: true,
              canBeBlank: true,
            ) ==
            null &&
        correctValueSyrius(
              _qsrAmountController.text,
              accountInfo.qsr()!,
              coinDecimals,
              BigInt.zero,
              canBeEqualToMin: true,
              canBeBlank: true,
            ) ==
            null &&
        (_qsrAmountController.text.isNotEmpty ||
            _znnAmountController.text.isNotEmpty) &&
        (_znnAmount > BigInt.zero || _qsrAmount > BigInt.zero);
  }

  Widget _getSubmitDonationStepContent() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                'Thank you for supporting the Accelerator',
              ),
            ),
            kIconAndTextHorizontalSpacer,
            Icon(Icons.thumb_up),
          ],
        ),
        kVerticalSpacer,
      ],
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _znnAmountController.dispose();
    _qsrAmountController.dispose();
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
