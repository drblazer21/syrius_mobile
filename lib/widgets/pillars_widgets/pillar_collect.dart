import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class PillarCollect extends StatefulWidget {
  final PillarRewardsHistoryBloc pillarRewardsHistoryBloc;

  const PillarCollect({
    required this.pillarRewardsHistoryBloc,
    super.key,
  });

  @override
  State<PillarCollect> createState() => _PillarCollectState();
}

class _PillarCollectState extends State<PillarCollect> {
  final _pillarCollectRewardsBloc = PillarUncollectedRewardsBloc();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UncollectedReward?>(
      stream: _pillarCollectRewardsBloc.stream,
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          return SyriusErrorWidget(snapshot.hasError);
        } else if (snapshot.hasData) {
          Logger('_PillarCollectState').log(Level.INFO, snapshot.data);
          if (snapshot.data!.znnAmount > BigInt.zero) {
            return _getCollectButton(active: true);
          }
          return _getCollectButton();
        }
        return const SyriusLoadingWidget(size: 25.0, strokeWidth: 2.0);
      },
    );
  }

  @override
  void dispose() {
    _pillarCollectRewardsBloc.dispose();
    super.dispose();
  }

  Widget _getCollectButton({bool active = false}) {
    return SyriusFilledButton(
      onPressed: active ? _onCollectPressed : null,
      text: AppLocalizations.of(context)!.collect,
    );
  }

  Future<void> _onCollectPressed() async {
    try {
      _sendCreatedBlockNotification();
      createAccountBlock(
        zenon.embedded.pillar.collectReward(),
        'collect Pillar rewards',
        waitForRequiredPlasma: true,
        actionType: ActionType.delegate,
      ).then(
        (response) async {
          await Future.delayed(kDelayAfterBlockCreationCall);
          if (mounted) {
            _pillarCollectRewardsBloc.updateStream();
          }
          widget.pillarRewardsHistoryBloc.updateStream();
        },
      );
    } catch (e, stackTrace) {
      sendNotificationError(
        AppLocalizations.of(context)!.pillarDelegationCollectError,
        e,
      );
      Logger('PillarCollect').log(
        Level.SEVERE,
        '_onCollectPressed',
        e,
        stackTrace,
      );
    } finally {}
  }

  void _sendCreatedBlockNotification() {
    sl.get<NotificationsBloc>().addNotification(
          WalletNotification(
            title: 'Sent collect account-block',
            timestamp: DateTime.now().millisecondsSinceEpoch,
            details:
                'Created account-block for receiving the delegation rewards',
            type: NotificationType.paymentSent,
          ),
        );
  }
}
