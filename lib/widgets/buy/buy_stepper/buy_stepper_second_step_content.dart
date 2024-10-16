import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/utils/constants.dart';
import 'package:syrius_mobile/utils/extensions/extensions.dart';
import 'package:syrius_mobile/utils/input_validators.dart';
import 'package:syrius_mobile/utils/text_input_formatters.dart';

class BuyStepperSecondStepContent extends StatelessWidget {
  final BigInt weiBalance;
  final TextEditingController ethAmountController;

  const BuyStepperSecondStepContent({
    required this.weiBalance,
    required this.ethAmountController,
    super.key,
  });

  String get _ethAmountTextFieldContent => ethAmountController.text;

  BigInt get _ethAmountForSwapping =>
      _ethAmountTextFieldContent.extractDecimals(18);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ethAmountController,
      builder: (_, __, ___) => TextField(
        controller: ethAmountController,
        decoration: InputDecoration(
          errorMaxLines: 2,
          errorText: _ethAmountValidator(_ethAmountTextFieldContent),
          hintText: AppLocalizations.of(context)!.amount,
          suffixIcon: TextButton(
            onPressed: _onMaxPressed,
            child: Text(
              AppLocalizations.of(context)!.max.toUpperCase(),
            ),
          ),
        ),
        inputFormatters: generateAmountTextInputFormatters(
          replacementString: _ethAmountTextFieldContent,
          maxDecimals: kEvmCurrencyDecimals,
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  String? _ethAmountValidator(String input) {
    if (input.isNotEmpty) {
      return correctValueSyrius(
        input,
        weiBalance,
        kEvmCurrencyDecimals,
        kMinimumWeiNeededForSwapping,
        canBeEqualToMin: true,
      );
    }
    return null;
  }

  void _onMaxPressed() {
    final BigInt maxBalance = weiBalance;

    if (_ethAmountTextFieldContent.isEmpty ||
        _ethAmountForSwapping < maxBalance) {
      ethAmountController.text = maxBalance.toStringWithDecimals(kEvmCurrencyDecimals);
    }
  }
}
