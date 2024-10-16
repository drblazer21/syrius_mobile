import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class AcceleratorProjectDetails extends StatelessWidget {
  final Address? owner;
  final Hash? hash;
  final int? creationTimestamp;
  final AcceleratorProjectStatus? acceleratorProjectStatus;

  const AcceleratorProjectDetails({
    this.owner,
    this.hash,
    this.creationTimestamp,
    this.acceleratorProjectStatus,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];

    if (owner != null) {
      children.add(
        Text(
          _getOwnerDetails(),
          style: Theme.of(context).inputDecorationTheme.hintStyle,
        ),
      );
    }

    if (hash != null) {
      children.add(
        Text(
          'ID ${hash!.toShortString()}',
          style: Theme.of(context).inputDecorationTheme.hintStyle,
        ),
      );
    }

    if (creationTimestamp != null) {
      children.add(
        Text(
          'Created ${_formatData(creationTimestamp! * 1000)}',
          style: Theme.of(context).inputDecorationTheme.hintStyle,
        ),
      );
      if (acceleratorProjectStatus != null &&
          acceleratorProjectStatus == AcceleratorProjectStatus.voting) {
        children.add(
          Text(
            _getTimeUntilVotingCloses(),
            style: Theme.of(context).inputDecorationTheme.hintStyle,
          ),
        );
      }
    }

    return Wrap(
      spacing: 5.0,
      children: children.zip(
        List.generate(
          children.length - 1,
          (index) => Text(
            '●',
            style: Theme.of(context).inputDecorationTheme.hintStyle,
          ),
        ),
      ),
    );
  }

  String _formatData(int transactionMillis) {
    final int currentMillis = DateTime.now().millisecondsSinceEpoch;
    if (currentMillis - transactionMillis <=
        const Duration(
          days: 1,
        ).inMilliseconds) {
      return _formatDataShort(currentMillis - transactionMillis);
    }
    return formatTxsDateTime(
      DateTime.fromMillisecondsSinceEpoch(transactionMillis),
    );
  }

  String _formatDataShort(int i) {
    final Duration duration = Duration(milliseconds: i);
    if (duration.inHours > 0) {
      return '${duration.inHours} h ago';
    }
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes} min ago';
    }
    return '${duration.inSeconds} s ago';
  }

  String _getTimeUntilVotingCloses() {
    const String prefix = 'Voting closes in ';
    String suffix = '';
    final DateTime creationDate =
        DateTime.fromMillisecondsSinceEpoch((creationTimestamp ?? 0) * 1000);
    final DateTime votingEnds = creationDate.add(kProjectVotingPeriod);
    final Duration difference = votingEnds.difference(DateTime.now());
    if (difference.isNegative) {
      return 'Voting closed';
    }
    if (difference.inDays > 0) {
      suffix = '${difference.inDays} days';
    } else if (difference.inHours > 0) {
      suffix = '${difference.inHours} h';
    } else if (difference.inMinutes > 0) {
      suffix = '${difference.inMinutes} min';
    } else {
      suffix = '${difference.inSeconds} s';
    }
    return prefix + suffix;
  }

  String _getOwnerDetails() {
    String address = owner!.toShortString();
    for (final appAddress in addressList) {
      if (appAddress.hex == owner.toString()) {
        address = appAddress.label;
      }
    }
    return 'Owner $address';
  }
}
