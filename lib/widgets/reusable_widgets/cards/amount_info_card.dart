import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class AmountInfoCard extends StatelessWidget {
  final AccountInfo accountInfo;
  final String? Function(String) amountValidator;
  final List<Token> coins;
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(Token)? onTokenDropdownPressed;
  final FocusNode? recipientFocusNode;
  final Token selectedToken;
  final TextInputAction textInputAction;
  final bool requiredInteger;

  const AmountInfoCard({
    required this.accountInfo,
    required this.amountValidator,
    required this.coins,
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
                    DropdownMenu<Token>(
                      width: 150.0,
                      inputDecorationTheme: InputDecorationTheme(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.zero,
                        filled: true,
                        fillColor: context.colorScheme.scrim,
                      ),
                      initialSelection: coins.first,
                      leadingIcon: _buildLeadingIcon(selectedToken),
                      dropdownMenuEntries: _generateItems(),
                      onSelected: (token) {
                        if (token != null) {
                          onTokenDropdownPressed?.call(token);
                        }
                      },
                    ),
                    kIconAndTextHorizontalSpacer,
                    Expanded(
                      child: _buildBalanceInfo(context, accountInfo),
                    ),
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
                  maxDecimals: kZnnCoin.decimals,
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

  Widget _buildBalanceInfo(
    BuildContext context,
    AccountInfo accountInfo,
  ) {
    final balance = accountInfo
        .getBalance(selectedToken.tokenStandard)
        .toStringWithDecimals(coinDecimals);

    return Tooltip(
      message: balance,
      child: Text(
        balance,
        style: Theme.of(context).textTheme.headlineSmall,
        maxLines: 1,
        textAlign: TextAlign.end,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _onMaxPressed(AccountInfo accountInfo) {
    final BigInt maxBalance = accountInfo.getBalance(
      selectedToken.tokenStandard,
    );

    if (controller.text.isEmpty ||
        controller.text.extractDecimals(selectedToken.decimals) < maxBalance) {
      controller.text = maxBalance.toStringWithDecimals(selectedToken.decimals);
    }
  }

  Widget _buildLeadingIcon(Token token) {
    final Color iconColor = getTokenColor(token);
    final Color bgColor = getTokenColor(token).withOpacity(0.3);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        backgroundColor: bgColor,
        radius: 15.0,
        child: SvgIcon(
          iconFileName: 'zn_icon',
          iconColor: iconColor,
        ),
      ),
    );
  }

  List<DropdownMenuEntry<Token>> _generateItems() {
    return List.generate(
      coins.length,
      (index) {
        final Token coin = coins.elementAt(
          index,
        );

        return DropdownMenuEntry(
          value: coin,
          label: coin.symbol,
          leadingIcon: _buildLeadingIcon(coin),
        );
      },
    );
  }
}
