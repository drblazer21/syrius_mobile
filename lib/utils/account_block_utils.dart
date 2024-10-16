import 'dart:async';

import 'package:logging/logging.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

final Map<String, Future<void>?> _kIsRunningByAddress = {};

enum ActionType {
  sendFund,
  delegate,
  stake,
  plasma,
  sentinel,
  autoReceive,
  voteForProject,
}

Future<AccountBlockTemplate> createAccountBlock(
  AccountBlockTemplate transactionParams,
  String purposeOfGeneratingPlasma, {
  String? blockSigningAddress,
  void Function(PowStatus)? generatingPowCallback,
  bool waitForRequiredPlasma = false,
  ActionType? actionType,
}) async {
  final SyncInfo syncInfo = await zenon.stats.syncInfo();
  final bool nodeIsSynced = syncInfo.state == SyncState.syncDone ||
      (syncInfo.targetHeight > 0 &&
          syncInfo.currentHeight > 0 &&
          (syncInfo.targetHeight - syncInfo.currentHeight) < 20);
  if (nodeIsSynced) {
    final KeyPair blockSigningKeyPair = await getKeyPairFromAddress(
      blockSigningAddress ?? kSelectedAddress!.hex,
    );
    final Address address = await blockSigningKeyPair.address;
    Logger('AccountBlockUtils')
        .log(Level.INFO, 'createAccountBlock', purposeOfGeneratingPlasma);
    try {
      // Wait until the lock is unused.
      //
      // A while-loop is required since there is the case when a lot of routines are waiting, and only one should move
      // forward when the main routine finishes.
      while (_kIsRunningByAddress.containsKey(address.toString()) &&
          _kIsRunningByAddress[address.toString()] != null) {
        await _kIsRunningByAddress[address.toString()];
      }

      // Acquire lock
      Completer<void> completer;
      completer = Completer<void>();
      _kIsRunningByAddress[address.toString()] = completer.future;

      final bool needPlasma = await zenon.requiresPoW(
        transactionParams,
        blockSigningKey: blockSigningKeyPair,
      );

      if (needPlasma) {
        sl
            .get<NotificationsService>()
            .sendPlasmaNotification(purposeOfGeneratingPlasma);
      }
      final AccountBlockTemplate response = await zenon.send(
        transactionParams,
        currentKeyPair: blockSigningKeyPair,
        generatingPowCallback: (status) async {
          addEventToPowGeneratingStatusBloc(status);
        },
        waitForRequiredPlasma: waitForRequiredPlasma,
      );
      refreshBalanceAndTx();

      // Release the lock after 1 second, asynchronously.
      //
      // This will give the node enough time so that it'll process the transaction before we start creating a new one.
      // This is a problem when we create 2 transactions from the same address without requiring PoW.
      // If we release the lock too early, zenon.send will autofill the AccountBlockTemplate with an old value of
      // ledger.getFrontierAccountBlock, since the node did not had enough time to process the current transaction.
      Future.delayed(const Duration(seconds: 1)).then((_) {
        completer.complete();
        _kIsRunningByAddress[address.toString()] = null;
      });

      return response;
    } catch (e, stackTrace) {
      Logger('AccountBlockUtils')
          .log(Level.SEVERE, 'createAccountBlock', e, stackTrace);
      _kIsRunningByAddress[address.toString()] = null;
      sendNotificationError('Account-block creation failed', e);
      rethrow;
    }
  } else {
    throw 'Node is not synced';
  }
}

void addEventToPowGeneratingStatusBloc(PowStatus event) =>
    sl.get<PowGeneratingStatusBloc>().addEvent(event);
