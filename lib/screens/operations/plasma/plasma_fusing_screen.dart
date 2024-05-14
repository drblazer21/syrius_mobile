import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import 'package:stacked/stacked.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/screens/screens.dart';
import 'package:syrius_mobile/utils/extensions/extensions.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class PlasmaFusingScreen extends StatefulWidget {
  const PlasmaFusingScreen({
    super.key,
  });

  @override
  State<PlasmaFusingScreen> createState() => _PlasmaFusingScreenState();
}

class _PlasmaFusingScreenState extends State<PlasmaFusingScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _recipientFocusNode = FocusNode();
  PlasmaOptionsBloc? _plasmaOptionsBloc;

  bool isButtonEnabled(AccountInfo accountInfo) =>
      _hasBalance(accountInfo) && _isInputValid(accountInfo);

  @override
  void initState() {
    super.initState();
    _recipientController.text = kDefaultAddressList.first;
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.plasmaScreenTitle,
      withLateralPadding: false,
      child: StreamBuilder<Map<String, AccountInfo>?>(
        stream: sl.get<BalanceBloc>().stream,
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            return SyriusErrorWidget(snapshot.error!);
          }
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              Logger('PlasmaFusingPage').log(Level.INFO, snapshot.data);
              return _getBody(
                context,
                snapshot.data![kSelectedAddress!]!,
              );
            }
            return const SyriusLoadingWidget();
          }
          return const SyriusLoadingWidget();
        },
      ),
    );
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _amountFocusNode.dispose();
    _recipientFocusNode.dispose();
    _plasmaOptionsBloc?.dispose();
    super.dispose();
  }

  Widget _getBody(BuildContext context, AccountInfo accountInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: context.listTileTheme.contentPadding!,
          child: Column(
            children: [
              _buildTokenAndAmountInfo(context, accountInfo),
              _buildToAddressInputField(accountInfo),
              _buildFusingInfo(context),
            ].addSeparator(kVerticalSpacer),
          ),
        ),
        kVerticalSpacer,
        const Expanded(
          child: PlasmaListWidget(),
        ),
        Padding(
          padding: context.listTileTheme.contentPadding!,
          child: _buildFuseBlocWithWidget(context, accountInfo),
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
          kQsrCoin.tokenStandard,
        ),
        kQsrCoin.decimals,
        fuseMinQsrAmount,
        canBeEqualToMin: true,
      ),
      controller: _amountController,
      focusNode: _amountFocusNode,
      recipientFocusNode: _recipientFocusNode,
      selectedToken: kQsrCoin,
      requiredInteger: true,
    );
  }

  Widget _buildToAddressInputField(AccountInfo accountInfo) {
    return RecipientAddressTextField(
      controller: _recipientController,
      context: context,
      focusNode: _recipientFocusNode,
      hintText: AppLocalizations.of(context)!.beneficiaryAddress,
      onSubmitted: (value) {
        final void Function(String?)? callback = isButtonEnabled(accountInfo)
            ? (_) => _showFuseConfirmationBottomSheet(context)
            : null;

        callback?.call(value);
      },
    );
  }

  Widget _buildFusingInfo(BuildContext context) {
    return WarningWidget(
      iconData: Icons.info,
      fillColor: context.colorScheme.primaryContainer,
      textColor: context.colorScheme.onPrimaryContainer,
      text: AppLocalizations.of(context)!.fusePlasmaDescription,
    );
  }

  Widget _buildFuseBlocWithWidget(
    BuildContext context,
    AccountInfo accountInfo,
  ) {
    return ViewModelBuilder<PlasmaOptionsBloc>.reactive(
      onViewModelReady: (model) {
        _plasmaOptionsBloc = model;
        model.stream.listen(
          (event) {
            if (event != null) {
              sl.get<PlasmaStatsBloc>().get();
              sl.get<PlasmaListBloc>().refreshResults();
            }
          },
          onError: (error) {
            sendNotificationError(
              AppLocalizations.of(context)!.plasmaGenerationError,
              error,
            );
          },
        );
      },
      builder: (_, model, __) {
        return _buildFuseButton(accountInfo, context);
      },
      viewModelBuilder: () => PlasmaOptionsBloc(),
    );
  }

  Widget _buildFuseButton(
    AccountInfo accountInfo,
    BuildContext context,
  ) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _amountController,
        _recipientController,
      ]),
      builder: (_, __) => SyriusFilledButton.color(
        color: qsrColor,
        text: AppLocalizations.of(context)!.fuse,
        onPressed: isButtonEnabled(accountInfo)
            ? () => _showFuseConfirmationBottomSheet(context)
            : null,
      ),
    );
  }

  bool _hasBalance(AccountInfo accountInfo) =>
      accountInfo.getBalance(
        kQsrCoin.tokenStandard,
      ) >
      BigInt.zero;

  bool _isInputValid(AccountInfo accountInfo) =>
      checkAddress(_recipientController.text) == null &&
      correctValueSyrius(
            _amountController.text,
            accountInfo.getBalance(
              kQsrCoin.tokenStandard,
            ),
            kQsrCoin.decimals,
            fuseMinQsrAmount,
            canBeEqualToMin: true,
          ) ==
          null;

  Future<dynamic> _showFuseConfirmationBottomSheet(BuildContext context) {
    return showModalBottomSheetWithBody(
      context: context,
      title: AppLocalizations.of(context)!.fusePlasma,
      body: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.reviewFusion,
            style: context.textTheme.titleSmall?.copyWith(
              color: context.colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
          kVerticalSpacer,
          ...<Widget>[
            _buildBottomSheetInfoRow(
              AppLocalizations.of(context)!.fromAddress,
              shortenWalletAddress(kSelectedAddress!),
            ),
            _buildBottomSheetInfoRow(
              AppLocalizations.of(context)!.beneficiary,
              shortenWalletAddress(_recipientController.text),
            ),
            _buildBottomSheetInfoRow(
              AppLocalizations.of(context)!.amount,
              '${_amountController.text} ${kQsrCoin.symbol}',
            ),
          ].addSeparator(kVerticalSpacer),
          kVerticalSpacer,
          _buildConfirmButton(context),
        ],
      ),
    );
  }

  Row _buildBottomSheetInfoRow(
    String leftColumnContent,
    String rightColumnContent,
  ) {
    return BottomSheetInfoRow(
      context: context,
      leftContent: leftColumnContent,
      rightContent: rightColumnContent,
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SyriusFilledButton.color(
        color: qsrColor,
        text: AppLocalizations.of(context)!.confirm,
        onPressed: () async {
          _plasmaOptionsBloc?.generatePlasma(
            _recipientController.text,
            _amountController.text.extractDecimals(coinDecimals),
          );
          _amountController.clear();
          _recipientController.clear();
          Navigator.pop(context);
        },
      ),
    );
  }
}
