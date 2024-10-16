import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:eip1559/eip1559.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/eth_to_znn_quota.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:web3dart/web3dart.dart';

abstract class EthereumService {
  Future<void> dispose();

  Future<EthereumTxGasDetailsData> getGasDetails({
    required Transaction tx,
  });

  bool dataMatchesTransferTokenFunction({
    required Uint8List data,
  });

  Future<dynamic> estimateGas({
    required String from,
    required String to,
    Uint8List? data,
  });

  Future<void> initialize(String url);

  Future<EtherAmount> getBalance({required EthereumAddress address});

  Future<EtherAmount> getBaseFee();

  Future<ExtendedBlockInformation> getLatestBlockInformation();

  Future<EtherAmount> getGasPrice();

  Future<EvmNodeStats> getNodeStats();

  Future<Transaction> generateTx({
    required BigInt amount,
    required NetworkAsset ethAsset,
    required String toAddressHex,
  });

  Future<String> sendEthereumAssetTx({
    required Transaction tx,
    int? chainId,
  });

  Future<EthToZnnQuota> getAmountsOut({required BigInt weiAmount});

  Future<NetworkAssetsCompanion> getNetworkAsset({
    required String contractAddressHex,
  });

  Future<BigInt> getTokenBalance({
    required String addressHex,
    required String contractAddressHex,
  });

  Future<BigInt> getTokenDecimals({
    required String contractAddressHex,
  });

  Future<String> getTokenName({
    required String contractAddressHex,
  });

  Future<String> getTokenSymbol({
    required String contractAddressHex,
  });

  ContractFunction getTokenTransferFunction();

  Future<Uint8List> signTx({
    required int chainId,
    required Credentials cred,
    required Transaction transaction,
  });

  Future<String> swapExactETHForTokens({required SwapEthForZnnData data});

  Future<void> switchNetwork(String newUrl);
}

class EthereumServiceImpl implements EthereumService {
  Web3Client? _client;
  String? _currentUrl;

  ContractAbi? _tokenContractAbi;

  @override
  Future<void> initialize(String url) async {
    _client = Web3Client(url, Client());
    _currentUrl = url;
    await _initTokenContractAbi();
  }

  @override
  Future<void> switchNetwork(String newUrl) async {
    await dispose();
    await initialize(newUrl);
  }

  @override
  Future<void> dispose() async {
    await _client?.dispose();
    _currentUrl = null;
    _tokenContractAbi = null;
  }

  @override
  Future<dynamic> estimateGas({
    required String from,
    required String to,
    Uint8List? data,
  }) async {
    return _client!.estimateGas(
      sender: EthereumAddress.fromHex(from),
      to: EthereumAddress.fromHex(to),
      data: data,
    );
  }

  @override
  Future<EtherAmount> getBalance({
    required EthereumAddress address,
  }) =>
      _client!.getBalance(address);

  @override
  Future<EtherAmount> getBaseFee() async {
    final BlockInformation blockInfo = await _client!.getBlockInformation(
      blockNumber: const BlockNum.pending().toBlockParam(),
      isContainFullObj: false,
    );

    return blockInfo.baseFeePerGas!;
  }

  @override
  Future<ExtendedBlockInformation> getLatestBlockInformation() async {
    final RpcService jsonRpc = JsonRPC(_currentUrl!, Client());
    final RPCResponse rpcResponse = await jsonRpc.call(
      'eth_getBlockByNumber',
      [
        'latest',
        false,
      ],
    );

    return ExtendedBlockInformation.fromJson(
      rpcResponse.result as Map<String, dynamic>,
    );
  }

  @override
  Future<EtherAmount> getGasPrice() => _client!.getGasPrice();

  Future<void> _saveTransaction({
    required String hash,
  }) async {
    try {
      EthereumTransactionStatus txStatus = EthereumTransactionStatus.pending;

      final String currencySymbol =
          kSelectedAppNetworkWithAssets!.network.currencySymbol;

      TransactionReceipt? receipt;

      do {
        await Future.delayed(const Duration(seconds: 5));
        receipt = await _client!.getTransactionReceipt(hash);
      } while (receipt == null);

      if (receipt.status != null) {
        if (receipt.status!) {
          txStatus = EthereumTransactionStatus.done;
        } else {
          txStatus = EthereumTransactionStatus.failed;
          sendNotificationError(
            'Transaction failed',
            'Transaction with hash ${receipt.transactionHash} failed',
          );
        }

        final TransactionInformation? txInfo =
            await _client!.getTransactionByHash(hash);

        final BlockInformation blockInfo = await _client!.getBlockInformation(
          blockNumber: txInfo!.blockNumber.toBlockParam(),
          isContainFullObj: false,
        );

        await db.ethereumTxsDao.insert(
          info: txInfo,
          dateTime: blockInfo.timestamp,
          status: txStatus,
        );

        if (txStatus == EthereumTransactionStatus.done) {
          sendSuccessEthereumPaymentNotification(
            currencySymbol: currencySymbol,
            txInfo: txInfo,
          );
        }

        Timer(
          kEthereumBlockProductionInterval,
          () {
            sl.get<EthAccountBalanceBloc>().fetch(
                  address: kEthSelectedAddress!.toEthAddress(),
                );
          },
        );
      } else {
        // This will happen for EVM pre-Byzantium networks
        sendNotificationError(
          'Status missing from receipt',
          'No status found for transaction hash ${receipt.transactionHash}',
        );
      }
    } on Exception catch (e) {
      sendNotificationError(
        'Something went wrong saving the transaction details',
        e,
      );
    }
  }

  @override
  Future<EthToZnnQuota> getAmountsOut({required BigInt weiAmount}) async {
    final DeployedContract contract = await getContractFromAssets(
      path: 'assets/json/uniswap_proxy.json',
      // Router address
      contractAddress: '0x9A46DFf91035449699baD9E7BF14F9b2666B5270',
      contractName: 'uniswap_router',
    );

    final ContractFunction function = contract.function('getAmountsOut');

    final List<dynamic> result = await _client!.call(
      contract: contract,
      function: function,
      params: [
        weiAmount,
        [
          EthereumAddress.fromHex(kWethAddress),
          EthereumAddress.fromHex(kWznnAddress),
        ],
      ],
    );

    return EthToZnnQuota.fromList(result.first as List);
  }

  @override
  Future<String> swapExactETHForTokens({
    required SwapEthForZnnData data,
  }) async {
    final DeployedContract uniswap = await getContractFromAssets(
      path: 'assets/json/uniswap_proxy.json',
      contractAddress: kProxyAddress,
      contractName: 'uniswap_proxy',
    );
    final DeployedContract bridge = await getContractFromAssets(
      path: 'assets/json/bridge.json',
      contractAddress: kBridgeAddress,
      contractName: 'bridge',
    );

    final ContractFunction swapExactETHForTokens = uniswap.function(
      'swapExactETHForTokens',
    );
    final ContractFunction confirmationsToFinalityFunction = bridge.function(
      'confirmationsToFinality',
    );
    final ContractFunction estimatedBlockTimeFunction = bridge.function(
      'estimatedBlockTime',
    );

    final BlockInformation latestBlock = await _client!.getBlockInformation();

    const Duration deadlineOffset = Duration(minutes: 10);

    final Credentials credentials = await generateCredentials(
      address: selectedAddress.hex,
    );

    final BigInt confirmationsToFinality = (await _client!.call(
      contract: bridge,
      function: confirmationsToFinalityFunction,
      params: [],
    ))
        .first as BigInt;

    final BigInt estimatedBlockTime = (await _client!.call(
      contract: bridge,
      function: estimatedBlockTimeFunction,
      params: [],
    ))
        .first as BigInt;

    final int latestBlockTimestampSeconds =
        latestBlock.timestamp.millisecondsSinceEpoch ~/ 1000;

    final BigInt deadline = BigInt.from(latestBlockTimestampSeconds) +
        confirmationsToFinality * estimatedBlockTime +
        BigInt.from(deadlineOffset.inSeconds);

    final BigInt slippageAmount = BigInt.from(
      data.quota!.znn * BigInt.from(data.slippage) / BigInt.from(100),
    );

    final Transaction transaction = Transaction.callContract(
      contract: uniswap,
      from: credentials.address,
      function: swapExactETHForTokens,
      value: EtherAmount.fromBigInt(EtherUnit.wei, data.quota!.wei),
      parameters: [
        data.quota!.znn - slippageAmount,
        [
          EthereumAddress.fromHex(kWethAddress),
          EthereumAddress.fromHex(kWznnAddress),
        ],
        EthereumAddress.fromHex(data.fromEthAddress!),
        deadline,
        data.toZnnAddress,
      ],
    );

    final String hash = await _client!.sendTransaction(
      credentials,
      transaction,
      chainId: kSelectedAppNetworkWithAssets!.network.chainId,
    );

    _saveTransaction(
      hash: hash,
    );

    return hash;
  }

  @override
  Future<String> sendEthereumAssetTx({
    required Transaction tx,
    int? chainId,
  }) async {
    try {
      final Credentials credentials = await generateCredentials(
        address: tx.from!.hex,
      );

      final String hash = await _client!.sendTransaction(
        credentials,
        tx,
        chainId: chainId ?? kSelectedAppNetworkWithAssets!.network.chainId,
      );

      _saveTransaction(
        hash: hash,
      );

      return hash;
    } catch (e) {
      throw 'Transaction failed: $e';
    }
  }

  @override
  Future<Transaction> generateTx({
    required BigInt amount,
    required NetworkAsset ethAsset,
    required String toAddressHex,
  }) async {
    final Credentials credentials = await generateCredentials(
      address: selectedAddress.hex,
    );

    Transaction? transaction;

    if (ethAsset.isCurrency) {
      transaction = Transaction(
        from: credentials.address,
        to: EthereumAddress.fromHex(toAddressHex),
        value: EtherAmount.fromBigInt(EtherUnit.wei, amount),
      );
    } else {
      final DeployedContract contract = await getContractFromAssets(
        path: 'assets/json/token.json',
        contractAddress: ethAsset.contractAddressHex!,
        contractName: 'token',
      );
      final ContractFunction function = contract.function('transfer');

      transaction = Transaction.callContract(
        contract: contract,
        from: credentials.address,
        function: function,
        parameters: [
          EthereumAddress.fromHex(toAddressHex),
          amount,
        ],
      );
    }

    return transaction;
  }

  @override
  Future<BigInt> getTokenBalance({
    required String addressHex,
    required String contractAddressHex,
  }) async {
    final DeployedContract contract = await getContractFromAssets(
      path: 'assets/json/token.json',
      contractAddress: contractAddressHex,
      contractName: 'token',
    );

    final ContractFunction function = contract.function('balanceOf');

    final List<dynamic> result = await _client!.call(
      contract: contract,
      function: function,
      params: [
        EthereumAddress.fromHex(addressHex),
      ],
    );

    return result.first as BigInt;
  }

  @override
  Future<BigInt> getTokenDecimals({
    required String contractAddressHex,
  }) async {
    final ContractFunction function = _tokenContractAbi!.functions.singleWhere(
      (f) => f.name == 'decimals',
    );

    final List<dynamic> result = await callContractFunctionRaw(
      contractAddress: EthereumAddress.fromHex(contractAddressHex),
      function: function,
      params: [],
    );

    return result.first as BigInt;
  }

  @override
  Future<String> getTokenName({
    required String contractAddressHex,
  }) async {
    final ContractFunction function = _tokenContractAbi!.functions.singleWhere(
      (f) => f.name == 'name',
    );

    final List<dynamic> result = await callContractFunctionRaw(
      contractAddress: EthereumAddress.fromHex(contractAddressHex),
      function: function,
      params: [],
    );

    return result.first as String;
  }

  @override
  Future<String> getTokenSymbol({
    required String contractAddressHex,
  }) async {
    final ContractFunction function = _tokenContractAbi!.functions.singleWhere(
      (f) => f.name == 'symbol',
    );

    final List<dynamic> result = await callContractFunctionRaw(
      contractAddress: EthereumAddress.fromHex(contractAddressHex),
      function: function,
      params: [],
    );

    return result.first as String;
  }

  @override
  Future<NetworkAssetsCompanion> getNetworkAsset({
    required String contractAddressHex,
  }) async {
    final List<dynamic> result = await Future.wait([
      getTokenDecimals(contractAddressHex: contractAddressHex),
      getTokenName(contractAddressHex: contractAddressHex),
      getTokenSymbol(contractAddressHex: contractAddressHex),
    ]);

    return NetworkAssetsCompanion.insert(
      decimals: (result[0] as BigInt).toInt(),
      isCurrency: false,
      name: Value(result[1] as String),
      network: kSelectedAppNetworkWithAssets!.network.id,
      symbol: result[2] as String,
    );
  }

  @override
  Future<EthereumTxGasDetailsData> getGasDetails({
    required Transaction tx,
  }) async {
    BigInt? gasLimit;

    // Tx from dApp might already have a maxGas value
    if (tx.maxGas != null) {
      gasLimit = BigInt.from(tx.maxGas!);
    } else {
      gasLimit = await _client!.estimateGas(
        sender: tx.from,
        to: tx.to,
        value: tx.value,
        data: tx.data,
      );
    }

    final List<Fee> gasEIP = await _client!.getGasInEIP1559();

    return EthereumTxGasDetailsData(
      fees: gasEIP,
      gasLimit: gasLimit,
      tx: tx,
    );
  }

  static Future<DeployedContract> getContractFromAssets({
    required String path,
    required String contractAddress,
    required String contractName,
  }) async {
    final Map<String, dynamic> contractJson = jsonDecode(
      await rootBundle.loadString(path),
    ) as Map<String, dynamic>;

    return DeployedContract(
      ContractAbi.fromJson(
        jsonEncode(contractJson['abi']),
        contractName,
      ),
      EthereumAddress.fromHex(contractAddress),
    );
  }

  /// This function handles the situation when the RPC eth_call returns an
  /// empty string. A situation when this might arise is when you want to get
  /// the details of a token, but it's contract address is not found on the
  /// network or is not a valid contract address
  Future<List> callContractFunctionRaw({
    EthereumAddress? sender,
    required EthereumAddress contractAddress,
    required ContractFunction function,
    required List<dynamic> params,
    BlockNum? atBlock,
  }) async {
    final encodedResult = await _client!.callRaw(
      sender: sender,
      contract: contractAddress,
      data: function.encodeCall(params),
      atBlock: atBlock,
    );

    // Checking if the response is an empty string
    if (encodedResult == '0x') {
      throw 'Contract address was not found';
    }

    return function.decodeReturnValues(encodedResult);
  }

  Future<ContractAbi> _buildTokenContractAbi() async {
    final Map<String, dynamic> contractJson = jsonDecode(
      await rootBundle.loadString('assets/json/token.json'),
    ) as Map<String, dynamic>;

    return ContractAbi.fromJson(
      jsonEncode(contractJson['abi']),
      'token',
    );
  }

  Future<void> _initTokenContractAbi() async {
    _tokenContractAbi ??= await _buildTokenContractAbi();
  }

  @override
  bool dataMatchesTransferTokenFunction({
    required Uint8List data,
  }) {
    final ContractFunction function = _tokenContractAbi!.functions.singleWhere(
      (f) => f.name == 'transfer',
    );

    final Uint8List functionIdentifier = data.sublist(0, 4);
    return functionIdentifier.equals(function.selector);
  }

  @override
  ContractFunction getTokenTransferFunction() =>
      _tokenContractAbi!.functions.singleWhere(
        (f) => f.name == 'transfer',
      );

  @override
  Future<Uint8List> signTx({
    required int chainId,
    required Credentials cred,
    required Transaction transaction,
  }) {
    return _client!.signTransaction(cred, transaction, chainId: chainId);
  }

  @override
  Future<EvmNodeStats> getNodeStats() async {
    final List<dynamic> data = await Future.wait([
      _client!.getBlockNumber(),
      _client!.getClientVersion(),
      _client!.getChainId(),
      _client!.getNetworkId(),
      _client!.getPeerCount(),
    ]);

    final int blockNumber = data[0] as int;
    final String clientVersion = data[1] as String;
    final BigInt chainId = data[2] as BigInt;
    final int networkId = data[3] as int;
    final int peerCount = data[4] as int;

    return EvmNodeStats(
      blockNumber: blockNumber,
      clientVersion: clientVersion,
      chainId: chainId,
      networkId: networkId,
      peerCount: peerCount,
    );
  }

  void sendSuccessEthereumPaymentNotification({
    required TransactionInformation txInfo,
    required String currencySymbol,
  }) {
    final bool isContractInteraction = txInfo.input.isNotEmpty;
    final String sender = txInfo.from.hex;
    final String hash = txInfo.hash;

    if (isContractInteraction) {
      sl.get<NotificationsService>().addNotification(
            WalletNotificationsCompanion.insert(
              title: 'Sent transaction from $sender',
              details: 'Hash: $hash',
              type: NotificationType.paymentSent,
            ),
          );
    } else {
      final String recipient = txInfo.to!.hex;
      final String amount = txInfo.value.toEthWithDecimals();
      final String senderLabel = getLabel(sender);

      sl.get<NotificationsService>().addNotification(
            WalletNotificationsCompanion.insert(
              title: 'Sent $amount $currencySymbol '
                  'from $senderLabel',
              details: 'To $recipient with hash: $hash',
              type: NotificationType.paymentSent,
            ),
          );
    }
  }
}
