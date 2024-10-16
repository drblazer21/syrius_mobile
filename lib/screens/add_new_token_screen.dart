import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/blocs/tokens/add_token_bloc.dart';
import 'package:syrius_mobile/database/app_network_asset_entries.dart';
import 'package:syrius_mobile/database/database.dart';
import 'package:syrius_mobile/database/extensions.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/text_form_fields/new_token_symbol_text_field.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class AddNewTokenScreen extends StatefulWidget {
  const AddNewTokenScreen({super.key});

  @override
  State<AddNewTokenScreen> createState() => _AddNewTokenScreenState();
}

class _AddNewTokenScreenState extends State<AddNewTokenScreen> {
  final TextEditingController _contractAddressController =
      TextEditingController();
  final TextEditingController _decimalsController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _symbolController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _symbolFocusNode = FocusNode();

  final AddTokenBloc _addTokenBloc = AddTokenBloc();

  String get _contractAddress => _contractAddressController.text;

  String get _decimals => _decimalsController.text;

  String get _name => _nameController.text;

  String get _symbol => _symbolController.text;

  String? get _symbolErrorText => networkAssetSymbolValidator(_symbol);

  String? get _nameErrorText => networkAssetNameValidator(_name);

  @override
  void initState() {
    super.initState();
    _contractAddressController.addListener(
      () => _searchToken(_contractAddress),
    );
  }

  @override
  void dispose() {
    _contractAddressController.dispose();
    _decimalsController.dispose();
    _nameController.dispose();
    _symbolController.dispose();
    _addTokenBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.addNewToken,
      child: Column(
        children: [
          RecipientAddressTextField(
            controller: _contractAddressController,
            context: context,
            focusNode: FocusNode(),
            hintText: 'Contract Address',
            onSubmitted: (value) {
              if (value != null) {
                _searchToken(value);
              }
            },
          ),
          Expanded(
            child: StreamBuilder<UiState>(
              initialData: InitialUiState(),
              stream: _addTokenBloc.stream,
              builder: (_, snapshot) {
                switch (snapshot.data!) {
                  case InitialUiState():
                    return const SizedBox.shrink();
                  case LoadingUiState():
                    return const SyriusLoadingWidget();
                  case SuccessUiState():
                    final NetworkAssetsCompanion networkAsset =
                        (snapshot.data! as SuccessUiState).data
                            as NetworkAssetsCompanion;

                    _decimalsController.text =
                        networkAsset.decimals.value.toString();
                    _nameController.text = networkAsset.name.value!;
                    _symbolController.text = networkAsset.symbol.value;
                    _nameFocusNode.requestFocus();
                    return _buildSuccessUiStateWidget();
                  case ErrorUiState():
                    return SyriusErrorWidget(
                      (snapshot.data! as ErrorUiState).error.toString(),
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Column _buildSuccessUiStateWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _buildNetworkAssetTextFields(),
        ),
        _buildSaveButton(),
      ],
    );
  }

  void _searchToken(String contractAddress) {
    final bool isValidAddress = checkAddress(contractAddress) == null;
    if (isValidAddress) {
      _addTokenBloc.searchToken(contractAddress);
    }
  }

  Widget _buildNetworkAssetTextFields() {
    final Widget nameField = ValueListenableBuilder(
      valueListenable: _nameController,
      builder: (context, __, ___) => NewTokenNameTextField(
        controller: _nameController,
        errorText: _nameErrorText,
        focusNode: _nameFocusNode,
        onSubmitted: (_) {
          FocusScope.of(context).requestFocus(_symbolFocusNode);
        },
      ),
    );

    final Widget symbolField = ValueListenableBuilder(
      valueListenable: _symbolController,
      builder: (_, TextEditingValue value, ___) {
        return NewTokenSymbolTextField(
          controller: _symbolController,
          errorText: _symbolErrorText,
          focusNode: _symbolFocusNode,
          onSubmitted: (_) {
            final void Function()? callback =
                _isInputValid() ? _saveToken : null;

            callback?.call();
          },
        );
      },
    );

    final TextField decimalsField = TextField(
      controller: _decimalsController,
      enabled: false,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text('Name'),
          nameField,
          const Text('Symbol'),
          symbolField,
          const Text('Decimals'),
          decimalsField,
        ].addSeparator(
          kVerticalSpacer,
          skipCount: 0,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _nameController,
        _symbolController,
      ]),
      builder: (_, __) => FilledButton(
        onPressed: _isInputValid() ? _saveToken : null,
        child: Text(
          AppLocalizations.of(context)!.save,
        ),
      ),
    );
  }

  Future<void> _saveToken() async {
    try {
      final NetworkAssetsCompanion networkAsset = NetworkAssetsCompanion.insert(
        contractAddressHex: Value(_contractAddress),
        decimals: int.parse(_decimals),
        isCurrency: false,
        name: Value(_name),
        network: kSelectedAppNetworkWithAssets!.network.id,
        symbol: _symbol,
      );

      final Iterable<String?> existingAssetAddresses =
          kSelectedAppNetworkWithAssets!.assets
              .map((e) => e.contractAddressHex);

      final bool tokenAlreadyExists = existingAssetAddresses.contains(
        networkAsset.contractAddressHex.value,
      );

      if (tokenAlreadyExists) {
        sendNotificationError(
          'Duplicate token',
          'A token with the same contract address already exists: $networkAsset',
        );
      } else {
        showLoadingDialog(context);
        final int id = await db.networkAssetsDao.insert(networkAsset);
        await db.appNetworksDao.updateData(
          kSelectedAppNetworkWithAssets!.network.copyWith(
            assets: AppNetworkAssetEntries(
              items: [
                ...kSelectedAppNetworkWithAssets!.assets.map((e) => e.id),
                id,
              ],
            ),
          ),
        );

        final AppNetwork selectedAppNetwork = await db.managers.appNetworks
            .filter((f) => f.id(kSelectedAppNetworkWithAssets!.network.id))
            .getSingle();

        final List<NetworkAsset> selectAppNetworkAssets =
            await db.networkAssetsDao.getAllByNetworkId(selectedAppNetwork.id);

        kSelectedAppNetworkWithAssets = (
          assets: selectAppNetworkAssets,
          network: selectedAppNetwork,
        );

        if (!mounted) return;
        sl.get<EthAccountBalanceBloc>().fetch(
              address: selectedAddress.toEthAddress(),
            );
        Navigator.pop(context);
      }
    } catch (e) {
      sendNotificationError(
        'Something went wrong while adding the new token',
        e,
      );
    } finally {
      Navigator.pop(context);
    }
  }

  bool _isInputValid() {
    final bool isSymbolValid = _symbol.isNotEmpty && _symbolErrorText == null;

    final bool isNameValid = _name.isNotEmpty && _nameErrorText == null;

    return isSymbolValid && isNameValid;
  }
}
