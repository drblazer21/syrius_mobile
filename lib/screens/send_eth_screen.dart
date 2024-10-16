import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/blocs/transfer/eth_send_transaction_bloc.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:web3dart/web3dart.dart';

class SendEthScreen extends StatefulWidget {
  const SendEthScreen({super.key});

  @override
  State<SendEthScreen> createState() => _SendEthScreenState();
}

class _SendEthScreenState extends State<SendEthScreen> {
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _recipientFocusNode = FocusNode();

  String get _amount => _amountController.text;

  String get _recipient => _recipientController.text;

  final EthSendTransactionBloc _ethSendTransactionBloc =
      EthSendTransactionBloc();

  NetworkAsset _selectedAsset = kSelectedAppNetworkWithAssets!.assets.first;

  late EthAccountBalance _ethereumAccountBalance;
  late GasFeeDetailsBloc _gasFeeDetailsBloc;

  @override
  void initState() {
    super.initState();
    _gasFeeDetailsBloc = GasFeeDetailsBloc();
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
          : const SyriusErrorWidget('No tokens added'),
    );
  }

  AppStreamBuilder<EthAccountBalance> _buildNetworkWithAssetsBody() {
    return AppStreamBuilder<EthAccountBalance>(
      errorHandler: (a) {},
      stream: sl.get<EthAccountBalanceBloc>().stream,
      builder: (ethereumAccountBalance) {
        _ethereumAccountBalance = ethereumAccountBalance;
        return _buildBody(ethereumAccountBalance);
      },
      customErrorWidget: (String error) {
        return SyriusErrorWidget(error);
      },
      customLoadingWidget: const SyriusLoadingWidget(),
    );
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _recipientFocusNode.dispose();
    _amountController.dispose();
    _amountFocusNode.dispose();
    _ethSendTransactionBloc.dispose();
    super.dispose();
  }

  Widget _buildBody(EthAccountBalance ethAccountBalance) {
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
                      _buildTokenAndAmountInfo(context, ethAccountBalance),
                      kVerticalSpacer,
                      _buildToAddressInputField(
                        balanceItem: ethAccountBalance.findItem(
                          ethAsset: _selectedAsset,
                        ),
                      ),
                    ],
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
                ethAccountBalance.findItem(
                  ethAsset: _selectedAsset,
                ),
                context,
                _ethSendTransactionBloc,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTokenAndAmountInfo(
    BuildContext context,
    EthAccountBalance ethAccountBalance,
  ) {
    return EthAmountInfoCard(
      ethAccountBalance: ethAccountBalance,
      amountValidator: (value) => _ethAmountValidator(
        value,
        ethAccountBalance.findItem(ethAsset: _selectedAsset),
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

  Widget _buildToAddressInputField({
    required EthAccountBalanceItem balanceItem,
  }) {
    return RecipientAddressTextField(
      controller: _recipientController,
      context: context,
      focusNode: _recipientFocusNode,
      hintText: AppLocalizations.of(context)!.recipientAddress,
      onSubmitted: (value) {
        final void Function(String?)? callback =
            _hasBalanceAndInputIsValid(balanceItem)
                ? (_) => _fetchGasFeeAndShowConfirmationDialog()
                : null;

        callback?.call(value);
      },
    );
  }

  Widget _buildSendButton(
    EthAccountBalanceItem balanceItem,
    BuildContext context,
    EthSendTransactionBloc model,
  ) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _amountController,
        _recipientController,
      ]),
      builder: (_, __) => SyriusFilledButton(
        text: AppLocalizations.of(context)!.next,
        onPressed: _hasBalanceAndInputIsValid(balanceItem)
            ? _fetchGasFeeAndShowConfirmationDialog
            : null,
      ),
    );
  }

  Future<void> _fetchGasFeeAndShowConfirmationDialog() async {
    FocusScope.of(context).unfocus();
    _gasFeeDetailsBloc.addEvent(GasFeeDetailsLoading());
    _showConfirmTxBottomSheet();
    final Transaction tx = await eth.generateTx(
      amount: _amount.extractDecimals(_selectedAsset.decimals),
      ethAsset: _selectedAsset,
      toAddressHex: _recipient,
    );
    _gasFeeDetailsBloc.fetch(
      tx: tx,
    );
  }

  bool _hasBalanceAndInputIsValid(EthAccountBalanceItem item) =>
      _hasBalance(item.balance) && _isInputValid(item);

  Future<dynamic> _showConfirmTxBottomSheet() {
    return showModalBottomSheetWithBody(
      context: context,
      title: AppLocalizations.of(context)!.confirmTransaction,
      body: StreamBuilder(
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
                  gasDetails: loaded.ethereumTxGasDetailsData,
                  setState: setState,
                ),
              );
            case GasFeeDetailsError():
              final GasFeeDetailsError error =
                  snapshot.data! as GasFeeDetailsError;
              return SyriusErrorWidget(error.message);
          }
        },
      ),
    );
  }

  Column _buildConfirmTxBottomSheetBody({
    required EthereumTxGasDetailsData gasDetails,
    required StateSetter setState,
  }) {
    BigInt totalNeededEthForTx = gasDetails.maxFee.getInWei;

    if (_selectedAsset.isCurrency) {
      totalNeededEthForTx += gasDetails.tx.value!.getInWei;
    }

    final bool hasEnoughEth = _ethAmountValidator(
          totalNeededEthForTx.toStringWithDecimals(
            kEvmCurrencyDecimals,
          ),
          _ethereumAccountBalance.getCurrency(),
        ) ==
        null;

    final Widget subtitleWidget = Text(
      AppLocalizations.of(context)!.reviewTransaction,
      style: context.textTheme.titleSmall?.copyWith(
        color: context.colorScheme.secondary,
      ),
      textAlign: TextAlign.center,
    );

    final Widget confirmButton = SyriusFilledButton(
      text: AppLocalizations.of(context)!.confirm,
      onPressed: () {
        _onSendPaymentPressed(
          tx: gasDetails.txWithGasFee,
        );
      },
    );

    final Widget ethBalanceWarning = Text(
      'Not enough balance to cover the gas fees',
      style: TextStyle(
        color: context.colorScheme.error,
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
          context: context,
          leftContent: 'Estimated gas',
          rightContent:
              '${gasDetails.estimatedGas.toEthWithDecimals()} $currencySymbol',
        ),
        BottomSheetInfoRow(
          context: context,
          leftContent: 'Maximum gas',
          rightContent:
              '${gasDetails.maxFee.toEthWithDecimals()} $currencySymbol',
        ),
        BottomSheetInfoRow(
          context: context,
          leftContent: AppLocalizations.of(context)!.fromAddress,
          rightContent: shortenWalletAddress(selectedAddress.hex),
        ),
        BottomSheetInfoRow(
          context: context,
          leftContent: AppLocalizations.of(context)!.toAddress,
          rightContent: shortenWalletAddress(_recipient),
        ),
        BottomSheetInfoRow(
          context: context,
          leftContent: AppLocalizations.of(context)!.amount,
          rightContent: '$_amount ${_selectedAsset.symbol}',
        ),
        TextButton(
          onPressed: () async {
            showEditGasFeeScreen(
              context: context,
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

  bool _hasBalance(BigInt amount) => amount > BigInt.zero;

  bool _isInputValid(EthAccountBalanceItem item) =>
      checkAddress(_recipient) == null &&
      _ethAmountValidator(_amount, item) == null;

  void _onSendPaymentPressed({
    required Transaction tx,
  }) {
    Navigator.pop(context);
    _ethSendTransactionBloc.send(
      context: context,
      tx: tx,
    );
    _amountController.clear();
    _recipientController.clear();
    showTransactionInProgressBottomSheet(context: context);
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
