import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:logging/logging.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/services/services.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

int _kHeight = 0;

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

Future<void> initWebSocketClient() async {
  addOnWebSocketConnectedCallback();
  var url = kCurrentNode ?? kDefaultNode;
  bool connected = false;
  try {
    connected = await establishConnectionToNode(url);
  } on WebSocketException catch (e, stackTrace) {
    Logger('NodeUtils').log(
      Level.WARNING,
      'initWebSocketClient',
      e,
      stackTrace,
    );
    url = kDefaultNode;
  } catch (e, stackTrace) {
    Logger('NodeUtils').log(
      Level.SEVERE,
      'initWebSocketClient',
      e,
      stackTrace,
    );
  }
  if (!connected) {
    zenon.wsClient.initialize(
      url,
    );
  }
}

void addOnWebSocketConnectedCallback() {
  zenon.wsClient.addOnConnectionEstablishedCallback(
    (allResponseBroadcaster) async {
      await _getSubscriptionForMomentums();
      await _getSubscriptionForAllAccountEvents();
      await _addUnreceivedTransactions();
      if (kSelectedNetwork == AppNetwork.znn &&
          await secureStorageUtil.containsKey(
            key: kKeyStoreKey,
          )) {
        sl<AutoReceiveTxWorker>().autoReceive();
      }

      Future.delayed(const Duration(seconds: 30))
          .then((value) => sendNodeSyncingNotification());
      _initListenForUnreceivedAccountBlocks(allResponseBroadcaster);
    },
  );
}

Future<void> _addUnreceivedTransactions() async {
  await Future.forEach<String>(
    kDefaultAddressList,
    (addressString) async {
      final Address address = await compute(Address.parse, addressString);

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
  broadcaster.listen(
    (event) async {
      event = event as Map;
      if (event.containsKey('method') &&
          event['method'] == 'ledger.subscription') {
        final Map params = event['params'] as Map;
        final List results = params['result'] as List;
        for (var i = 0; i < results.length; i += 1) {
          final tx = results[i] as Map;
          if (tx.containsKey('toAddress') &&
              kDefaultAddressList.contains(tx['toAddress'])) {
            final hash = Hash.parse(tx['hash'] as String);
            sl<AutoReceiveTxWorker>().addHash(hash);
          }
        }

        final Map result = results.first as Map;
        if (!result.containsKey('blockType') &&
            result['height'] != null &&
            (_kHeight == 0 || result['height'] as int >= _kHeight + 1)) {
          _kHeight = result['height'] as int;

          if (sl<AutoReceiveTxWorker>().pool.isNotEmpty) {
            if (kSelectedNetwork == AppNetwork.znn &&
                await secureStorageUtil.containsKey(
                  key: kKeyStoreKey,
                )) {
              sl<AutoReceiveTxWorker>().autoReceive();
            }
          }
        }
      }
    },
  );
}

Future<void> _getSubscriptionForMomentums() async =>
    await zenon.subscribe.toMomentums();

Future<void> _getSubscriptionForAllAccountEvents() async =>
    await zenon.subscribe.toAllAccountBlocks();

Future<void> loadDbNodes() async {
  if (!Hive.isBoxOpen(kNodesBox)) {
    await Hive.openBox<String>(kNodesBox);
  }
  final Box<String> nodesBox = Hive.box<String>(kNodesBox);
  if (kDbNodes.isNotEmpty) {
    kDbNodes.clear();
  }
  kDbNodes.addAll(nodesBox.values);
  // Handle the case in which some default nodes were deleted
  // so they can't be found in the cache
  final String currentNode = kCurrentNode ?? kDefaultNode;
  if (!kDefaultNodes.contains(currentNode) && !kDbNodes.contains(currentNode)) {
    kDefaultNodes.add(currentNode);
  }
}

Future<void> setNode() async {
  final String savedNode = sharedPrefsService.get<String>(
    kSelectedNodeKey,
    defaultValue: kDefaultNodes.first,
  )!;
  kCurrentNode = savedNode;
}

Future<void> setChainId() async {
  chainId = await getChainId();
}

Future<int> getChainId() async {
  final String chainIdAsString = await secureStorageUtil.read(
    kChainIdKey,
    defaultValue: chainId.toString(),
  );

  return int.parse(chainIdAsString);
}

Future<void> saveChainId(String newChainId) => secureStorageUtil.write(
      key: kChainIdKey,
      value: newChainId,
    );
