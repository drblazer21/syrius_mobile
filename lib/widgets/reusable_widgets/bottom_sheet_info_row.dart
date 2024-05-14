import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';

class BottomSheetInfoRow extends Row {
  BottomSheetInfoRow({
    required BuildContext context,
    required String leftContent,
    required String rightContent,
  }) : super(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              leftContent,
              style: context.textTheme.titleSmall,
            ),
            Text(
              rightContent,
            ),
          ],
        );
}
