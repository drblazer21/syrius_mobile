import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/utils/extensions/extensions.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class AmountInfoCard extends StatelessWidget {
  final AccountInfo accountInfo;
  final String? Function(String) amountValidator;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback? onTokenDropdownPressed;
  final FocusNode? recipientFocusNode;
  final Token selectedToken;
  final TextInputAction textInputAction;
  final bool requiredInteger;

  const AmountInfoCard({
    required this.accountInfo,
    required this.amountValidator,
    required this.controller,
    required this.focusNode,
    required this.selectedToken,
    required this.requiredInteger,
    super.key,
    this.onTokenDropdownPressed,
    this.recipientFocusNode,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTokenInfo(context),
                    _buildBalanceInfo(context, accountInfo),
                  ],
                ),
              ],
            ),
          ),
        ),
        kVerticalSpacer,
        Row(
          children: [
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: controller,
                builder: (_, __, ___) => AmountTextField(
                  context: context,
                  controller: controller,
                  focusNode: focusNode,
                  onMaxPressed: () => _onMaxPressed(accountInfo),
                  recipientFocusNode: recipientFocusNode,
                  textInputAction: textInputAction,
                  validator: amountValidator,
                  requireInteger: requiredInteger,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Row _buildTokenInfo(BuildContext context) {
    return Row(
      children: [
        Tooltip(
          message: AppLocalizations.of(context)!.zenonTokenStandard,
          child: Text(
            AppLocalizations.of(context)!.zts,
          ),
        ),
        kIconAndTextHorizontalSpacer,
        TokenDropdown(
          token: selectedToken,
          onTap: onTokenDropdownPressed,
        ),
      ],
    );
  }

  Widget _buildBalanceInfo(
    BuildContext context,
    AccountInfo accountInfo,
  ) {
    final balance = accountInfo
        .getBalance(selectedToken.tokenStandard)
        .addDecimals(coinDecimals);
    final symbol = selectedToken.symbol;

    return Text(
      '$balance $symbol',
    );
  }

  void _onMaxPressed(AccountInfo accountInfo) {
    final BigInt maxBalance = accountInfo.getBalance(
      selectedToken.tokenStandard,
    );

    if (controller.text.isEmpty ||
        controller.text.extractDecimals(selectedToken.decimals) < maxBalance) {
      controller.text = maxBalance.addDecimals(selectedToken.decimals);
    }
  }
}
