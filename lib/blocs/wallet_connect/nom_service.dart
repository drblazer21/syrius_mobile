import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/blocs/transfer/send_payment_bloc.dart';
import 'package:syrius_mobile/blocs/wallet_connect/i_chain.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/services/i_web3wallet_service.dart';
import 'package:syrius_mobile/utils/extensions/extensions.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/utils/wallet/sign_utils.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/icons/link_icon.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

enum NoMChainId {
  mainnet,
  testnet,
}

extension NoMChainIdX on NoMChainId {
  String chain() {
    String name = '';

    switch (this) {
      case NoMChainId.mainnet:
        name = '1';
      case NoMChainId.testnet:
        name = '3';
    }

    return '${NoMService.namespace}:$name';
  }
}

class NoMService extends IChain {
  static const namespace = 'zenon';

  final IWeb3WalletService _web3WalletService = sl<IWeb3WalletService>();

  final NoMChainId reference;

  final _walletLockedError = const WalletConnectError(
    code: 9000,
    message: 'Wallet is locked',
  );

  Web3Wallet? wallet;

  NoMService({
    required this.reference,
  }) {
    wallet = _web3WalletService.getWeb3Wallet();

    // Register event emitters
    // wallet!.registerEventEmitter(chainId: getChainId(), event: 'chainIdChange');
    // wallet!.registerEventEmitter(chainId: getChainId(), event: 'addressChange');

    // Register request handlers
    wallet!.registerRequestHandler(
      chainId: getChainId(),
      method: 'znn_info',
      handler: _methodZnnInfo,
    );
    wallet!.registerRequestHandler(
      chainId: getChainId(),
      method: 'znn_sign',
      handler: _methodZnnSign,
    );
    wallet!.registerRequestHandler(
      chainId: getChainId(),
      method: 'znn_send',
      handler: _methodZnnSend,
    );
  }

  @override
  String getNamespace() {
    return namespace;
  }

  @override
  String getChainId() {
    return reference.chain();
  }

  @override
  List<String> getEvents() {
    return ['chainIdChange', 'addressChange'];
  }

  Future _methodZnnInfo(String topic, dynamic params) async {
    final dAppMetadata = wallet!
        .getActiveSessions()
        .values
        .firstWhere((element) => element.topic == topic)
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
        return {
          'address': kSelectedAddress,
          'nodeUrl': kCurrentNode,
          'chainId': getChainIdentifier(),
        };
      } else {
        sendNotificationError(
          AppLocalizations.of(navState.currentContext!)!.walletConnectRejection,
          Errors.getSdkError(Errors.USER_REJECTED),
        );
        throw Errors.getSdkError(Errors.USER_REJECTED);
      }
    } else {
      throw _walletLockedError;
    }
  }

  Future _methodZnnSign(String topic, dynamic params) async {
    final dAppMetadata = wallet!
        .getActiveSessions()
        .values
        .firstWhere((element) => element.topic == topic)
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
        return await walletSign(message.codeUnits);
      } else {
        sendNotificationError(
          AppLocalizations.of(navState.currentContext!)!.walletConnectRejection,
          Errors.getSdkError(Errors.USER_REJECTED),
        );
        throw Errors.getSdkError(Errors.USER_REJECTED);
      }
    } else {
      throw _walletLockedError;
    }
  }

  Future _methodZnnSend(String topic, dynamic params) async {
    final dAppMetadata = wallet!
        .getActiveSessions()
        .values
        .firstWhere((element) => element.topic == topic)
        .peer
        .metadata;
    final accountBlock = AccountBlockTemplate.fromJson(
      // ignore: avoid_dynamic_calls
      params['accountBlock'] as Map<String, dynamic>,
    );

    final toAddress = accountBlock.toAddress.toString();

    final token =
        await zenon.embedded.token.getByZts(accountBlock.tokenStandard);

    final amount = accountBlock.amount.addDecimals(token!.decimals);

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
          fromAddress: kSelectedAddress!,
          toAddress: toAddress,
          amount: amount.extractDecimals(token.decimals),
          token: token,
        );

        final result = await sendPaymentBloc.stream.firstWhere(
          (element) => element != null,
        );

        return result!;
      } else {
        sendNotificationError(
          AppLocalizations.of(navState.currentContext!)!.walletConnectRejection,
          Errors.getSdkError(Errors.USER_REJECTED),
        );
        throw Errors.getSdkError(Errors.USER_REJECTED);
      }
    } else {
      throw _walletLockedError;
    }
  }
}
