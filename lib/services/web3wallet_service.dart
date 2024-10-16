import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/services/services.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/utils/wallet_connect/chain_metadata.dart';
import 'package:syrius_mobile/utils/wallet_connect/connection_widget_builder.dart';
import 'package:syrius_mobile/utils/wallet_connect/eip155_supported_methods.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart'
    hide Level, Logger;

class Web3WalletService extends IWeb3WalletService {
  late Web3Wallet? _web3Wallet;

  /// The list of requests from the dapp
  /// Potential types include, but aren't limited to:
  /// [SessionProposalEvent], [AuthRequest]
  @override
  ValueNotifier<List<PairingInfo>> pairings =
      ValueNotifier<List<PairingInfo>>([]);
  @override
  ValueNotifier<List<SessionData>> sessions =
      ValueNotifier<List<SessionData>>([]);
  @override
  ValueNotifier<List<StoredCacao>> auth = ValueNotifier<List<StoredCacao>>([]);

  final List<int> _idSessionsApproved = [];

  @override
  Future<void> create() async {
    if (kWcProjectId.isNotEmpty) {
      _web3Wallet = Web3Wallet(
        core: Core(
          projectId: kWcProjectId,
        ),
        metadata: const PairingMetadata(
          name: 's y r i u s',
          description: 'A wallet for interacting with Zenon Network',
          url: 'https://zenon.network',
          icons: [
            'https://raw.githubusercontent.com/zenon-network/syrius/master/macos/Runner/Assets.xcassets/AppIcon.appiconset/Icon-MacOS-512x512%402x.png',
          ],
        ),
      );

      // Setup our listeners
      _web3Wallet!.core.relayClient.onRelayClientConnect
          .subscribe(_onRelayClientConnect);
      _web3Wallet!.core.relayClient.onRelayClientDisconnect
          .subscribe(_onRelayClientDisconnect);
      _web3Wallet!.core.relayClient.onRelayClientError
          .subscribe(_onRelayClientError);

      _web3Wallet!.core.pairing.onPairingCreate.subscribe(_onPairingCreate);
      _web3Wallet!.core.pairing.onPairingActivate.subscribe(_onPairingActivate);
      _web3Wallet!.core.pairing.onPairingPing.subscribe(_onPairingPing);
      _web3Wallet!.core.pairing.onPairingInvalid.subscribe(_onPairingInvalid);
      _web3Wallet!.core.pairing.onPairingDelete.subscribe(_onPairingDelete);

      _web3Wallet!.pairings.onSync.subscribe(_onPairingsSync);
      _web3Wallet!.sessions.onSync.subscribe(_onSessionsSync);

      _web3Wallet!.onSessionProposal.subscribe(_onSessionProposal);
      _web3Wallet!.onSessionConnect.subscribe(_onSessionConnect);
      _web3Wallet!.onSessionProposalError.subscribe(_onSessionProposalError);
      _web3Wallet!.onSessionDelete.subscribe(_onSessionDelete);
      _web3Wallet!.onSessionAuthRequest.subscribe(_onSessionAuthRequest);
      _web3Wallet!.onAuthRequest.subscribe(_onAuthRequest);
    } else {
      Logger('WalletConnectService').log(Level.INFO, 'kWcProjectId missing');
    }
  }

  @override
  Future<void> init() async {
    // Await the initialization of the web3wallet
    Logger('WalletConnectService').log(Level.INFO, 'initialization');
    await _web3Wallet!.init();

    pairings.value = _web3Wallet!.pairings.getAll();
    sessions.value = _web3Wallet!.sessions.getAll();
    auth.value = _web3Wallet!.completeRequests.getAll();
  }

  @override
  FutureOr onDispose() {
    _web3Wallet!.core.relayClient.onRelayClientConnect
        .unsubscribe(_onRelayClientConnect);
    _web3Wallet!.core.relayClient.onRelayClientDisconnect
        .unsubscribe(_onRelayClientDisconnect);
    _web3Wallet!.core.relayClient.onRelayClientError
        .unsubscribe(_onRelayClientError);

    _web3Wallet!.core.pairing.onPairingCreate.unsubscribe(_onPairingCreate);
    _web3Wallet!.core.pairing.onPairingActivate.unsubscribe(_onPairingActivate);
    _web3Wallet!.core.pairing.onPairingPing.unsubscribe(_onPairingPing);
    _web3Wallet!.core.pairing.onPairingInvalid.unsubscribe(_onPairingInvalid);
    _web3Wallet!.core.pairing.onPairingDelete.unsubscribe(_onPairingDelete);

    _web3Wallet!.pairings.onSync.unsubscribe(_onPairingsSync);
    _web3Wallet!.sessions.onSync.unsubscribe(_onSessionsSync);

    _web3Wallet!.onSessionProposal.unsubscribe(_onSessionProposal);
    _web3Wallet!.onSessionConnect.unsubscribe(_onSessionConnect);
    _web3Wallet!.onSessionProposalError.unsubscribe(_onSessionProposalError);
    _web3Wallet!.onSessionDelete.unsubscribe(_onSessionDelete);
    _web3Wallet!.onSessionAuthRequest.unsubscribe(_onSessionAuthRequest);
    _web3Wallet!.onAuthRequest.unsubscribe(_onAuthRequest);

    pairings.dispose();
    sessions.dispose();
    auth.dispose();
  }

  @override
  Web3Wallet getWeb3Wallet() {
    return _web3Wallet!;
  }

  @override
  Future<PairingInfo> pair(Uri uri) {
    return _web3Wallet!.pair(uri: uri);
  }

  @override
  Future<void> activatePairing({
    required String topic,
  }) {
    return _web3Wallet!.core.pairing.activate(
      topic: topic,
    );
  }

  @override
  Future<void> deactivatePairing({
    required String topic,
  }) async {
    try {
      _web3Wallet!.core.pairing.disconnect(topic: topic);
      _idSessionsApproved.clear();
    } on WalletConnectError catch (e) {
      // technically look for WalletConnectError 6 : Expired. to consider it a warning
      Logger('WalletConnectService')
          .log(Level.INFO, 'deactivatePairing ${e.code} : ${e.message}');
    } catch (e, s) {
      // Catch anything else (not just Exceptions) and log stack
      Logger('WalletConnectService').log(
        Level.INFO,
        'disconnectAllParings - Unexpected error: $e, topic $topic\n$s',
      );
    }
  }

  @override
  Map<String, SessionData> getSessionsForPairing(String pairingTopic) {
    return _web3Wallet!.getSessionsForPairing(
      pairingTopic: pairingTopic,
    );
  }

  @override
  Future<void> emitAddressChangeEvent(String newAddress) {
    return _emitEventPairedDApps(
      changeName: 'addressChange',
      newValue: newAddress,
    );
  }

  @override
  Future<void> emitChainIdChangeEvent(String newChainId) {
    return _emitEventPairedDApps(
      changeName: 'chainIdChange',
      newValue: newChainId,
    );
  }

  @override
  Future<void> disconnectSessions() async {
    Logger('WalletConnectService')
        .log(Level.INFO, 'disconnectSessions triggered');
    for (int i = 0; i < pairings.value.length; i++) {
      await _web3Wallet!.disconnectSession(
        topic: pairings.value[i].topic,
        reason: Errors.getSdkError(Errors.USER_DISCONNECTED),
      );
    }
    _idSessionsApproved.clear();
  }

  @override
  Future<void> disconnectSession({required String topic}) async {
    Logger('WalletConnectService')
        .log(Level.INFO, 'disconnectSession triggered', topic);
    _web3Wallet!.disconnectSession(
      topic: topic,
      reason: Errors.getSdkError(Errors.USER_DISCONNECTED),
    );
  }

  @override
  Map<String, SessionData> getActiveSessions() {
    Logger('WalletConnectService')
        .log(Level.INFO, 'getActiveSessions triggered');
    return _web3Wallet!.getActiveSessions();
  }

  Future<void> _onRelayClientConnect(var args) async {
    Logger('WalletConnectService')
        .log(Level.INFO, '_onRelayClientConnect triggered', args.toString());
  }

  Future<void> _onRelayClientDisconnect(var args) async {
    Logger('WalletConnectService')
        .log(Level.INFO, '_onRelayClientDisconnect triggered', args.toString());
  }

  Future<void> _onRelayClientError(var args) async {
    Logger('WalletConnectService')
        .log(Level.INFO, '_onRelayClientError triggered', args.toString());
  }

  Future<void> _onSessionsSync(StoreSyncEvent? args) async {
    if (args != null) {
      Logger('WalletConnectService')
          .log(Level.INFO, '_onSessionsSync triggered', args.toString());
      sessions.value = _web3Wallet!.sessions.getAll();
    }
  }

  Future<void> _onPairingCreate(PairingEvent? args) async {
    Logger('WalletConnectService')
        .log(Level.INFO, 'onPairingCreate triggered', args.toString());
    sl.get<WalletConnectPairingsBloc>().refreshResults();
  }

  Future<void> _onPairingActivate(PairingActivateEvent? args) async {
    Logger('WalletConnectService')
        .log(Level.INFO, '_onPairingActivate triggered', args.toString());
    sl.get<WalletConnectPairingsBloc>().refreshResults();
  }

  Future<void> _onPairingPing(PairingEvent? args) async {
    Logger('WalletConnectService')
        .log(Level.INFO, '_onPairingPing triggered', args.toString());
  }

  void _onPairingInvalid(PairingInvalidEvent? args) {
    Logger('WalletConnectService')
        .log(Level.INFO, 'onPairingInvalid triggered', args.toString());
  }

  Future<void> _onPairingDelete(PairingEvent? args) async {
    Logger('WalletConnectService')
        .log(Level.INFO, '_onPairingDelete triggered', args.toString());
  }

  Future<void> _onPairingsSync(StoreSyncEvent? args) async {
    if (args != null) {
      Logger('WalletConnectService')
          .log(Level.INFO, '_onPairingsSync triggered', args.toString());
      pairings.value = _web3Wallet!.pairings.getAll();
    }
  }

  void _onSessionDelete(SessionDelete? args) {
    Logger('WalletConnectService')
        .log(Level.INFO, '_onSessionDelete triggered', args.toString());
    sl.get<WalletConnectSessionsBloc>().refreshResults();
  }

  void _onSessionProposalError(SessionProposalErrorEvent? args) {
    Logger('WalletConnectService')
        .log(Level.INFO, '_onSessionProposalError triggered', args.toString());
    sl.get<WalletConnectPairingsBloc>().refreshResults();
  }

  Future<void> _onSessionProposal(SessionProposalEvent? event) async {
    Logger('WalletConnectService')
        .log(Level.INFO, '_onSessionProposal triggered', event.toString());

    if (event != null) {
      Logger('WalletConnectService')
          .log(Level.INFO, '_onSessionProposal event', event.params.toJson());

      final dAppMetadata = event.params.proposer.metadata;

      final views = ConnectionWidgetBuilder().buildFromRequiredNamespaces(
        event.params.generatedNamespaces!,
      );

      final actionWasAccepted = await showDialogWithNoAndYesOptions<bool>(
        context: navState.currentContext!,
        title: 'Approve session',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to '
                'connect to ${dAppMetadata.name} ?'),
            Image(
              image: NetworkImage(dAppMetadata.icons.first),
              height: 100.0,
              fit: BoxFit.fitHeight,
            ),
            Text(dAppMetadata.description),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dAppMetadata.name,
                  style: const TextStyle(
                    color: znnColor,
                  ),
                ),
                LinkIcon(
                  url: dAppMetadata.url,
                ),
              ],
            ),
            ...views,
          ],
        ),
        onYesButtonPressed: () async {},
        onNoButtonPressed: () async {},
      );

      if (actionWasAccepted ?? false) {
        if (!_idSessionsApproved.contains(event.id)) {
          _idSessionsApproved.add(event.id);
          try {
            await _approveSession(event: event);
            _sendSuccessfullyApprovedSessionNotification(dAppMetadata);
          } catch (e, stackTrace) {
            sendNotificationError(
              'WalletConnect session approval failed',
              e,
            );
            Logger('WalletConnectService').log(
              Level.INFO,
              'onSessionProposal approveResponse',
              e,
              stackTrace,
            );
          }
        }
      } else {
        await _web3Wallet!.rejectSession(
          id: event.id,
          reason: Errors.getSdkError(
            Errors.USER_REJECTED,
          ),
        );
        await _web3Wallet!.core.pairing.disconnect(
          topic: event.params.pairingTopic,
        );
      }
    }
  }

  void _onSessionConnect(SessionConnect? args) {
    if (args != null) {
      sessions.value.add(args.session);
    }
    Logger('WalletConnectService')
        .log(Level.INFO, '_onSessionConnect triggered', args.toString());
    Future.delayed(const Duration(seconds: 3))
        .then((value) => sl.get<WalletConnectSessionsBloc>().refreshResults());
  }

  Future<void> _onSessionAuthRequest(SessionAuthRequest? args) async {
    Logger('Web3WalletService').info(
      '_onSessionAuthRequest ${jsonEncode(args?.authPayload.toJson())}',
    );
    if (args != null) {
      final SessionAuthPayload authPayload = args.authPayload;

      final Iterable<String> supportedChainIds =
          await _generateSupportedChainIds();
      final supportedMethods = Eip155SupportedMethods.values.map((e) => e.name);
      final newAuthPayload = AuthSignature.populateAuthPayload(
        authPayload: authPayload,
        chains: supportedChainIds.toList(),
        methods: supportedMethods.toList(),
      );
      final cacaoRequestPayload = CacaoRequestPayload.fromSessionAuthPayload(
        newAuthPayload,
      );
      final AppAddress address = kEthSelectedAddress!;

      final List<Map<String, dynamic>> formattedMessages = [];
      for (final chain in newAuthPayload.chains) {
        final iss = 'did:pkh:$chain:${address.hex}';
        final message = _web3Wallet!.formatAuthMessage(
          iss: iss,
          cacaoPayload: cacaoRequestPayload,
        );
        formattedMessages.add({iss: message});
      }

      final bool? rs = await showDialogWithNoAndYesOptions<bool>(
        context: navState.currentContext!,
        title: '${args.requester.metadata.name} would like to connect',
        onYesButtonPressed: () async {},
        onNoButtonPressed: () async {},
        content: Column(
          children: formattedMessages
              .map(
                (e) => Text(e.values.first as String),
              )
              .toList(),
        ),
      );

      if (rs ?? false) {
        final credentials = await generateCredentials(address: address.hex);
        //
        final List<Cacao> cacaos = [];
        for (var i = 0; i < formattedMessages.length; i++) {
          final iss = formattedMessages[i].keys.first;
          final String message = formattedMessages[i].values.first as String;
          final signature = credentials.signPersonalMessageToUint8List(
            Uint8List.fromList(message.codeUnits),
          );
          final hexSignature = bytesToHex(signature, include0x: true);
          cacaos.add(
            AuthSignature.buildAuthObject(
              requestPayload: cacaoRequestPayload,
              signature: CacaoSignature(
                t: CacaoSignature.EIP191,
                s: hexSignature,
              ),
              iss: iss,
            ),
          );
        }
        //
        final _ = await _web3Wallet!.approveSessionAuthenticate(
          id: args.id,
          auths: cacaos,
        );
      } else {
        await _web3Wallet!.rejectSessionAuthenticate(
          id: args.id,
          reason: Errors.getSdkError(Errors.USER_REJECTED_AUTH),
        );
      }
    }
  }

  Future<Iterable<String>> _generateSupportedChainIds() async {
    final List<AppNetwork> appNetworks = await db.managers.appNetworks
        .filter((f) => f.blockChain.equals(BlockChain.evm))
        .get();
    final Iterable<ChainMetadata> chainsMetadata =
        appNetworks.map((e) => generateChainMetadata(e));
    final supportedChains = chainsMetadata.map((e) => e.chainId);
    return supportedChains;
  }

  Future<void> _onAuthRequest(AuthRequest? args) async {
    Logger('Web3WalletService').info(
      '_onAuthRequest ${jsonEncode(args?.payloadParams.toJson())}',
    );
    if (args != null) {
      final AppAddress address = kEthSelectedAddress!;

      final cacaoPayload = CacaoRequestPayload.fromPayloadParams(
        args.payloadParams,
      );
      final iss = 'did:pkh:${args.payloadParams.chainId}:${address.hex}';
      final message = _web3Wallet!.formatAuthMessage(
        iss: iss,
        cacaoPayload: cacaoPayload,
      );

      final bool? rs = await showDialogWithNoAndYesOptions<bool>(
        context: navState.currentContext!,
        title: '${args.requester.metadata.name} would like to connect',
        onYesButtonPressed: () async {},
        onNoButtonPressed: () async {},
        content: Text(message),
      );

      if (rs ?? false) {
        final credentials = await generateCredentials(address: address.hex);

        final signature = credentials.signPersonalMessageToUint8List(
          Uint8List.fromList(message.codeUnits),
        );
        final hexSignature = bytesToHex(signature, include0x: true);

        await _web3Wallet!.respondAuthRequest(
          id: args.id,
          iss: iss,
          signature: CacaoSignature(
            t: CacaoSignature.EIP191,
            s: hexSignature,
          ),
        );
      } else {
        await _web3Wallet!.respondAuthRequest(
          id: args.id,
          iss: iss,
          error: Errors.getSdkError(Errors.USER_REJECTED_AUTH),
        );
      }
    }
  }

  void _sendSuccessfullyApprovedSessionNotification(
    PairingMetadata dAppMetadata,
  ) {
    sl.get<NotificationsService>().addNotification(
          WalletNotificationsCompanion.insert(
            title: 'Successfully connected to ${dAppMetadata.name}',
            details: 'Successfully connected to ${dAppMetadata.name} '
                'via WalletConnect',
            type: NotificationType.paymentSent,
          ),
        );
  }

  Future<ApproveResponse> _approveSession({
    required SessionProposalEvent event,
  }) async {
    return _web3Wallet!.approveSession(
      id: event.id,
      namespaces: event.params.generatedNamespaces!,
      sessionProperties: event.params.sessionProperties,
    );
  }

  Future<void> _emitEventPairedDApps({
    required String changeName,
    required String newValue,
  }) async {
    final sessionTopics =
        pairings.value.fold<List<String>>(<String>[], (previousValue, pairing) {
      if (pairing.active) {
        previousValue.addAll(getSessionsForPairing(pairing.topic).keys);
        return previousValue;
      }
      return previousValue;
    });

    for (final String sessionTopic in sessionTopics) {
      _emitDAppEvent(
        sessionTopic: sessionTopic,
        changeName: changeName,
        newValue: newValue,
      );
    }
  }

  Future<void> _emitDAppEvent({
    required String sessionTopic,
    required String changeName,
    required String newValue,
  }) {
    return _web3Wallet!.emitSessionEvent(
      topic: sessionTopic,
      chainId: 'zenon:1',
      event: SessionEventParams(
        name: changeName,
        data: newValue,
      ),
    );
  }
}
