import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:syrius_mobile/utils/file_utils.dart';
import 'package:syrius_mobile/utils/ui/modal_bottom_sheets.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/buttons/syrius_filled_button.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/custom_appbar_screen.dart';
import 'package:timer_button/timer_button.dart';

class DeleteWalletScreen extends StatefulWidget {
  const DeleteWalletScreen({super.key});

  @override
  State<DeleteWalletScreen> createState() => _DeleteWalletScreenState();
}

class _DeleteWalletScreenState extends State<DeleteWalletScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.deleteWallet,
      child: Column(
        children: [
          const Spacer(),
          _buildDeleteInfo(context),
          const Spacer(),
          _buildDeleteButton(context),
        ],
      ),
    );
  }

  Future<dynamic> _showDeleteConfirmationBottomSheet(BuildContext context) {
    return showModalBottomSheetWithBody(
      context: context,
      title: AppLocalizations.of(context)!.deleteWallet,
      body: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.reviewWalletDeletion,
            style: context.textTheme.titleSmall?.copyWith(
              color: context.colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
          kVerticalSpacer,
          _buildDeleteConfirmButton(context),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SyriusFilledButton.color(
        color: context.colorScheme.errorContainer,
        text: AppLocalizations.of(context)!.deleteWallet,
        onPressed: () async {
          await _showDeleteConfirmationBottomSheet(context);
        },
      ),
    );
  }

  Widget _buildDeleteConfirmButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TimerButton(
        label: AppLocalizations.of(context)!.delete,
        color: Colors.red,
        disabledTextStyle: const TextStyle(color: Colors.grey),
        buttonType: ButtonType.outlinedButton,
        timeOutInSeconds: 5,
        onPressed: () async {
          await FileUtils.deleteWallet();
        },
      ),
    );
  }

  Widget _buildDeleteInfo(BuildContext context) {
    return Row(
      children: [
        Icon(
          MdiIcons.alertOctagon,
          color: context.colorScheme.errorContainer,
          size: 50.0,
        ),
        kHorizontalSpacer,
        Expanded(
          child: Text(
            AppLocalizations.of(context)!.deleteWalletDescription,
            style: context.textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
