import 'dart:async';
import 'dart:collection';

import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:logging/logging.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class AutoReceiveTxWorker extends BaseBloc<WalletNotification> {
  Queue<Hash> pool = Queue<Hash>();
  HashSet<Hash> processedHashes = HashSet<Hash>();
  bool running = false;

  Future<void> autoReceive() async {
    if (pool.isNotEmpty && !running) {
      running = true;
      final Hash currentHash = pool.first;
      pool.removeFirst();
      try {
        final String toAddress =
            (await zenon.ledger.getAccountBlockByHash(currentHash))!
                .toAddress
                .toString();

        final KeyPair keyPair = await getKeyPairFromAddress(toAddress);

        final AccountBlockTemplate transactionParams =
            AccountBlockTemplate.receive(
          currentHash,
        );
        final AccountBlockTemplate response = await createAccountBlock(
          transactionParams,
          'receive transaction',
          blockSigningKey: keyPair,
          generatingPowCallback: (status) async {
            addEventToPowGeneratingStatusBloc(status);
          },
          waitForRequiredPlasma: true,
          actionType: ActionType.autoReceive,
        );
        _sendSuccessNotification(response, toAddress);
      } on RpcException catch (e, stackTrace) {
        Logger('AutoReceiveTxWorker')
            .log(Level.SEVERE, 'autoReceive', e, stackTrace);

        if (e.message.compareTo('account-block from-block already received') !=
            0) {
          pool.addFirst(currentHash);
        } else {
          _sendErrorNotification(e.toString());
        }
      }
      running = false;
    }
  }

  void _sendErrorNotification(String errorText) {
    sl<NotificationsBloc>().addNotification(
      WalletNotification(
        title: 'Receive transaction failed',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        details: 'Failed to receive the transaction: $errorText',
        type: NotificationType.error,
      ),
    );
  }

  void _sendSuccessNotification(AccountBlockTemplate block, String toAddress) {
    sl<NotificationsBloc>().addNotification(
      WalletNotification(
        title: 'Transaction received on ${getLabel(toAddress)}',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        details: 'Transaction hash: ${block.hash}',
        type: NotificationType.paymentReceived,
      ),
    );
  }

  void addHash(Hash hash) {
    if (!processedHashes.contains(hash)) {
      zenon.stats.syncInfo().then((syncInfo) {
        if (!processedHashes.contains(hash) &&
            (syncInfo.state == SyncState.syncDone ||
                (syncInfo.targetHeight > 0 &&
                    syncInfo.currentHeight > 0 &&
                    (syncInfo.targetHeight - syncInfo.currentHeight) < 3))) {
          pool.add(hash);
          processedHashes.add(hash);
        }
      });
    }
  }
}
