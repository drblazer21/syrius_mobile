import 'dart:convert';

import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/services/services.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/utils/wallet_connect/chain_metadata.dart';
import 'package:syrius_mobile/utils/wallet_connect/common.dart';
import 'package:syrius_mobile/utils/wallet_connect/eip155_supported_methods.dart';
import 'package:syrius_mobile/utils/wallet_connect/eth_utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart'
    hide Level, Logger;

class EthereumWcService {
  final IWeb3WalletService _web3WalletService = sl<IWeb3WalletService>();

  final ChainMetadata chainMetaData;

  String get chainId => chainMetaData.chainId;

  bool get matchesSelectedNetwork =>
      chainId ==
      generateChainMetadata(kSelectedAppNetworkWithAssets!.network).chainId;

  final Logger _logger = Logger('EthereumService');
  final CommonMethods _commonMethods = CommonMethods();
  final GasFeeDetailsBloc _gasFeeDetailsBloc = GasFeeDetailsBloc();

  late Web3Wallet _web3Wallet;

  Map<String, dynamic Function(String, dynamic)> get sessionRequestHandlers => {
        Eip155SupportedMethods.ethSign.name: ethSign,
        Eip155SupportedMethods.ethSignTransaction.name: ethSignTransaction,
        Eip155SupportedMethods.ethSignTypedData.name: ethSignTypedData,
        Eip155SupportedMethods.ethSignTypedDataV4.name: ethSignTypedDataV4,
        Eip155SupportedMethods.switchChain.name: switchChain,
        // 'wallet_addEthereumChain': addChain,
      };

  Map<String, dynamic Function(String, dynamic)> get methodRequestHandlers => {
        Eip155SupportedMethods.personalSign.name: personalSign,
        Eip155SupportedMethods.ethSendTransaction.name: ethSendTransaction,
      };

  EthereumWcService({required this.chainMetaData}) {
    _web3Wallet = _web3WalletService.getWeb3Wallet();

    // Register accounts
    for (final address in addressList) {
      _web3Wallet.registerAccount(
        chainId: chainId,
        accountAddress: address.hex,
      );
    }

    for (final event in EventsConstants.allEvents) {
      _web3Wallet.registerEventEmitter(
        chainId: chainMetaData.chainId,
        event: event,
      );
    }

    for (final handler in methodRequestHandlers.entries) {
      _web3Wallet.registerRequestHandler(
        chainId: chainMetaData.chainId,
        method: handler.key,
        handler: handler.value,
      );
    }
    for (final handler in sessionRequestHandlers.entries) {
      _web3Wallet.registerRequestHandler(
        chainId: chainMetaData.chainId,
        method: handler.key,
        handler: handler.value,
      );
    }

    _web3Wallet.onSessionRequest.subscribe(_onSessionRequest);
  }

  Future<void> personalSign(String topic, dynamic parameters) async {
    Logger('EthereumService').log(
      Level.INFO,
      'personalSign triggered',
      parameters.toString(),
    );
    final pRequest = _web3Wallet.pendingRequests.getAll().last;
    final data = EthUtils().getDataFromParamsList(parameters);
    final message = EthUtils().getUtf8Message(data.toString());
    var response = JsonRpcResponse(
      id: pRequest.id,
    );

    if (matchesSelectedNetwork) {
      if (await _commonMethods.requestApproval(
        text: message,
        dAppMetadata: getDAppMetadata(topic),
      )) {
        try {
          final credentials = await generateCredentials(
            address: selectedAddress.hex,
          );
          final signature = credentials.signPersonalMessageToUint8List(
            utf8.encode(message),
          );
          final signedTx = bytesToHex(signature, include0x: true);

          isValidSignature(signedTx, message, credentials.address.hex);

          response = response.copyWith(result: signedTx);
        } catch (e) {
          Logger('EthereumService').log(
            Level.WARNING,
            'personalSign error',
            e,
          );
          response = response.copyWith(
            error: JsonRpcError(code: 0, message: e.toString()),
          );
        }
      } else {
        response = response.copyWith(
          error:
              const JsonRpcError(code: 5001, message: 'User rejected method'),
        );
      }
    } else {
      response = response.copyWith(
        error: JsonRpcError.invalidRequest(
          "Wallet and dApp chain identifiers don't match",
        ),
      );
    }

    await _web3Wallet.respondSessionRequest(
      topic: topic,
      response: response,
    );
  }

  Future<void> ethSign(String topic, dynamic parameters) async {
    _logger.info(
      'ethSign request: $parameters',
    );
    final pRequest = _web3Wallet.pendingRequests.getAll().last;
    final data = EthUtils().getDataFromParamsList(parameters);
    final message = EthUtils().getUtf8Message(data.toString());
    var response = JsonRpcResponse(
      id: pRequest.id,
    );

    if (matchesSelectedNetwork) {
      if (await _commonMethods.requestApproval(
        dAppMetadata: getDAppMetadata(topic),
        text: message,
      )) {
        try {
          final credentials = await generateCredentials(
            address: selectedAddress.hex,
          );
          final signature = credentials.signToUint8List(
            utf8.encode(message),
          );
          final signedTx = bytesToHex(signature, include0x: true);

          isValidSignature(signedTx, message, credentials.address.hex);

          response = response.copyWith(result: signedTx);
        } catch (e) {
          _logger.warning(
            '[WALLET] ethSign error',
            e,
          );
          response = response.copyWith(
            error: JsonRpcError(code: 0, message: e.toString()),
          );
        }
      } else {
        response = response.copyWith(
          error:
              const JsonRpcError(code: 5001, message: 'User rejected method'),
        );
      }
    } else {
      response = response.copyWith(
        error: JsonRpcError.invalidRequest(
          "Wallet and dApp chain identifiers don't match",
        ),
      );
    }

    await _web3Wallet.respondSessionRequest(
      topic: topic,
      response: response,
    );
  }

  Future<void> ethSignTypedData(String topic, dynamic parameters) async {
    _logger.info('[WALLET] ethSignTypedData request: $parameters');
    final pRequest = _web3Wallet.pendingRequests.getAll().last;
    final data = EthUtils().getDataFromParamsList(parameters);
    var response = JsonRpcResponse(
      id: pRequest.id,
    );

    if (matchesSelectedNetwork) {
      if (await _commonMethods.requestApproval(
        dAppMetadata: getDAppMetadata(topic),
        text: data as String,
      )) {
        try {
          final signature = EthSigUtil.signTypedData(
            privateKey: await getPrivateKey(address: selectedAddress.hex),
            jsonData: data,
            version: TypedDataVersion.V1,
          );

          response = response.copyWith(result: signature);
        } catch (e) {
          _logger.warning(
            '[WALLET] ethSignTypedData error',
            e,
          );
          response = response.copyWith(
            error: JsonRpcError(code: 0, message: e.toString()),
          );
        }
      } else {
        response = response.copyWith(
          error:
              const JsonRpcError(code: 5001, message: 'User rejected method'),
        );
      }
    } else {
      response = response.copyWith(
        error: JsonRpcError.invalidRequest(
          "Wallet and dApp chain identifiers don't match",
        ),
      );
    }

    await _web3Wallet.respondSessionRequest(
      topic: topic,
      response: response,
    );
  }

  Future<void> ethSignTypedDataV4(String topic, dynamic parameters) async {
    _logger.info('[WALLET] ethSignTypedDataV4 request: $parameters');
    final pRequest = _web3Wallet.pendingRequests.getAll().last;
    final data = EthUtils().getDataFromParamsList(parameters);
    var response = JsonRpcResponse(
      id: pRequest.id,
    );

    if (matchesSelectedNetwork) {
      if (await _commonMethods.requestApproval(
        dAppMetadata: getDAppMetadata(topic),
        text: data as String,
      )) {
        try {
          final signature = EthSigUtil.signTypedData(
            privateKey: await getPrivateKey(address: selectedAddress.hex),
            jsonData: data,
            version: TypedDataVersion.V4,
          );

          response = response.copyWith(result: signature);
        } catch (e) {
          _logger.warning('[WALLET] ethSignTypedDataV4 error', e);
          response = response.copyWith(
            error: JsonRpcError(code: 0, message: e.toString()),
          );
        }
      } else {
        response = response.copyWith(
          error:
              const JsonRpcError(code: 5001, message: 'User rejected method'),
        );
      }
    } else {
      response = response.copyWith(
        error: JsonRpcError.invalidRequest(
          "Wallet and dApp chain identifiers don't match",
        ),
      );
    }

    await _web3Wallet.respondSessionRequest(
      topic: topic,
      response: response,
    );
  }

  Future<void> ethSignTransaction(String topic, dynamic parameters) async {
    _logger.info('[WALLET] ethSignTransaction request: $parameters');
    final pRequest = _web3Wallet.pendingRequests.getAll().last;
    final data = EthUtils().getTransactionFromParams(parameters);
    if (data == null) return;
    var response = JsonRpcResponse(
      id: pRequest.id,
    );

    if (matchesSelectedNetwork) {
      final transaction = await _approveTransactionWithGasFees(data);
      if (transaction is Transaction) {
        try {
          final credentials = await generateCredentials(
            address: selectedAddress.hex,
          );

          final signature = await eth.signTx(
            chainId: chainMetaData.chainIdInt,
            cred: credentials,
            transaction: transaction,
          );
          // Sign the transaction
          final signedTx = bytesToHex(signature, include0x: true);

          response = response.copyWith(result: signedTx);
        } on RPCError catch (e) {
          final String message = e.message;
          _logger.warning('[WALLET] ethSignTransaction error: $message', e);
          response = response.copyWith(
            error: JsonRpcError(code: e.errorCode, message: e.message),
          );
        } catch (e) {
          _logger.info('[WALLET] ethSignTransaction error', e);
          response = response.copyWith(
            error: JsonRpcError(code: 0, message: e.toString()),
          );
        }
      } else {
        response = response.copyWith(error: transaction as JsonRpcError);
      }
    } else {
      response = response.copyWith(
        error: JsonRpcError.invalidRequest(
          "Wallet and dApp chain identifiers don't match",
        ),
      );
    }

    await _web3Wallet.respondSessionRequest(
      topic: topic,
      response: response,
    );
  }

  Future<void> ethSendTransaction(String topic, dynamic parameters) async {
    _logger.info('[WALLET] ethSendTransaction request: $parameters');
    final pRequest = _web3Wallet.pendingRequests.getAll().last;
    final data = EthUtils().getTransactionFromParams(parameters);
    if (data == null) return;
    var response = JsonRpcResponse(
      id: pRequest.id,
    );

    if (matchesSelectedNetwork) {
      final transaction = await _approveTransactionWithGasFees(data);
      if (transaction is Transaction) {
        try {
          final hash = await eth.sendEthereumAssetTx(
            tx: transaction,
            chainId: chainMetaData.chainIdInt,
          );

          response = response.copyWith(result: hash);
        } on RPCError catch (e) {
          final String message = e.message;
          _logger.warning('[WALLET] ethSendTransaction error: $message', e);
          response = response.copyWith(
            error: JsonRpcError(code: e.errorCode, message: e.message),
          );
        } catch (e) {
          _logger.warning('[WALLET] ethSendTransaction error $e');
          response = response.copyWith(
            error: JsonRpcError(code: 0, message: e.toString()),
          );
        }
      } else {
        response = response.copyWith(error: transaction as JsonRpcError);
      }
    } else {
      response = response.copyWith(
        error: JsonRpcError.invalidRequest(
          "Wallet and dApp chain identifiers don't match",
        ),
      );
    }

    await _web3Wallet.respondSessionRequest(
      topic: topic,
      response: response,
    );
  }

  Future<void> switchChain(String topic, dynamic parameters) async {
    _logger.info('[WALLET] switchChain request: $topic $parameters');
    final pRequest = _web3Wallet.pendingRequests.getAll().last;
    var response = JsonRpcResponse(id: pRequest.id);
    try {
      final params = (parameters as List).first as Map<String, dynamic>;
      final hexChainId = params['chainId'].toString().replaceFirst('0x', '');
      final chainId = int.parse(hexChainId, radix: 16);
      await _web3Wallet.emitSessionEvent(
        topic: topic,
        chainId: 'eip155:$chainId',
        event: SessionEventParams(
          name: 'chainChanged',
          data: chainId,
        ),
      );
      response = response.copyWith(result: true);
    } on WalletConnectError catch (e) {
      _logger.warning('[WALLET] switchChain error', e);
      response = response.copyWith(
        error: JsonRpcError(code: e.code, message: e.message),
      );
    } catch (e) {
      _logger.warning('[WALLET] switchChain error', e);
      response = response.copyWith(
        error: JsonRpcError(code: 0, message: e.toString()),
      );
    }

    await _web3Wallet.respondSessionRequest(
      topic: topic,
      response: response,
    );
  }

  Future<dynamic> _approveTransactionWithGasFees(
    Map<String, dynamic> tJson,
  ) async {
    final Transaction transaction = tJson.toTransaction();

    _gasFeeDetailsBloc.addEvent(GasFeeDetailsLoading());

    _gasFeeDetailsBloc.fetch(
      fetchAsset: transaction.isContractInteraction,
      tx: transaction,
    );

    final dynamic result = await _showConfirmTxBottomSheet();

    if (result as bool? ?? false) {
      final GasFeeDetailsState lastState = _gasFeeDetailsBloc.lastValue!;
      return (lastState as GasFeeDetailsLoaded)
          .ethereumTxGasDetailsData
          .txWithGasFee;
    } else {
      return const JsonRpcError(code: 5001, message: 'User rejected method');
    }
  }

  /// This will only emmit if for a particular method, no handler was registered
  /// https://github.com/WalletConnect/WalletConnectFlutterV2/pull/269
  Future<void> _onSessionRequest(SessionRequestEvent? args) async {
    if (args != null && args.chainId == chainId && matchesSelectedNetwork) {
      _logger.info('[WALLET] _onSessionRequest $args');
      final handler = sessionRequestHandlers[args.method];
      if (handler != null) {
        await handler(args.topic, args.params);
      }
    }
  }

  bool isValidSignature(
    String hexSignature,
    String message,
    String hexAddress,
  ) {
    try {
      _logger.info('isValidSignature(): $hexSignature, $message, $hexAddress');
      final recoveredAddress = EthSigUtil.recoverPersonalSignature(
        signature: hexSignature,
        message: utf8.encode(message),
      );
      _logger.info('recoveredAddress: $recoveredAddress');

      final recoveredAddress2 = EthSigUtil.recoverSignature(
        signature: hexSignature,
        message: utf8.encode(message),
      );
      _logger.info('recoveredAddress2: $recoveredAddress2');

      final isValid = recoveredAddress == hexAddress;
      _logger.info('isValidSignature: $isValid');
      return isValid;
    } catch (e) {
      _logger.warning('isValidSignature() error', e);
      return false;
    }
  }

  PairingMetadata getDAppMetadata(String topic) => _web3Wallet
      .getActiveSessions()
      .values
      .firstWhere((element) => element.topic == topic)
      .peer
      .metadata;

  Future<dynamic> _showConfirmTxBottomSheet() {
    return showModalBottomSheetWithBody(
      context: navState.currentState!.context,
      title: 'Sign transaction',
      body: AppStreamBuilder<EthAccountBalance>(
        errorHandler: (a) {},
        stream: sl.get<EthAccountBalanceBloc>().stream,
        builder: (ethereumAccountBalance) {
          return _buildGasFeeListenerWidget(ethereumAccountBalance);
        },
        customErrorWidget: (String error) {
          return SyriusErrorWidget(error);
        },
        customLoadingWidget: const SyriusLoadingWidget(),
      ),
    );
  }

  StreamBuilder<GasFeeDetailsState> _buildGasFeeListenerWidget(
    EthAccountBalance ethAccountBalance,
  ) {
    return StreamBuilder(
      initialData: GasFeeDetailsInitialState(),
      stream: _gasFeeDetailsBloc.stream,
      builder: (_, snapshot) {
        switch (snapshot.data!) {
          case GasFeeDetailsInitialState():
            return const SyriusLoadingWidget();
          case GasFeeDetailsLoading():
            return const SyriusLoadingWidget();
          case GasFeeDetailsLoaded():
            final GasFeeDetailsLoaded loaded =
                snapshot.data! as GasFeeDetailsLoaded;
            return StatefulBuilder(
              builder: (_, setState) => _buildConfirmTxBottomSheetBody(
                ethAccountBalance: ethAccountBalance,
                gasDetails: loaded.ethereumTxGasDetailsData,
                setState: setState,
              ),
            );
          case GasFeeDetailsError():
            return SyriusErrorWidget(
              (snapshot.data! as GasFeeDetailsError).message,
            );
        }
      },
    );
  }

  Column _buildConfirmTxBottomSheetBody({
    required EthAccountBalance ethAccountBalance,
    required EthereumTxGasDetailsData gasDetails,
    required StateSetter setState,
  }) {
    String? readableAmount;
    String? symbol;
    EthereumAddress? to;

    if (gasDetails.tx.isContractInteraction) {
      final Uint8List data = gasDetails.tx.data!;
      if (eth.dataMatchesTransferTokenFunction(data: data)) {
        final List<dynamic> decodedParameters = decodeParameters(
          eth.getTokenTransferFunction(),
          data,
        );

        to = decodedParameters[0] as EthereumAddress;

        final BigInt amount = decodedParameters[1] as BigInt;

        final NetworkAssetsCompanion asset = gasDetails.asset!;

        readableAmount = amount.toStringWithDecimals(asset.decimals.value);

        symbol = asset.symbol.value;
      }
    } else {
      readableAmount = gasDetails.tx.value!.toEthWithDecimals();
      symbol = kSelectedAppNetworkWithAssets!.network.currencySymbol;
      to = gasDetails.tx.to;
    }

    BigInt totalNeededEthForTx = gasDetails.maxFee.getInWei;

    if (gasDetails.tx.value != null) {
      totalNeededEthForTx += gasDetails.tx.value!.getInWei;
    }

    final bool hasEnoughEth = _ethAmountValidator(
          totalNeededEthForTx.toStringWithDecimals(
            kEvmCurrencyDecimals,
          ),
          ethAccountBalance.getCurrency(),
        ) ==
        null;

    final Widget subtitleWidget = Text(
      AppLocalizations.of(navState.currentState!.context)!.reviewTransaction,
      style: navState.currentState!.context.textTheme.titleSmall?.copyWith(
        color: navState.currentState!.context.colorScheme.secondary,
      ),
      textAlign: TextAlign.center,
    );

    final Widget confirmButton = SyriusFilledButton(
      text: AppLocalizations.of(navState.currentState!.context)!.confirm,
      onPressed: () {
        Navigator.pop(navState.currentState!.context, true);
      },
    );

    final Widget ethBalanceWarning = Text(
      'Not enough ETH to pay for the gas fees',
      style: TextStyle(
        color: navState.currentState!.context.colorScheme.error,
      ),
      textAlign: TextAlign.center,
    );

    final String currencySymbol =
        kSelectedAppNetworkWithAssets!.network.currencySymbol;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        subtitleWidget,
        Column(
          children: [
            ..._buildEthereumTxSpeedListTiles(
              data: gasDetails,
            ),
          ],
        ),
        BottomSheetInfoRow(
          context: navState.currentState!.context,
          leftContent: 'Estimated gas',
          rightContent:
              '${gasDetails.estimatedGas.toEthWithDecimals()} $currencySymbol',
        ),
        BottomSheetInfoRow(
          context: navState.currentState!.context,
          leftContent: 'Maximum gas',
          rightContent:
              '${gasDetails.maxFee.toEthWithDecimals()} $currencySymbol',
        ),
        BottomSheetInfoRow(
          context: navState.currentState!.context,
          leftContent:
              AppLocalizations.of(navState.currentState!.context)!.fromAddress,
          rightContent: shortenWalletAddress(
            selectedAddress.hex,
          ),
        ),
        if (to != null)
          BottomSheetInfoRow(
            context: navState.currentState!.context,
            leftContent:
                AppLocalizations.of(navState.currentState!.context)!.toAddress,
            rightContent: shortenWalletAddress(
              to.hex,
            ),
          ),
        if (readableAmount != null && symbol != null)
          BottomSheetInfoRow(
            context: navState.currentState!.context,
            leftContent:
                AppLocalizations.of(navState.currentState!.context)!.amount,
            rightContent: '$readableAmount $symbol',
          ),
        TextButton(
          onPressed: () {
            showEditGasFeeScreen(
              context: navState.currentState!.context,
              data: gasDetails,
              gasFeeDetailsBloc: _gasFeeDetailsBloc,
            );
          },
          child: const Text('Edit gas fee'),
        ),
        if (hasEnoughEth) confirmButton else ethBalanceWarning,
      ].addSeparator(kVerticalSpacer),
    );
  }

  String? _ethAmountValidator(String input, EthAccountBalanceItem balanceItem) {
    if (input.isNotEmpty) {
      return correctValueSyrius(
        input,
        balanceItem.balance,
        balanceItem.ethAsset.decimals,
        BigInt.zero,
      );
    }
    return null;
  }

  List<Widget> _buildEthereumTxSpeedListTiles({
    required EthereumTxGasDetailsData data,
  }) =>
      EthereumTxSpeed.values
          .map(
            (speed) => _buildEthereumTxSpeedListTile(
              evmTransactionSpeed: speed,
              onChangedCallback: (EthereumTxSpeed speed) {
                final EthereumTxGasDetailsData newData = data
                  ..speed = speed
                  ..userFee = data.fees[speed.index];
                _gasFeeDetailsBloc.update(newData);
              },
              selectedSpeed: data.speed,
            ),
          )
          .toList();

  Widget _buildEthereumTxSpeedListTile({
    required EthereumTxSpeed evmTransactionSpeed,
    required void Function(EthereumTxSpeed) onChangedCallback,
    required EthereumTxSpeed? selectedSpeed,
  }) {
    return RadioListTile<EthereumTxSpeed>(
      title: Text(evmTransactionSpeed.name.capitalize()),
      value: evmTransactionSpeed,
      groupValue: selectedSpeed,
      onChanged: (EthereumTxSpeed? value) {
        if (value != null) {
          onChangedCallback(value);
        }
      },
    );
  }
}
