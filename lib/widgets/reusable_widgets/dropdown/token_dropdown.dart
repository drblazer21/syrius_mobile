import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/icons/svg_icon.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class TokenDropdown extends StatelessWidget {
  final Token token;
  final double imageSize;
  final VoidCallback? onTap;

  const TokenDropdown({
    super.key,
    required this.token,
    this.imageSize = 32.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: context.colorScheme.scrim,
        disabledBackgroundColor: context.colorScheme.scrim,
        minimumSize: Size(10.0, imageSize),
        padding: const EdgeInsets.all(8.0),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLeading(token),
          kIconAndTextHorizontalSpacer,
          Text(
            token.symbol,
            style: context.textTheme.bodySmall,
          ),
          if (onTap != null)
            const Icon(
              Icons.keyboard_arrow_down_rounded,
            ),
        ],
      ),
    );
  }

  CircleAvatar _buildLeading(Token token) {
    final Color iconColor = getTokenColor(token);
    final Color bgColor = getTokenColor(token).withOpacity(0.2);
    return CircleAvatar(
      radius: 15.0,
      backgroundColor: bgColor,
      child: SvgIcon(
        size: 10.0,
        iconFileName: 'zn_icon',
        iconColor: iconColor,
      ),
    );
  }
}
