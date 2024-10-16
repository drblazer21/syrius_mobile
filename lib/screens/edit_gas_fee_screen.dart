import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/blocs/gas_fee_details_bloc.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/constants.dart';
import 'package:syrius_mobile/utils/extensions/extensions.dart';
import 'package:syrius_mobile/utils/extensions/list_separator.dart';
import 'package:syrius_mobile/utils/input_validators.dart';
import 'package:syrius_mobile/utils/text_input_formatters.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/custom_appbar_screen.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/error_widget.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/loading_widget.dart';

// All the numbers expressed in the text fields are in Gwei
class EditGasFeeScreen extends StatefulWidget {
  final EthereumTxGasDetailsData data;
  final GasFeeDetailsBloc gasFeeDetailsBloc;

  const EditGasFeeScreen({
    required this.data,
    required this.gasFeeDetailsBloc,
    super.key,
  });

  @override
  State<EditGasFeeScreen> createState() => _EditGasFeeScreenState();
}

class _EditGasFeeScreenState extends State<EditGasFeeScreen> {
  late ExtendedBlockInformation _extendedBlockInformation;

  final TextEditingController _gasLimitUnitsController =
      TextEditingController();
  final TextEditingController _maxFeePerGasController = TextEditingController();
  final TextEditingController _maxPriorityFeePerGasController =
      TextEditingController();

  final FocusNode _gasLimitNode = FocusNode();
  final FocusNode _maxFeePerGasNode = FocusNode();
  final FocusNode _maxPriorityFeePerGasNode = FocusNode();

  String get _gasLimitUnits => _gasLimitUnitsController.text;

  String get _maxFeePerGas => _maxFeePerGasController.text;

  String get _maxPriorityFeePerGas => _maxPriorityFeePerGasController.text;

  String? get _gasLimitError => gasLimitValidator(
        value: _gasLimitUnits,
        max: _extendedBlockInformation.gasLimit,
      );

  String? get _maxFeePerGasError => maxFeePerGasValidator(_maxFeePerGas);

  String? get _maxPriorityFeePerGasError => maxPriorityFeePerGasValidator(
        maxFeePerGasValue: _maxFeePerGas,
        maxPriorityFeePerGasValue: _maxPriorityFeePerGas,
      );

  String get _initialGasLimit => widget.data.gasLimit.toString();

  String get _initialMaxFee =>
      widget.data.userFee!.maxFeePerGas.toStringWithDecimals(kGweiDecimals);

  String get _initialMaxPriorityFee => widget.data.userFee!.maxPriorityFeePerGas
      .toStringWithDecimals(kGweiDecimals);

  @override
  void initState() {
    super.initState();
    _gasLimitUnitsController.text = _initialGasLimit;
    _maxFeePerGasController.text = _initialMaxFee;
    _maxPriorityFeePerGasController.text = _initialMaxPriorityFee;
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.editGasFee,
      child: FutureBuilder(
        future: eth.getLatestBlockInformation(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _extendedBlockInformation = snapshot.data!;
            _maxFeePerGasNode.requestFocus();
            return _buildBody(context);
          } else if (snapshot.hasError) {
            return SyriusErrorWidget(snapshot.error.toString());
          }
          return const SyriusLoadingWidget();
        },
      ),
    );
  }

  Column _buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Max base fee (Gwei)'),
                _buildMaxFeePerGasTextField(),
                const Text('Max priority fee (Gwei)'),
                _buildMaxPriorityFeePerGasTextField(),
                const Text('Gas units limit'),
                _buildGasUnitsLimitTextField(),
              ].addSeparator(kVerticalSpacer),
            ),
          ),
        ),
        _buildSaveButton(context),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _gasLimitUnitsController,
        _maxFeePerGasController,
        _maxPriorityFeePerGasController,
      ]),
      builder: (_, __) => FilledButton(
        onPressed: _isInputValid() ? _updateGasFees : null,
        child: Text(
          AppLocalizations.of(context)!.save,
        ),
      ),
    );
  }

  void _updateGasFees() {
    final BigInt gasLimit = BigInt.parse(_gasLimitUnits);
    final BigInt maxFeePerGas = _maxFeePerGas.extractDecimals(kGweiDecimals);
    final BigInt maxPriorityFeePerGas =
        _maxPriorityFeePerGas.extractDecimals(kGweiDecimals);

    widget.gasFeeDetailsBloc.updateUserFee(
      data: widget.data..gasLimit = gasLimit,
      maxFeePerGas: maxFeePerGas,
      maxPriorityFeePerGas: maxPriorityFeePerGas,
    );

    Navigator.pop(context);
  }

  Widget _buildMaxFeePerGasTextField() {
    return ValueListenableBuilder(
      valueListenable: _maxFeePerGasController,
      builder: (_, __, ___) => TextField(
        controller: _maxFeePerGasController,
        decoration: InputDecoration(
          errorText: _maxFeePerGasError,
        ),
        focusNode: _maxFeePerGasNode,
        inputFormatters: generateAmountTextInputFormatters(
          replacementString: _maxFeePerGasController.text,
          maxDecimals: kGweiDecimals,
        ),
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) {
          FocusScope.of(context).requestFocus(_maxPriorityFeePerGasNode);
        },
      ),
    );
  }

  Widget _buildMaxPriorityFeePerGasTextField() {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _maxFeePerGasController,
        _maxPriorityFeePerGasController,
      ]),
      builder: (_, __) => TextField(
        controller: _maxPriorityFeePerGasController,
        decoration: InputDecoration(
          errorText: _maxPriorityFeePerGasError,
        ),
        focusNode: _maxPriorityFeePerGasNode,
        inputFormatters: generateAmountTextInputFormatters(
          replacementString: _maxPriorityFeePerGasController.text,
          maxDecimals: kGweiDecimals,
        ),
        keyboardType: TextInputType.number,
        onSubmitted: (_) {
          FocusScope.of(context).requestFocus(_gasLimitNode);
        },
        textInputAction: TextInputAction.next,
      ),
    );
  }

  Widget _buildGasUnitsLimitTextField() {
    return ValueListenableBuilder(
      valueListenable: _gasLimitUnitsController,
      builder: (_, __, ___) => TextField(
        controller: _gasLimitUnitsController,
        decoration: InputDecoration(
          errorText: _gasLimitError,
        ),
        focusNode: _gasLimitNode,
        inputFormatters: onlyIntegersTextInputFormatters(
          replacementString: _gasLimitUnitsController.text,
        ),
        onSubmitted: (_) {
          if (_isInputValid()) {
            _updateGasFees();
          }
        },
        keyboardType: TextInputType.number,
      ),
    );
  }

  bool _isInputValid() {
    final bool isGasLimitValid =
        _gasLimitUnits.isNotEmpty && _gasLimitError == null;
    final bool isMaxFeePerGasValid =
        _maxFeePerGas.isNotEmpty && _maxFeePerGasError == null;
    final bool isMaxPriorityFeePerGasValid =
        _maxPriorityFeePerGas.isNotEmpty && _maxPriorityFeePerGasError == null;

    final bool valuesDifferThanTheInitialOnes =
        _gasLimitUnits != _initialGasLimit ||
            _maxFeePerGas != _initialMaxFee ||
            _maxPriorityFeePerGas != _initialMaxPriorityFee;

    return isGasLimitValid &&
        isMaxFeePerGasValid &&
        isMaxPriorityFeePerGasValid &&
        valuesDifferThanTheInitialOnes;
  }
}
