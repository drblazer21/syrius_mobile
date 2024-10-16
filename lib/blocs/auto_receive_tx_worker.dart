import 'dart:async';
import 'dart:collection';

import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:logging/logging.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/database/database.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class AutoReceiveTxWorker extends BaseBloc<WalletNotification> with RefreshBlocMixin {

  AutoReceiveTxWorker() {
    listenToWsRestart(() {
      handleUnreceivedAccountBlocks();
    });

  }

  final Logger _logger = Logger('AutoReceiveTxWorker');
  Queue<Hash> pool = Queue<Hash>();
  HashSet<Hash> hashesAddedToThePool = HashSet<Hash>();
  bool running = false;

  Future<void> _autoReceive() async {
    if (pool.isNotEmpty && !running) {
      running = true;
      while (pool.isNotEmpty) {
        _logger.info('Auto receive loop started');
        final Hash currentHash = pool.first;
        pool.removeFirst();
        await _processHash(currentHash);
      }
      running = false;
      _logger.info('Auto receive loop ended');
    }
  }

  Future<void> _processHash(Hash currentHash) async {
    try {
      final AccountBlock? accountBlock =
          await zenon.ledger.getAccountBlockByHash(currentHash);

      final String toAddress = accountBlock!.toAddress.toString();

      final AccountBlockTemplate transactionParams =
          AccountBlockTemplate.receive(
        currentHash,
      );
      final AccountBlockTemplate response = await createAccountBlock(
        transactionParams,
        'receive transaction',
        blockSigningAddress: toAddress,
        generatingPowCallback: (status) async {
          addEventToPowGeneratingStatusBloc(status);
        },
        waitForRequiredPlasma: true,
        actionType: ActionType.autoReceive,
      );
      _logger.info('Processed hash: $currentHash');
      _sendSuccessNotification(response, toAddress);
    } on RpcException catch (e, stackTrace) {
      _logger.severe('error', e, stackTrace);

      if (e.message.compareTo('account-block from-block already received') !=
          0) {
        pool.addFirst(currentHash);
      } else {
        _sendErrorNotification(e.toString());
      }
    }
  }

  void _sendErrorNotification(String errorText) {
    sl.get<NotificationsService>().addNotification(
          WalletNotificationsCompanion.insert(
            title: 'Receive transaction failed',
            details: 'Failed to receive the transaction: $errorText',
            type: NotificationType.error,
          ),
        );
  }

  void _sendSuccessNotification(AccountBlockTemplate block, String toAddress) {
    sl.get<NotificationsService>().addNotification(
          WalletNotificationsCompanion.insert(
            title: 'Transaction received on ${getLabel(toAddress)}',
            details: 'Transaction hash: ${block.hash}',
            type: NotificationType.paymentReceived,
          ),
        );
  }

  void addHash(Hash hash) {
    if (!hashesAddedToThePool.contains(hash)) {
      zenon.stats.syncInfo().then((syncInfo) {
        if (!hashesAddedToThePool.contains(hash) &&
            (syncInfo.state == SyncState.syncDone ||
                (syncInfo.targetHeight > 0 &&
                    syncInfo.currentHeight > 0 &&
                    (syncInfo.targetHeight - syncInfo.currentHeight) < 3))) {
          pool.add(hash);
          _logger.info('Hash added to the poll: $hash');
          hashesAddedToThePool.add(hash);
          _autoReceive();
        }
      });
    }
  }
}
