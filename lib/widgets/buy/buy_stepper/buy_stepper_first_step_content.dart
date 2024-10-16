import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/buttons/refresh_button.dart';

class BuyStepperFirstStepContent extends StatelessWidget {
  final TextEditingController ethAddressController;
  final String ethBalance;
  final VoidCallback onRefreshButtonPressed;
  final TextEditingController znnAddressController;

  const BuyStepperFirstStepContent({
    required this.ethAddressController,
    required this.ethBalance,
    required this.onRefreshButtonPressed,
    required this.znnAddressController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: znnAddressController,
          readOnly: true,
        ),
        TextField(
          controller: ethAddressController,
          readOnly: true,
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                'Available balance: $ethBalance',
              ),
            ),
            RefreshButton(onPressed: onRefreshButtonPressed),
          ],
        ),
      ].addSeparator(kVerticalSpacer),
    );
  }
}
