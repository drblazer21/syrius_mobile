import 'dart:async';

import 'package:big_decimal/big_decimal.dart';
import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/btc/bitcoin_utils.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/send/utxo_widget.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class SendBtcScreen extends StatefulWidget {
  const SendBtcScreen({super.key});

  @override
  State<SendBtcScreen> createState() => _SendBtcScreenState();
}

class _SendBtcScreenState extends State<SendBtcScreen> {
  final BtcSendTransactionBloc _sendBloc = BtcSendTransactionBloc();

  final TextEditingController _changeAddressController =
      TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _lockTimeController = TextEditingController();

  final FocusNode _changeAddressFocusNode = FocusNode();
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _recipientFocusNode = FocusNode();
  final FocusNode _lockTimeFocusNode = FocusNode();

  String get _amount => _amountController.text;

  String get _recipient => _recipientController.text;

  String get _lockTime => _lockTimeController.text;

  String get _finalChangeAddress => _dropdownChangeAddress.id == 0
      ? _changeAddressController.text
      : _dropdownChangeAddress.hex;

  NetworkAsset _selectedAsset = kSelectedAppNetworkWithAssets!.assets.first;

  late BtcAccountBalance _btcAccountBalance;
  final UtxosBloc _utxosBloc = UtxosBloc();
  final BtcTxFeeDetailsBloc _btcTxFeeDetailsBloc = BtcTxFeeDetailsBloc();

  final List<UtxoWithAddress> _selectedUtxos = [];
  late BitcoinFeeRate _fees;
  BitcoinFeeRateType? _selectedBitcoinFeeRateType = BitcoinFeeRateType.medium;
  bool _enableRbf = true;
  late double _userFeePerByte;
  AppAddress _dropdownChangeAddress = selectedAddress;
  final List<AppAddress> _dropdownAddressList = [];

  @override
  void initState() {
    super.initState();
    _sendBloc.stream.listen(
      (hash) {
        _popTwice();
        _sendSuccessPaymentNotification(hash: hash);
        _amountController.clear();
        _recipientController.clear();
      },
      onError: (error) {
        _popTwice();
        sendNotificationError(
          'Something went wrong while executing the Bitcoin transfer',
          error,
        );
      },
    );
    _dropdownAddressList.add(
      // Dummy address - when it's selected, a text field will appear
      const AppAddress(
        id: 0,
        index: 0,
        blockChain: BlockChain.btc,
        hex: 'Custom change address',
        label: 'Custom change address',
      ),
    );
    _dropdownAddressList.addAll(addressList);
    _btcTxFeeDetailsBloc.fetchFees();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        Timer(
            const Duration(
              milliseconds: 200,
            ), () {
          refreshBlocs();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final address = selectedAddress;
    final shortAddress = shortenWalletAddress(address.hex);
    final appBarTitle =
        '${AppLocalizations.of(context)!.sendScreenTitle} $shortAddress';

    return CustomAppbarScreen(
      appbarTitle: appBarTitle,
      withLateralPadding: false,
      child: kSelectedAppNetworkWithAssets!.assets.isNotEmpty
          ? _buildNetworkWithAssetsBody()
          : const SyriusErrorWidget('No currencies added'),
    );
  }

  AppStreamBuilder<BtcAccountBalance> _buildNetworkWithAssetsBody() {
    return AppStreamBuilder<BtcAccountBalance>(
      errorHandler: (a) {},
      stream: sl.get<BtcAccountBalanceBloc>().stream,
      builder: (btcAccountBalance) {
        _btcAccountBalance = btcAccountBalance;
        return _buildBody(btcAccountBalance);
      },
      customErrorWidget: (String error) {
        return SyriusErrorWidget(error);
      },
      customLoadingWidget: const SyriusLoadingWidget(),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    _btcTxFeeDetailsBloc.dispose();
    _changeAddressController.dispose();
    _changeAddressFocusNode.dispose();
    _lockTimeController.dispose();
    _lockTimeFocusNode.dispose();
    _recipientController.dispose();
    _recipientFocusNode.dispose();
    _sendBloc.dispose();
    super.dispose();
  }

  Widget _buildBody(BtcAccountBalance btcAccountBalance) {
    const EdgeInsets horizontalEdgeInsets = EdgeInsets.symmetric(
      horizontal: kHorizontalPagePaddingDimension,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: horizontalEdgeInsets,
                  child: Column(
                    children: [
                      _buildTokenAndAmountInfo(context, btcAccountBalance),
                      _buildToAddressInputField(),
                      _buildChangeAddressDropdownMenu(),
                      Visibility(
                        visible: _dropdownChangeAddress.id == 0,
                        child: _buildChangeAddressTextField(),
                      ),
                    ].addSeparator(kVerticalSpacer),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: horizontalEdgeInsets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSendButton(
                context,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTokenAndAmountInfo(
    BuildContext context,
    BtcAccountBalance btcAccountBalance,
  ) {
    return BtcAmountInfoCard(
      btcAccountBalance: btcAccountBalance,
      amountValidator: (value) => _btcAmountValidator(
        value,
      ),
      controller: _amountController,
      focusNode: _amountFocusNode,
      onEthAssetSelected: (NetworkAsset? ethAsset) {
        if (ethAsset != null) {
          setState(() {
            _selectedAsset = ethAsset;
          });
        }
      },
      selectedEthAsset: _selectedAsset,
      recipientFocusNode: _recipientFocusNode,
      requiredInteger: false,
    );
  }

  Widget _buildToAddressInputField() {
    return RecipientAddressTextField(
      controller: _recipientController,
      context: context,
      focusNode: _recipientFocusNode,
      hintText: AppLocalizations.of(context)!.recipientAddress,
      onSubmitted: (value) {},
    );
  }

  Widget _buildSendButton(
    BuildContext context,
  ) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _amountController,
        _changeAddressController,
        _recipientController,
      ]),
      builder: (_, __) => SyriusFilledButton(
        text: AppLocalizations.of(context)!.next,
        onPressed: _hasBalanceAndInputIsValid() ? _showUtxos : null,
      ),
    );
  }

  bool _hasBalanceAndInputIsValid() =>
      _hasBalance(_btcAccountBalance.confirmed) && _isInputValid();

  bool _hasBalance(BigInt amount) => amount > BigInt.zero;

  bool _isInputValid() =>
      checkAddress(_recipient) == null &&
      _btcAmountValidator(_amount) == null &&
      lockTimeValidator(_lockTime) == null &&
      checkAddress(_finalChangeAddress) == null;

  String? _btcAmountValidator(String input) {
    if (input.isNotEmpty) {
      return correctValueSyrius(
        input,
        _btcAccountBalance.confirmed,
        kBtcDecimals,
        BigInt.zero,
      );
    }
    return null;
  }

  Future<dynamic> _showUtxos() {
    _utxosBloc.fetch(addressHex: selectedAddress.hex);
    FocusScope.of(context).unfocus();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setState) {
                final StreamBuilder streamBuilder = _getUtxosStreamBuilder(
                  scrollController: scrollController,
                  setState: setState,
                );

                return SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      Text(
                        'UTXOs',
                        style: context.textTheme.titleLarge,
                      ),
                      streamBuilder,
                    ].addSeparator(
                      kVerticalSpacer,
                      addAfterLastItem: true,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  StreamBuilder _getUtxosStreamBuilder({
    required ScrollController scrollController,
    required StateSetter setState,
  }) {
    final Widget utxosStreamBuilder = StreamBuilder(
      initialData: UtxosStateInitialState(),
      stream: _utxosBloc.stream,
      builder: (_, snapshot) {
        switch (snapshot.data!) {
          case UtxosStateInitialState():
            return const SyriusLoadingWidget();
          case UtxosStateLoading():
            return const SyriusLoadingWidget();
          case UtxosStateLoaded():
            final UtxosStateLoaded loaded = snapshot.data! as UtxosStateLoaded;
            final List<UtxoWithAddress> items = loaded.utxos;
            return Column(
              children: [
                ListView.builder(
                  itemCount: items.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final UtxoWithAddress utxo = items[index];

                    final Iterable<String> txIds = _selectedUtxos.map(
                      (e) => e.utxo.txHash,
                    );

                    final bool isSelected = txIds.contains(utxo.utxo.txHash);

                    return UtxoWidget(
                      isSelected: isSelected,
                      onChanged: (isSelected) {
                        setState(() {
                          if (isSelected) {
                            _selectedUtxos.add(utxo);
                          } else {
                            final int index =
                                txIds.toList().indexOf(utxo.utxo.txHash);

                            _selectedUtxos.removeAt(index);
                          }
                        });
                      },
                      utxo: utxo,
                    );
                  },
                ),
                CheckboxListTile.adaptive(
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Row(
                    children: [
                      Text('Enable RBF'),
                      kIconAndTextHorizontalSpacer,
                      Tooltip(
                        message:
                            'RBF (Replace-by-Fee) is a transaction feature that allows a sender to replace a pending transaction with a new one that has a higher fee, to speed up the confirmation process.',
                        child: Icon(Icons.info_outline),
                      ),
                    ],
                  ),
                  value: _enableRbf,
                  onChanged: (bool? enableRbf) {
                    if (enableRbf != null) {
                      setState(() {
                        _enableRbf = enableRbf;
                      });
                    }
                  },
                ),
                BtcTxPriorityList(
                  onChangedCallback: (btcTxPriority) {
                    setState(() {
                      _selectedBitcoinFeeRateType = btcTxPriority;
                    });
                  },
                  selectedBtcTxPriority: _selectedBitcoinFeeRateType,
                ),
                _buildAmountsAndConfirmButton(setState),
              ],
            );
          case UtxosStateError():
            final UtxosStateError error = snapshot.data! as UtxosStateError;
            return SyriusErrorWidget(error.message);
        }
      },
    );

    return StreamBuilder<BtcTxFeeDetailsState>(
      initialData: BtcTxFeeDetailsInitial(),
      stream: _btcTxFeeDetailsBloc.stream,
      builder: (_, snapshot) {
        switch (snapshot.data!) {
          case BtcTxFeeDetailsInitial _:
            return const SyriusLoadingWidget();
          case BtcTxFeeDetailsLoading _:
            return const SyriusLoadingWidget();
          case BtcTxFeeDetailsLoaded _:
            final BtcTxFeeDetailsLoaded loaded =
                snapshot.data! as BtcTxFeeDetailsLoaded;
            _fees = loaded.data;
            return utxosStreamBuilder;
          case BtcTxFeeDetailsError _:
            final BtcTxFeeDetailsError error =
                snapshot.data! as BtcTxFeeDetailsError;
            return SyriusErrorWidget(error.message);
        }
      },
    );
  }

  Widget _buildAmountsAndConfirmButton(StateSetter seState) {
    final int estimatedTxSizeInBytes = _getTxEstimatedSizeInBytes();
    final double feePerByte;

    if (_selectedBitcoinFeeRateType != null) {
      final BigInt networkEstimateFeePerKb;

      switch (_selectedBitcoinFeeRateType) {
        case BitcoinFeeRateType.low:
          networkEstimateFeePerKb = _fees.low;
        case BitcoinFeeRateType.medium:
          networkEstimateFeePerKb = _fees.medium;
        default:
          networkEstimateFeePerKb = _fees.high;
      }

      final double networkEstimateFeePerByte =
          networkEstimateFeePerKb / BigInt.from(1024);

      feePerByte = networkEstimateFeePerByte;
    } else {
      feePerByte = _userFeePerByte;
    }

    // In the end, the fee will be an integer
    final BigInt fee = (BigDecimal.parse(estimatedTxSizeInBytes.toString()) *
            BigDecimal.parse(
              feePerByte.toString(),
            ))
        .toBigInt(
      roundingMode: RoundingMode.DOWN,
    );
    final BigInt selectedValue = _selectedUtxos.sumOfUtxosValue();
    final BigInt transferValue = BtcUtils.toSatoshi(_amount);
    final BigInt neededValue = transferValue + fee;
    final BigInt difference = neededValue - selectedValue;
    final String value = difference.toStringWithDecimals(kBtcDecimals);
    final bool enoughUtxosSelected = difference <= BigInt.zero;
    final bool hasSegwit = _selectedUtxos.any((utxo) => utxo.utxo.isSegwit());

    final Widget confirmButton = SyriusFilledButton(
      text: AppLocalizations.of(context)!.confirm,
      onPressed: enoughUtxosSelected
          ? () {
              _sendBtc(estimatedFee: fee);
            }
          : null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextButton.icon(
          icon: const Icon(Icons.edit),
          iconAlignment: IconAlignment.end,
          label: Text(
            '$feePerByte sats/${hasSegwit ? 'vB' : 'byte'}',
            textAlign: TextAlign.center,
          ),
          onPressed: () async {
            final dynamic result = await showEditBtcTxFeePerByt(
              balance: _btcAccountBalance.confirmed,
              context: context,
              feePerByte: feePerByte,
              txValue: transferValue,
              txSize: estimatedTxSizeInBytes,
            );

            if (result != null) {
              _selectedBitcoinFeeRateType = null;
              seState(() {
                _userFeePerByte = result as double;
              });
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: kHorizontalPagePaddingDimension,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BottomSheetInfoRow(
                context: context,
                leftContent: 'Transfer value',
                rightContent: _amount,
              ),
              BottomSheetInfoRow(
                context: context,
                leftContent: 'Estimated fee value',
                rightContent: fee.toString(),
              ),
              Visibility(
                visible: !enoughUtxosSelected,
                child: BottomSheetInfoRow(
                  context: context,
                  leftContent: 'Required balance',
                  rightContent: value,
                ),
              ),
              confirmButton,
            ].addSeparator(kVerticalSpacer),
          ),
        ),
      ],
    );
  }

  int _getTxEstimatedSizeInBytes() {
    final BitcoinBaseAddress changeAddress = generateTestnetBitcoinBaseAddress(
      addressHex: _finalChangeAddress,
    );

    // We need to add this changeOutput to get the correct tx size estimation
    final BitcoinOutput dummyChangeOutput = BitcoinOutput(
      address: changeAddress,
      value: BigInt.zero,
    );

    final int estimatedSize = BitcoinTransactionBuilder.estimateTransactionSize(
      utxos: _selectedUtxos,
      outputs: [
        _getOutput(),
        dummyChangeOutput,
      ],
      network: BitcoinNetwork.testnet,
      enableRBF: _enableRbf,
    );

    return estimatedSize;
  }

  BitcoinOutput _getOutput() {
    final BigInt value = BtcUtils.toSatoshi(_amount);

    final BitcoinBaseAddress receiver = generateTestnetBitcoinBaseAddress(
      addressHex: _recipient,
    );

    return BitcoinOutput(
      address: receiver,
      value: value,
    );
  }

  Future<void> _sendBtc({
    required BigInt estimatedFee,
  }) async {
    showLoadingDialog(context);
    _sendBloc.send(
      amount: _amount,
      changeAddress: _finalChangeAddress,
      context: context,
      enableRbf: _enableRbf,
      estimatedFee: estimatedFee,
      recipient: _recipient,
      utxos: _selectedUtxos,
    );
  }

  // TODO: to be used when the package bitcoin_base will offer a way to
  // override the lock time before the signature of the transaction is generated
  Widget _buildLockTimeTextField() {
    return LockTimeTextField(
      controller: _lockTimeController,
      context: context,
      focusNode: _lockTimeFocusNode,
      onSubmitted: (value) {
        final void Function(String?)? callback =
            _hasBalanceAndInputIsValid() ? (_) => _showUtxos() : null;

        callback?.call(value);
      },
      hintText: 'Lock Time',
    );
  }

  Widget _buildChangeAddressDropdownMenu() {
    return ChangeAddressDropdownMenu(
      addresses: _dropdownAddressList,
      initialSelection: _dropdownChangeAddress,
      onSelected: (AppAddress? appAddress) {
        if (appAddress != null) {
          setState(() {
            _dropdownChangeAddress = appAddress;
          });
        }
      },
    );
  }

  Widget _buildChangeAddressTextField() {
    return ChangeAddressTextField(
      controller: _changeAddressController,
      context: context,
      focusNode: _changeAddressFocusNode,
      onSubmitted: (_) {
        if (_hasBalanceAndInputIsValid()) {
          _showUtxos();
        }
      },
      hintText: 'Change address',
    );
  }

  void _popTwice() {
    if (!mounted) return;
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void _sendSuccessPaymentNotification({required String hash}) {
    sl.get<NotificationsService>().addNotification(
          WalletNotificationsCompanion.insert(
            title: 'Sent $_amount ${_selectedAsset.symbol} to $_recipient',
            details: 'Hash: $hash',
            type: NotificationType.paymentSent,
          ),
        );
    showTransactionInProgressBottomSheet(context: context);
  }
}
