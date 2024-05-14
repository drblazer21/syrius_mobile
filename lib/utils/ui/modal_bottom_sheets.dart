import 'dart:async';

import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

Future showModalBottomSheetWithButtons({
  required BuildContext context,
  Widget? dialogImage,
  required String title,
  String? subTitle,
  String btn1Text = '',
  String btn2Text = '',
  VoidCallback? btn1Action,
  VoidCallback? btn2Action,
  Color? btn1Color,
  Color? btn2Color,
}) {
  return showModalBottomSheet(
    context: context,
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
  Color? backgroundColor,
  Color? barrierColor,
}) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    barrierColor: barrierColor,
    backgroundColor: backgroundColor ?? Colors.black87,
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
