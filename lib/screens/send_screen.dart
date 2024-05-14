import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/extensions/extensions.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _recipientFocusNode = FocusNode();

  Token _selectedToken = kDualCoin.first;

  String get _amount => _amountController.text;
  String get _recipient => _recipientController.text;

  SendPaymentBloc _sendPaymentBloc = SendPaymentBloc();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        Timer(
            const Duration(
              milliseconds: 200,
            ), () {
          refreshBalanceAndTx();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final address = getAddress();
    final shortAddress = shortenWalletAddress(address);
    final appBarTitle =
        '${AppLocalizations.of(context)!.sendScreenTitle} $shortAddress';

    return CustomAppbarScreen(
      appbarTitle: appBarTitle,
      child: AppStreamBuilder<Map<String, AccountInfo>?>(
        errorHandler: (a) {},
        stream: sl.get<BalanceBloc>().stream,
        builder: (snapshot) {
          final AccountInfo accountInfo = snapshot![kSelectedAddress]!;
          return _buildBody(accountInfo);
        },
        customErrorWidget: (String error) {
          return SyriusErrorWidget(error);
        },
        customLoadingWidget: const SyriusLoadingWidget(),
      ),
    );
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _recipientFocusNode.dispose();
    _amountController.dispose();
    _amountFocusNode.dispose();
    _sendPaymentBloc.dispose();
    super.dispose();
  }

  Widget _buildBody(AccountInfo accountInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTokenAndAmountInfo(context, accountInfo),
                kVerticalSpacer,
                _buildToAddressInputField(
                  accountInfo: accountInfo,
                  model: _sendPaymentBloc,
                ),
                kVerticalSpacer,
                GenericPagePlasmaInfo(
                  accountInfo: accountInfo,
                ),
              ],
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSendBlocWithWidget(context, accountInfo),
          ],
        ),
      ],
    );
  }

  Widget _buildTokenAndAmountInfo(
    BuildContext context,
    AccountInfo accountInfo,
  ) {
    return AmountInfoCard(
      accountInfo: accountInfo,
      amountValidator: (amount) => correctValueSyrius(
        amount,
        accountInfo.getBalance(
          _selectedToken.tokenStandard,
        ),
        _selectedToken.decimals,
        BigInt.zero,
      ),
      controller: _amountController,
      focusNode: _amountFocusNode,
      onTokenDropdownPressed: () {
        showTokenListScreen(
          context: context,
          onSelect: (selectedToken) {
            setState(() {
              _amountController.clear();
              _selectedToken = selectedToken;
            });
          },
          accountInfo: accountInfo,
          selectedToken: _selectedToken,
        );
      },
      recipientFocusNode: _recipientFocusNode,
      selectedToken: _selectedToken,
      requiredInteger: false,
    );
  }

  Widget _buildToAddressInputField({
    required AccountInfo accountInfo,
    required SendPaymentBloc? model,
  }) {
    return RecipientAddressTextField(
      controller: _recipientController,
      context: context,
      focusNode: _recipientFocusNode,
      hintText: AppLocalizations.of(context)!.recipientAddress,
      onSubmitted: (value) {
        final void Function(String?)? callback =
            _hasBalanceAndInputIsValid(accountInfo)
                ? (_) => _showConfirmTxBottomSheet(model!)
                : null;

        callback?.call(value);
      },
    );
  }

  Widget _buildSendBlocWithWidget(
    BuildContext context,
    AccountInfo accountInfo,
  ) {
    return ViewModelBuilder<SendPaymentBloc>.reactive(
      onViewModelReady: (model) {
        _sendPaymentBloc = model;
      },
      builder: (_, model, __) {
        return _buildSendButton(accountInfo, context, model);
      },
      viewModelBuilder: () => SendPaymentBloc(),
    );
  }

  Widget _buildSendButton(
    AccountInfo accountInfo,
    BuildContext context,
    SendPaymentBloc model,
  ) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _amountController,
        _recipientController,
      ]),
      builder: (_, __) => SyriusFilledButton(
        text: AppLocalizations.of(context)!.send,
        onPressed: _hasBalanceAndInputIsValid(accountInfo)
            ? () {
                _showConfirmTxBottomSheet(model);
              }
            : null,
      ),
    );
  }

  bool _hasBalanceAndInputIsValid(AccountInfo accountInfo) =>
      _hasBalance(accountInfo) && _isInputValid(accountInfo);

  Future<dynamic> _showConfirmTxBottomSheet(SendPaymentBloc model) {
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
        _onSendPaymentPressed(model);
      },
    );

    return showModalBottomSheetWithBody(
      context: context,
      title: AppLocalizations.of(context)!.confirmTransaction,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          subtitleWidget,
          BottomSheetInfoRow(
            context: context,
            leftContent: AppLocalizations.of(context)!.fromAddress,
            rightContent: shortenWalletAddress(kSelectedAddress!),
          ),
          BottomSheetInfoRow(
            context: context,
            leftContent: AppLocalizations.of(context)!.toAddress,
            rightContent: shortenWalletAddress(_recipient),
          ),
          BottomSheetInfoRow(
            context: context,
            leftContent: AppLocalizations.of(context)!.amount,
            rightContent: '$_amount ${_selectedToken.symbol}',
          ),
          confirmButton,
        ].addSeparator(kVerticalSpacer),
      ),
    );
  }

  bool _hasBalance(AccountInfo accountInfo) =>
      accountInfo.getBalance(
        _selectedToken.tokenStandard,
      ) >
      BigInt.zero;

  bool _isInputValid(AccountInfo accountInfo) =>
      checkAddress(_recipient) == null &&
      correctValueSyrius(
            _amount,
            accountInfo.getBalance(
              _selectedToken.tokenStandard,
            ),
            _selectedToken.decimals,
            BigInt.zero,
          ) ==
          null;

  void _onSendPaymentPressed(SendPaymentBloc model) {
    Navigator.pop(context);
    model.sendTransfer(
      context: context,
      fromAddress: kSelectedAddress!,
      toAddress: _recipient,
      amount: _amount.extractDecimals(_selectedToken.decimals),
      token: _selectedToken,
    );
    _amountController.clear();
    _recipientController.clear();
  }
}
