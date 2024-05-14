import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class StakeCollect extends StatefulWidget {
  const StakeCollect({
    super.key,
  });

  @override
  State<StakeCollect> createState() => _StakeCollectState();
}

class _StakeCollectState extends State<StakeCollect> {
  final StakingUncollectedRewardsBloc _stakingUncollectedRewardsBloc =
      StakingUncollectedRewardsBloc();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UncollectedReward?>(
      stream: _stakingUncollectedRewardsBloc.stream,
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          return SyriusErrorWidget(snapshot.hasError);
        } else if (snapshot.hasData) {
          Logger('StakeCollect').log(Level.INFO, snapshot.data);
          if (snapshot.data!.qsrAmount > BigInt.zero) {
            return _getCollectButton(active: true);
          }
          return _getCollectButton();
        }
        return const SyriusLoadingWidget(size: 25.0, strokeWidth: 2.0);
      },
    );
  }

  Widget _getCollectButton({bool active = false}) {
    return SyriusFilledButton.color(
      color: qsrColor,
      onPressed: active ? _onCollectPressed : null,
      text: AppLocalizations.of(context)!.collect,
    );
  }

  Future<void> _onCollectPressed() async {
    try {
      _sendCreatedBlockNotification();
      createAccountBlock(
        zenon.embedded.stake.collectReward(),
        'collect staking rewards',
        waitForRequiredPlasma: true,
        actionType: ActionType.stake,
      ).then(
        (response) async {
          await Future.delayed(kDelayAfterBlockCreationCall);
          _stakingUncollectedRewardsBloc.updateStream();
        },
      );
    } catch (e, stackTrace) {
      Logger('StakeCollect').log(
        Level.SEVERE,
        '_onCollectPressed',
        e,
        stackTrace,
      );
      sendNotificationError(
        AppLocalizations.of(context)!.stakingRewardsError,
        e,
      );
    }
  }

  void _sendCreatedBlockNotification() {
    sl.get<NotificationsBloc>().addNotification(
          WalletNotification(
            title: 'Sent collect account-block',
            timestamp: DateTime.now().millisecondsSinceEpoch,
            details: 'Created account-block for receiving the staking rewards',
            type: NotificationType.paymentSent,
          ),
        );
  }
}
