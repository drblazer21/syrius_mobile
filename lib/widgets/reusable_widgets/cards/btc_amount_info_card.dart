import 'package:flutter/material.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class BtcAmountInfoCard extends StatelessWidget {
  final BtcAccountBalance btcAccountBalance;
  final String? Function(String) amountValidator;
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(NetworkAsset?) onEthAssetSelected;
  final NetworkAsset selectedEthAsset;
  final FocusNode? recipientFocusNode;
  final TextInputAction textInputAction;
  final bool requiredInteger;

  const BtcAmountInfoCard({
    required this.amountValidator,
    required this.controller,
    required this.btcAccountBalance,
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
                Expanded(child: _buildBalanceInfo(context)),
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
                  maxDecimals: kBtcDecimals,
                  onMaxPressed: () => _onMaxPressed(),
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
        backgroundColor: BlockChain.btc.bgColor,
        radius: 15.0,
        child: SvgIcon(
          iconFileName: 'btc_icon',
          iconColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBalanceInfo(BuildContext context) {
    final String balance =
        btcAccountBalance.confirmed.toStringWithDecimals(kBtcDecimals);

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

  void _onMaxPressed() {
    if (controller.text.isEmpty ||
        controller.text.extractDecimals(kBtcDecimals) <
            btcAccountBalance.confirmed) {
      controller.text =
          btcAccountBalance.confirmed.toStringWithDecimals(kBtcDecimals);
    }
  }
}
