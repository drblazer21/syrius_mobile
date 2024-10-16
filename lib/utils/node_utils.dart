import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

final List<String> unreceivedAccountBlocksSubscriptionIds = [];

Future<bool> establishConnectionToNode(String url) async {
  try {
    return await zenon.wsClient.initialize(
      url,
      retry: false,
    );
  } catch (e, stackTrace) {
    Logger('NodeUtils').log(
      Level.SEVERE,
      'establishConnectionToNode',
      e,
      stackTrace,
    );
    return false;
  }
}

Future<void> initZnnWebSocketClient({
  required String url,
}) async {
  try {
    final bool connected = await establishConnectionToNode(url);
    if (connected) {
      addOnWebSocketConnectedCallback();
      handleUnreceivedAccountBlocks();
      sl.get<BalanceBloc>().get();
      Future.delayed(const Duration(seconds: 30))
          .then((value) => sendNodeSyncingNotification());
    } else {
      sendNotificationError(
        'Connection to websocket failed',
        'Connection to websocket failed',
      );
    }
  } on WebSocketException catch (e, stackTrace) {
    Logger('NodeUtils').log(
      Level.WARNING,
      'initWebSocketClient',
      e,
      stackTrace,
    );
  } catch (e, stackTrace) {
    Logger('NodeUtils').log(
      Level.SEVERE,
      'initWebSocketClient',
      e,
      stackTrace,
    );
  }
}

void handleUnreceivedAccountBlocks() {
  // The list has to be cleared, in case it contains IDs from another session
  if (unreceivedAccountBlocksSubscriptionIds.isNotEmpty) {
    unreceivedAccountBlocksSubscriptionIds.clear();
  }
  subscribeToUnreceivedAccountBlocks();
  addUnreceivedTransactions();
}

Future<void> subscribeToUnreceivedAccountBlocks() async {
  for (final AppAddress appAddress in kDefaultAddressList) {
    subscribeToUnreceivedAccountBlocksByAddress(
      address: appAddress.toZnnAddress(),
    );
  }
}

Future<void> subscribeToUnreceivedAccountBlocksByAddress({
  required Address address,
}) async {
  final String? subscriptionId =
      await zenon.subscribe.toUnreceivedAccountBlocksByAddress(address);

  if (subscriptionId != null) {
    unreceivedAccountBlocksSubscriptionIds.add(subscriptionId);
  }
}

void addOnWebSocketConnectedCallback() {
  zenon.wsClient.addOnConnectionEstablishedCallback(
    (allResponseBroadcaster) async {
      _initListenForUnreceivedAccountBlocks(allResponseBroadcaster);
    },
  );
}

Future<void> addUnreceivedTransactions() async {
  await Future.forEach<AppAddress>(
    kDefaultAddressList,
    (appAddress) async {
      final Address address = appAddress.toZnnAddress();

      return addUnreceivedTransactionsByAddress(address);
    },
  );
}

Future<void> addUnreceivedTransactionsByAddress(
  Address address,
) async {
  final List<AccountBlock> unreceivedBlocks =
      (await zenon.ledger.getUnreceivedBlocksByAddress(
    address,
  ))
          .list!;

  if (unreceivedBlocks.isNotEmpty) {
    for (final AccountBlock unreceivedBlock in unreceivedBlocks) {
      sl<AutoReceiveTxWorker>().addHash(unreceivedBlock.hash);
    }
  }
}

void _initListenForUnreceivedAccountBlocks(Stream broadcaster) {
  broadcaster
      .map<WsEvent>((map) => WsEvent.fromJson(map as Map<String, dynamic>))
      .listen(
    (event) async {
      final String? subscriptionId = event.params?.subscription;
      final bool isUnreceivedAccountBlockEvent =
          unreceivedAccountBlocksSubscriptionIds.contains(subscriptionId);
      if (isUnreceivedAccountBlockEvent) {
        for (final WsResult result in event.params!.results) {
          if (BlockChain.nom.isSelected &&
              await secureStorageUtil.containsKey(
                key: kKeyStoreKey,
              )) {
            final Hash hash = Hash.parse(result.hash);
            sl<AutoReceiveTxWorker>().addHash(hash);
          }
        }
      }
    },
  );
}
