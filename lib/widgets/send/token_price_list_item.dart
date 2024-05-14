import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/extensions/extensions.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class TokenPriceListItem extends StatelessWidget {
  final String iconFileName;
  final bool isSelected;
  final Token token;
  final BigInt tokenAmount;
  final VoidCallback onTap;

  const TokenPriceListItem({
    super.key,
    required this.iconFileName,
    required this.token,
    required this.tokenAmount,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(16.0);
    final Color iconColor = getTokenColor(token);
    final Color bgColor = getTokenColor(token).withOpacity(0.2);
    final Color selectedTileColor = getTokenColor(token).withOpacity(0.1);
    final String tokenName = token.symbol;

    final bool isHideBalance = sharedPrefsService.get<bool>(
      kIsHideBalanceKey,
      defaultValue: false,
    )!;

    return ListTile(
      leading: _buildLeading(bgColor, iconColor),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: selectedTileColor,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      title: _buildTitle(tokenName),
      trailing: _buildTrailing(isHideBalance, context),
    );
  }

  Text _buildTrailing(bool isHideBalance, BuildContext context) {
    return Text(
      isHideBalance
          ? "••••••"
          : NumberFormat()
              .format(tokenAmount.addDecimals(coinDecimals).toNum()),
      style: context.textTheme.labelLarge,
    );
  }

  Text _buildTitle(String tokenName) {
    return Text(
      ' $tokenName',
    );
  }

  CircleAvatar _buildLeading(Color bgColor, Color iconColor) {
    return CircleAvatar(
      backgroundColor: bgColor,
      child: SvgIcon(
        iconFileName: iconFileName,
        iconColor: iconColor,
      ),
    );
  }
}
