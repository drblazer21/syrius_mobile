import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

Future showModalBottomSheetWithButtons({
  required BuildContext context,
  Widget? dialogImage,
  required String title,
  bool isDismissible = true,
  String? subTitle,
  Widget? subTitleWidget,
  String btn1Text = '',
  String btn2Text = '',
  VoidCallback? btn1Action,
  VoidCallback? btn2Action,
  Color? btn1Color,
  Color? btn2Color,
}) {
  return showModalBottomSheet(
    context: context,
    isDismissible: isDismissible,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) {
      final Widget? firstButton = btn1Text.isEmpty
          ? null
          : SyriusFilledButton(
              text: btn1Text,
              onPressed: btn1Action,
            );

      final Widget? secondButton = btn2Text.isEmpty
          ? null
          : SyriusFilledButton.color(
              color: btn2Color ?? context.colorScheme.primary,
              text: btn2Text,
              onPressed: btn2Action,
            );

      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: kVerticalSpacer.height!,
            left: 24.0,
            right: 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: context.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (dialogImage != null) dialogImage,
              if (subTitle != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                  ),
                  child: Text(
                    subTitle,
                    style: context.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              if (subTitleWidget != null) subTitleWidget,
              Row(
                children: [
                  if (secondButton != null) Expanded(child: secondButton),
                  Visibility(
                    visible: btn2Text.isNotEmpty,
                    child: const SizedBox(
                      width: 10.0,
                    ),
                  ),
                  if (firstButton != null) Expanded(child: firstButton),
                ],
              ),
            ].addSeparator(kVerticalSpacer),
          ),
        ),
      );
    },
  );
}

Future<dynamic> showModalBottomSheetWithBody({
  required BuildContext context,
  required Widget body,
  String? title,
}) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom +
              kVerticalSpacer.height!,
          left: kHorizontalPagePaddingDimension,
          right: kHorizontalPagePaddingDimension,
        ),
        child: Column(
          children: [
            if (title != null)
              Column(
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleLarge,
                  ),
                  kVerticalSpacer,
                ],
              ),
            body,
          ],
        ),
      ),
    ),
  );
}

Future<dynamic> showTransactionInProgressBottomSheet({
  required BuildContext context,
}) async {
  return showModalBottomSheetWithBody(
    context: context,
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          MdiIcons.check,
          size: 50.0,
        ),
        Text(
          'Your transaction is being processed by the network. '
          'It may take a few minutes for the transaction to confirm.',
          style: context.textTheme.titleSmall?.copyWith(
            color: context.colorScheme.secondary,
          ),
        ),
        kVerticalSpacer,
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: const Text('Continue'),
        ),
      ],
    ),
    title: 'Transaction in progress',
  );
}
