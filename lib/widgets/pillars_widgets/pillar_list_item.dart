import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:syrius_mobile/utils/extensions/extensions.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class PillarListItem extends StatelessWidget {
  final PillarInfo pillarInfo;
  final DelegationInfo? delegationInfo;
  final int count;

  const PillarListItem({
    required this.pillarInfo,
    required this.delegationInfo,
    required this.count,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildLeading(context),
      subtitle: _buildSubtitle(context),
      title: _buildTitle(),
      trailing: _buildDelegateButton(context),
    );
  }

  int _getMomentumsPercentage(PillarInfo pillarInfo) {
    final double percentage =
        pillarInfo.producedMomentums / pillarInfo.expectedMomentums * 100;
    if (percentage.isNaN) {
      return 0;
    }
    return percentage.round();
  }

  String _getWeight() {
    return pillarInfo.weight.addDecimals(
      kZnnCoin.decimals,
    );
  }

  bool _isPillarItemDelegatedTo() {
    if (delegationInfo != null) {
      if (delegationInfo!.name == pillarInfo.name) {
        return true;
      }
    }
    return false;
  }

  Widget _buildSubtitle(BuildContext context) {
    final String formattedAmount = NumberFormat.compact().format(
      _getWeight().toNum(),
    );

    final String prefix = '$formattedAmount ${kZnnCoin.symbol}';

    final String suffix = "${_getMomentumsPercentage(pillarInfo)}%";

    return RichText(
      text: TextSpan(
        style: context.defaultListTileSubtitleStyle,
        children: [
          TextSpan(
            text: prefix,
          ),
          const TextSpan(
            text: '  ●  ',
            style: TextStyle(
              color: znnColor,
            ),
          ),
          TextSpan(
            text: suffix,
          ),
        ],
      ),
    );
  }

  Text _buildTitle() {
    return Text(
      pillarInfo.name,
    );
  }

  Widget _buildLeading(BuildContext context) {
    final Color backgroundColor = _isPillarItemDelegatedTo()
        ? context.colorScheme.primary
        : context.colorScheme.primaryContainer;

    final Color iconColor = _isPillarItemDelegatedTo()
        ? context.colorScheme.onPrimary
        : context.colorScheme.onPrimaryContainer;

    return CircleAvatar(
      backgroundColor: backgroundColor,
      child: SvgIcon(
        iconFileName: 'pillar',
        iconColor: iconColor,
        size: 20.0,
      ),
    );
  }

  Row _buildDelegateButton(BuildContext context) {
    final text = Text(
      _isPillarItemDelegatedTo()
          ? AppLocalizations.of(context)!.undelegate
          : AppLocalizations.of(context)!.delegateAction,
      style: context.textTheme.titleMedium,
    );

    const icon = Icon(
      Icons.chevron_right_rounded,
      size: 30.0,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        text,
        icon,
      ],
    );
  }
}
