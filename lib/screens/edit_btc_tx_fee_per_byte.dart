import 'package:big_decimal/big_decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/buttons/syrius_filled_button.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/custom_appbar_screen.dart';

class EditBtcTxFeePerByteScreen extends StatefulWidget {
  final BigInt balance;
  final double feePerByte;
  final BigInt txValue;
  final int txSize;

  const EditBtcTxFeePerByteScreen({
    required this.balance,
    required this.feePerByte,
    required this.txValue,
    required this.txSize,
    super.key,
  });

  @override
  State<EditBtcTxFeePerByteScreen> createState() =>
      _EditBtcTxFeePerByteScreenState();
}

class _EditBtcTxFeePerByteScreenState extends State<EditBtcTxFeePerByteScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.feePerByte.toString();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: 'Edit Fee',
      child: ValueListenableBuilder(
        valueListenable: _controller,
        builder: (_, value, __) {
          final String? errorText = _validateFee(value.text);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  errorText: errorText,
                  hintText: 'Fee per byte',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                onSubmitted: (String value) {
                  if (errorText == null) {
                    Navigator.pop(
                      context,
                      double.parse(_controller.text),
                    );
                  }
                },
              ),
              SyriusFilledButton(
                text: AppLocalizations.of(context)!.save,
                onPressed: errorText != null
                    ? null
                    : () {
                        Navigator.pop(
                          context,
                          double.parse(_controller.text),
                        );
                      },
              ),
            ],
          );
        },
      ),
    );
  }

  String? _validateFee(String input) {
    try {
      _checkThatInputDoesntHaveTooManyDecimals(input);

      final BigDecimal userFeeBigDecimal = BigDecimal.parse(input);

      if (userFeeBigDecimal == BigDecimal.zero) {
        return "Fee can't be zero";
      }

      final BigDecimal totalFee =
          BigDecimal.parse(widget.txSize.toString()) * userFeeBigDecimal;

      final BigDecimal txValue = BigDecimal.fromBigInt(widget.txValue);

      final BigDecimal balance = BigDecimal.fromBigInt(widget.balance);

      final BigDecimal totalTxValue = txValue + totalFee;

      if (totalTxValue > balance) {
        return 'Fee is too high';
      }
      return null;
    } catch (e) {
      return e is String ? e : 'Input is not valid';
    }
  }

  void _checkThatInputDoesntHaveTooManyDecimals(String input) {
    final double number = double.parse(input);

    if (input.contains('.')) {
      final String inputDecimals = input.split('.').last;
      final String numberDecimals = number.toString().split('.').last;

      if (inputDecimals.length > numberDecimals.length) {
        throw 'Input has too many decimals';
      }
    }
  }
}
