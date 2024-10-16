import 'package:flutter/material.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class EthAmountInfoCard extends StatelessWidget {
  final EthAccountBalance ethAccountBalance;
  final String? Function(String) amountValidator;
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(NetworkAsset?) onEthAssetSelected;
  final NetworkAsset selectedEthAsset;
  final FocusNode? recipientFocusNode;
  final TextInputAction textInputAction;
  final bool requiredInteger;

  const EthAmountInfoCard({
    required this.amountValidator,
    required this.controller,
    required this.ethAccountBalance,
    required this.focusNode,
    required this.onEthAssetSelected,
    required this.requiredInteger,
    required this.selectedEthAsset,
    super.key,
    this.recipientFocusNode,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    final EthAccountBalanceItem balanceItem = ethAccountBalance.findItem(
      ethAsset: selectedEthAsset,
    );

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                DropdownMenu<NetworkAsset>(
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
                  initialSelection: kSelectedAppNetworkWithAssets!.assets.first,
                  leadingIcon: _buildLeadingIcon(),
                  dropdownMenuEntries: _generateItems(),
                  onSelected: onEthAssetSelected,
                ),
                kIconAndTextHorizontalSpacer,
                Expanded(child: _buildBalanceInfo(context, balanceItem)),
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
                  maxDecimals: kEvmCurrencyDecimals,
                  onMaxPressed: () => _onMaxPressed(balanceItem),
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

  List<DropdownMenuEntry<NetworkAsset>> _generateItems() {
    return List.generate(
      kSelectedAppNetworkWithAssets!.assets.length,
      (index) {
        final NetworkAsset ethAsset =
            kSelectedAppNetworkWithAssets!.assets.elementAt(
          index,
        );

        return DropdownMenuEntry(
          value: ethAsset,
          label: ethAsset.symbol,
          leadingIcon: _buildLeadingIcon(),
        );
      },
    );
  }

  Padding _buildLeadingIcon() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        backgroundColor: BlockChain.evm.bgColor,
        radius: 15.0,
        child: SvgIcon(
          iconFileName: 'eth_icon',
        ),
      ),
    );
  }

  Widget _buildBalanceInfo(
    BuildContext context,
    EthAccountBalanceItem item,
  ) {
    return Tooltip(
      message: item.displayBalance,
      child: Text(
        item.displayBalance,
        style: Theme.of(context).textTheme.headlineSmall,
        maxLines: 1,
        textAlign: TextAlign.end,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _onMaxPressed(EthAccountBalanceItem item) {
    final BigInt maxBalance = item.balance;

    if (controller.text.isEmpty ||
        controller.text.extractDecimals(item.ethAsset.decimals) < maxBalance) {
      controller.text = item.displayBalance;
    }
  }
}
