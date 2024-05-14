import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:syrius_mobile/utils/extensions/extensions.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/buttons/explorer_button.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class ActivityItem extends StatelessWidget {
  final AccountBlock accountBlock;

  const ActivityItem({
    super.key,
    required this.accountBlock,
  });

  static Color _iconColor = Colors.transparent;
  static Color _backgroundColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    final bool isReceiveBlock =
        BlockUtils.isReceiveBlock(accountBlock.blockType);

    final AccountBlock pairedBlock =
        isReceiveBlock ? accountBlock.pairedAccountBlock! : accountBlock;
    final Address address =
        isReceiveBlock ? pairedBlock.address : accountBlock.toAddress;
    final AccountBlockConfirmationDetail? confirmationDetail =
        pairedBlock.confirmationDetail;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: context.listTileTheme.contentPadding!,
          child: _buildTransactionHeader(context, confirmationDetail),
        ),
        ListTile(
          leading: _buildLeading(accountBlock, pairedBlock),
          subtitle: _buildSubtitle(address, context, accountBlock),
          title: _buildTitle(accountBlock, context),
          trailing: _buildTrailing(
            address: address,
            pairedBlock: pairedBlock,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionHeader(
    BuildContext context,
    AccountBlockConfirmationDetail? accountBlockConfirmationDetail,
  ) {
    String headerText = AppLocalizations.of(context)!.pending;
    if (accountBlockConfirmationDetail != null) {
      final DateTime confirmationDateTime =
          _generateConfirmationDateTime(accountBlockConfirmationDetail);
      headerText = formatTxsDateTime(confirmationDateTime);
    }

    return Text(style: const TextStyle(color: Colors.grey), headerText);
  }

  DateTime _generateConfirmationDateTime(
    AccountBlockConfirmationDetail confirmationDetail,
  ) {
    final int confirmationTimestampSec = confirmationDetail.momentumTimestamp;

    final DateTime confirmationDateTime =
        timestampToDateTime(confirmationTimestampSec * 1000);
    return confirmationDateTime;
  }

  Color _getBlockColor(AccountBlock pairedBlock) {
    Color blockColor = Colors.black;
    switch (pairedBlock.tokenStandard.toString()) {
      case znnTokenStandard:
        blockColor = znnColor;
      case qsrTokenStandard:
        blockColor = qsrColor;
      default:
        blockColor = Colors.pink;
    }
    return blockColor;
  }

  Widget _buildLeading(AccountBlock block, AccountBlock pairedBlock) {
    Widget leadingIcon = const Icon(Icons.question_mark);

    if (BlockUtils.isSendBlock(block.blockType)) {
      _iconColor = _getBlockColor(pairedBlock);
      _backgroundColor = _getBlockColor(pairedBlock).withOpacity(0.2);
      leadingIcon = Icon(
        Icons.arrow_upward,
        color: _iconColor,
        size: 20.0,
      );
    }
    if (BlockUtils.isReceiveBlock(block.blockType)) {
      _iconColor = _getBlockColor(pairedBlock);
      _backgroundColor = _getBlockColor(pairedBlock).withOpacity(0.2);
      leadingIcon = Icon(
        Icons.arrow_downward,
        color: _iconColor,
        size: 20.0,
      );
    }

    final String address = _getTxDescriptionSubtitleAddress(block);

    if (address == plasmaAddress.toString()) {
      _iconColor = qsrColor;
      _backgroundColor = qsrColor.withOpacity(0.2);
      leadingIcon = Icon(
        Icons.flash_on,
        color: _iconColor,
        size: 20.0,
      );
    } else if (address == stakeAddress.toString()) {
      _iconColor = znnColor;
      _backgroundColor = znnColor.withOpacity(0.2);
      leadingIcon = SvgIcon(
        iconFileName: 'staked',
        iconColor: _iconColor,
        size: 20.0,
      );
    } else if (address == pillarAddress.toString()) {
      _iconColor = znnColor;
      _backgroundColor = znnColor.withOpacity(0.2);
      leadingIcon = SvgIcon(
        iconFileName: 'pillar',
        iconColor: _iconColor,
        size: 20.0,
      );
    } else if (address == sentinelAddress.toString()) {
      _iconColor = znnColor;
      _backgroundColor = znnColor.withOpacity(0.2);
      leadingIcon = SvgIcon(
        iconFileName: 'zn_icon',
        iconColor: _iconColor,
        size: 20.0,
      );
    }
    return CircleAvatar(
      backgroundColor: _backgroundColor,
      child: leadingIcon,
    );
  }

  String title(AccountBlock accountBlock) {
    final String address = _getTxDescriptionSubtitleAddress(accountBlock);

    if (address == plasmaAddress.toString()) {
      return 'Fused';
    }
    if (address == sentinelAddress.toString()) {
      return 'Sentinel';
    } else if (address == stakeAddress.toString()) {
      return 'Staked';
    } else if (address == pillarAddress.toString()) {
      return 'Delegated';
    } else {
      return BlockUtils.isSendBlock(accountBlock.blockType)
          ? 'Send'
          : 'Receive';
    }
  }

  Widget _buildSubtitle(
    Address address,
    BuildContext context,
    AccountBlock block,
  ) {
    return _getTxDescriptionSubtitle(
      address: address,
      context: context,
      block: block,
    );
  }

  Widget _buildTitle(AccountBlock block, BuildContext context) {
    return Text(
      title(block),
    );
  }

  Widget _buildLaunchExplorerButton(Hash hash) {
    return ExplorerButton(
      hash: hash.toString(),
      iconColor: _iconColor,
    );
  }

  Widget _buildTrailing({
    required Address address,
    required AccountBlock pairedBlock,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLaunchExplorerButton(pairedBlock.hash),
        Tooltip(
          message: pairedBlock.amount.addDecimals(
            pairedBlock.token?.decimals ?? 0,
          ),
          child: Text(
            '${NumberFormat.compact().format(
              pairedBlock.amount
                  .addDecimals(pairedBlock.token?.decimals ?? 0)
                  .toNum(),
            )}  ${pairedBlock.token?.symbol}',
          ),
        ),
      ],
    );
  }

  Widget _getTxDescriptionSubtitle({
    required Address address,
    required BuildContext context,
    required AccountBlock block,
  }) {
    final String prefix = _getTxDescriptionSubtitlePrefix(context, block);

    return RichText(
      text: TextSpan(
        style: context.defaultListTileSubtitleStyle,
        children: [
          TextSpan(
            text: prefix,
          ),
          TextSpan(
            text: '  ●  ',
            style: TextStyle(
              color: _iconColor,
            ),
          ),
          TextSpan(
            text: shortenWalletAddress(address.toString()),
          ),
        ],
      ),
    );
  }

  String _getTxDescriptionSubtitleAddress(AccountBlock block) {
    return BlockUtils.isSendBlock(block.blockType)
        ? block.toAddress.toString()
        : block.address.toString();
  }

  String _getTxDescriptionSubtitlePrefix(
    BuildContext context,
    AccountBlock block,
  ) {
    final blockType = block.blockType;

    if (BlockUtils.isSendBlock(blockType)) {
      return AppLocalizations.of(context)!.to;
    } else if (BlockUtils.isReceiveBlock(blockType)) {
      return AppLocalizations.of(context)!.from;
    } else {
      return AppLocalizations.of(context)!.beneficiaryAddress;
    }
  }
}
