import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import 'package:syrius_mobile/blocs/transfer/send_payment_bloc.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/services/i_web3wallet_service.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/utils/wallet/sign_utils.dart';
import 'package:syrius_mobile/utils/wallet_connect/chain_metadata.dart';
import 'package:syrius_mobile/utils/wallet_connect/nom_supported_events.dart';
import 'package:syrius_mobile/utils/wallet_connect/nom_supported_methods.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/icons/link_icon.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart'
    hide Level, Logger;
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class NoMService {
  final IWeb3WalletService _web3WalletService = sl<IWeb3WalletService>();

  final ChainMetadata chainMetaData;

  String get chainId => chainMetaData.chainId;

  bool get matchesSelectedNetwork =>
      chainId ==
      generateChainMetadata(kSelectedAppNetworkWithAssets!.network).chainId;

  SessionRequest get pendingRequest =>
      _web3Wallet.pendingRequests.getAll().last;

  final Logger _logger = Logger('NomService');

  late Web3Wallet _web3Wallet;

  Map<String, dynamic Function(SessionRequestEvent, dynamic)>
      get methodRequestHandlers => {
            NomSupportedMethods.info.name: _methodZnnInfo,
            NomSupportedMethods.send.name: _methodZnnSend,
            NomSupportedMethods.sign.name: _methodZnnSign,
          };

  NoMService({
    required this.chainMetaData,
  }) {
    _web3Wallet = _web3WalletService.getWeb3Wallet();

    // Register accounts
    for (final address in addressList) {
      _web3Wallet.registerAccount(
        chainId: chainId,
        accountAddress: address.hex,
      );
    }

    // Register event emitters
    for (final event in NomSupportedEvents.values) {
      _web3Wallet.registerEventEmitter(
        chainId: chainId,
        event: event.name,
      );
    }

    // Register supported methods
    for (final entry in methodRequestHandlers.entries) {
      _web3Wallet.registerRequestHandler(
        chainId: chainId,
        method: entry.key,
      );
    }

    /// We haven't registered any handlers for the methods, so we need to
    /// subscribe to onSessionRequest to choose a handler for each method
    _web3Wallet.onSessionRequest.subscribe(_onSessionRequest);
  }

  /// onSessionRequest will allow us to have a better control for each request
  /// coming from the dApp
  ///
  /// For example, before handling any request, we can check that the wallet and
  /// the dApp are on the same chain id - meaning same block chain and network id
  Future<void> _onSessionRequest(SessionRequestEvent? args) async {
    if (args != null && args.chainId == chainId) {
      _logger.info('[WALLET] _onSessionRequest $args');
      if (matchesSelectedNetwork) {
        final handler = methodRequestHandlers[args.method];
        if (handler != null) {
          await handler(args, args.params);
        }
      } else {
        var response = JsonRpcResponse(
          id: pendingRequest.id,
        );
        response = response.copyWith(
          error: JsonRpcError.invalidRequest(
            "Wallet and dApp chain identifiers don't match",
          ),
        );
        _web3Wallet.respondSessionRequest(
          topic: args.topic,
          response: response,
        );
      }
    }
  }

  Future _methodZnnInfo(SessionRequestEvent request, dynamic params) async {
    JsonRpcResponse response = JsonRpcResponse(id: request.id);
    final dAppMetadata = _web3Wallet
        .getActiveSessions()
        .values
        .firstWhere((element) => element.topic == request.topic)
        .peer
        .metadata;

    if (navState.currentContext!.mounted) {
      final actionWasAccepted = await showDialogWithNoAndYesOptions<bool>(
        context: navState.currentContext!,
        title: dAppMetadata.name,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to allow ${dAppMetadata.name} to '
                'retrieve the current address, node URL and chain identifier information?'),
            kVerticalSpacer,
            Image(
              image: NetworkImage(dAppMetadata.icons.first),
              height: 100.0,
              fit: BoxFit.fitHeight,
            ),
            kVerticalSpacer,
            Text(dAppMetadata.description),
            kVerticalSpacer,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(dAppMetadata.url),
                LinkIcon(
                  url: dAppMetadata.url,
                ),
              ],
            ),
          ],
        ),
        onYesButtonPressed: () async {},
        onNoButtonPressed: () {},
      );

      if (actionWasAccepted ?? false) {
        final Map<String, dynamic> result = {
          'address': kSelectedAddress!.hex,
          'nodeUrl': kSelectedAppNetworkWithAssets!..network.url,
          'chainId': kSelectedAppNetworkWithAssets!.network.chainId,
        };
        response = response.copyWith(result: result);
      } else {
        sendNotificationError(
          AppLocalizations.of(navState.currentContext!)!.walletConnectRejection,
          Errors.getSdkError(Errors.USER_REJECTED),
        );
        response = response.copyWith(
          error:
              const JsonRpcError(code: 5001, message: 'User rejected method'),
        );
      }
    } else {
      response = response.copyWith(
        error: const JsonRpcError(code: 5001, message: 'Wallet is locked'),
      );
    }
    await _web3Wallet.respondSessionRequest(
      topic: request.topic,
      response: response,
    );
  }

  Future _methodZnnSign(SessionRequestEvent request, dynamic params) async {
    JsonRpcResponse response = JsonRpcResponse(id: request.id);
    final dAppMetadata = _web3Wallet
        .getActiveSessions()
        .values
        .firstWhere((element) => element.topic == request.topic)
        .peer
        .metadata;
    final message = params as String;

    if (navState.currentContext!.mounted) {
      final actionWasAccepted = await showDialogWithNoAndYesOptions<bool>(
        context: navState.currentContext!,
        title: dAppMetadata.name,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to '
                'sign the following message: `$message` ?'),
            kVerticalSpacer,
            Image(
              image: NetworkImage(dAppMetadata.icons.first),
              height: 100.0,
              fit: BoxFit.fitHeight,
            ),
            kVerticalSpacer,
            Text(dAppMetadata.description),
            kVerticalSpacer,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(dAppMetadata.url),
                LinkIcon(
                  url: dAppMetadata.url,
                ),
              ],
            ),
          ],
        ),
        onYesButtonPressed: () async {},
        onNoButtonPressed: () async {},
      );

      if (actionWasAccepted ?? false) {
        final Signature result = await walletSign(message.codeUnits);

        response = response.copyWith(result: result.signature);
      } else {
        sendNotificationError(
          AppLocalizations.of(navState.currentContext!)!.walletConnectRejection,
          Errors.getSdkError(Errors.USER_REJECTED),
        );
        response = response.copyWith(
          error:
              const JsonRpcError(code: 5001, message: 'User rejected method'),
        );
      }
    } else {
      response = response.copyWith(
        error: const JsonRpcError(code: 5001, message: 'Wallet is locked'),
      );
    }
    await _web3Wallet.respondSessionRequest(
      topic: request.topic,
      response: response,
    );
  }

  Future _methodZnnSend(SessionRequestEvent request, dynamic params) async {
    JsonRpcResponse response = JsonRpcResponse(id: request.id);
    final dAppMetadata = _web3Wallet
        .getActiveSessions()
        .values
        .firstWhere((element) => element.topic == request.topic)
        .peer
        .metadata;
    final accountBlock = AccountBlockTemplate.fromJson(
      // ignore: avoid_dynamic_calls
      params['accountBlock'] as Map<String, dynamic>,
    );

    final toAddress = accountBlock.toAddress.toString();

    final token =
        await zenon.embedded.token.getByZts(accountBlock.tokenStandard);

    final amount = accountBlock.amount.toStringWithDecimals(token!.decimals);

    final sendPaymentBloc = SendPaymentBloc();

    if (navState.currentContext!.mounted) {
      final wasActionAccepted = await showDialogWithNoAndYesOptions<bool>(
        context: navState.currentContext!,
        title: dAppMetadata.name,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Transfer '
                '$amount ${token.symbol} to '
                '$toAddress'),
            kVerticalSpacer,
            Image(
              image: NetworkImage(dAppMetadata.icons.first),
              height: 100.0,
              fit: BoxFit.fitHeight,
            ),
            kVerticalSpacer,
            Text(dAppMetadata.description),
            kVerticalSpacer,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(dAppMetadata.url),
                LinkIcon(
                  url: dAppMetadata.url,
                ),
              ],
            ),
          ],
        ),
        description: 'Are you sure you want to transfer '
            '$amount ${token.symbol} to '
            '$toAddress ?',
        onYesButtonPressed: () {},
        onNoButtonPressed: () {},
      );

      if (wasActionAccepted ?? false) {
        sendPaymentBloc.sendTransfer(
          context: navState.currentContext!,
          fromAddress: kSelectedAddress!.hex,
          toAddress: toAddress,
          amount: amount.extractDecimals(token.decimals),
          token: token,
        );

        final result = await sendPaymentBloc.stream.firstWhere(
          (element) => element != null,
        );

        response = response.copyWith(result: result);
      } else {
        sendNotificationError(
          AppLocalizations.of(navState.currentContext!)!.walletConnectRejection,
          Errors.getSdkError(Errors.USER_REJECTED),
        );
        response = response.copyWith(
          error: const JsonRpcError(
            code: 5001,
            message: 'User rejected the request',
          ),
        );
      }
    } else {
      response = response.copyWith(
        error: const JsonRpcError(code: 5001, message: 'Wallet is locked'),
      );
    }

    await _web3Wallet.respondSessionRequest(
      topic: request.topic,
      response: response,
    );
  }
}
