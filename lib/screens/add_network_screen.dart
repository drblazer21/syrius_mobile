import 'package:drift/drift.dart' hide Column;
import 'package:drift/isolate.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/database/app_network_asset_entries.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/utils/wallet_connect/functions.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/text_form_fields/network_block_explorer_url_text_field.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/text_form_fields/network_currency_symbol_text_field.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

enum AddNetworkScreenMode { add, edit, info }

class AddNetworkScreen extends StatefulWidget {
  final AppNetwork? appNetwork;
  final AddNetworkScreenMode mode;

  const AddNetworkScreen({
    required this.mode,
    super.key,
    this.appNetwork,
  });

  @override
  State<AddNetworkScreen> createState() => _AddNetworkScreenState();
}

class _AddNetworkScreenState extends State<AddNetworkScreen> {
  final TextEditingController _networkChainIdController =
      TextEditingController();
  final TextEditingController _networkNameController = TextEditingController();
  final TextEditingController _networkUrlController = TextEditingController();
  final TextEditingController _currencySymbolController =
      TextEditingController();
  final TextEditingController _blockExplorerController =
      TextEditingController();

  final FocusNode _networkChainIdFocusNode = FocusNode();
  final FocusNode _networkNameFocusNode = FocusNode();
  final FocusNode _networkUrlFocusNode = FocusNode();
  final FocusNode _currencySymbolFocusNode = FocusNode();
  final FocusNode _blockExplorerFocusNode = FocusNode();

  BlockChain _selectedBlockChain = BlockChain.nom;
  NetworkType _type = NetworkType.mainnet;

  String get _name => _networkNameController.text;

  String get _url => _networkUrlController.text;

  String get _chainId => _networkChainIdController.text;

  String get _currencySymbol => _currencySymbolController.text;

  String get _blockExplorerUrl => _blockExplorerController.text;

  String? get _nameError => networkNameValidator(
        name: _name,
      );

  AppNetworksCompanion get _userGeneratedAppNetwork =>
      AppNetworksCompanion.insert(
        assets: AppNetworkAssetEntries(items: []),
        blockChain: _selectedBlockChain,
        blockExplorerUrl: _blockExplorerUrl.isNotEmpty
            ? _blockExplorerUrl
            : _generateBlockChainExplorer(
                _selectedBlockChain,
                _type,
              ),
        chainId: Value(
          _isBtcNetwork ? null : int.parse(_chainId.isEmpty ? '0' : _chainId),
        ),
        currencySymbol: _currencySymbol,
        id: widget.appNetwork != null
            ? Value(widget.appNetwork!.id)
            : const Value.absent(),
        name: _name,
        type: _type,
        url: _url,
      );

  bool get _isBtcNetwork => _selectedBlockChain == BlockChain.btc;

  bool get _shouldTextFieldsBeEnabled =>
      widget.mode != AddNetworkScreenMode.info;

  @override
  void initState() {
    super.initState();
    if (widget.appNetwork != null) {
      _initFields(widget.appNetwork!);
    }
  }

  @override
  void dispose() {
    _networkChainIdController.dispose();
    _networkNameController.dispose();
    _networkUrlController.dispose();
    _networkChainIdFocusNode.dispose();
    _networkNameFocusNode.dispose();
    _networkUrlFocusNode.dispose();
    _currencySymbolController.dispose();
    _currencySymbolFocusNode.dispose();
    _blockExplorerController.dispose();
    _blockExplorerFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String urlTextFieldTitle =
        _selectedBlockChain == BlockChain.btc ? 'Electrum Node URL' : 'URL';

    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.addNetwork,
      withLateralPadding: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: kHorizontalPagePaddingDimension,
                    ),
                    child: Text('Network Type'),
                  ),
                  ..._buildBlockChainRadioListTiles(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: kHorizontalPagePaddingDimension,
                        ),
                        child: Text('Environment'),
                      ),
                      ..._buildNetworkTypeRadioListTiles(),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kHorizontalPagePaddingDimension,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Name'),
                        _buildNetworkNameTextField(),
                        Text(urlTextFieldTitle),
                        _buildNetworkUrlTextField(),
                        Visibility(
                          visible: !_isBtcNetwork,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('Chain ID'),
                              kVerticalSpacer,
                              _buildNetworkChainIdTextField(),
                            ],
                          ),
                        ),
                        const Text('Currency Symbol'),
                        _buildNetworkCurrencySymbolTextField(),
                        const Row(
                          children: [
                            Text('Block Explorer URL'),
                            SizedBox(
                              width: 4.0,
                            ),
                            Tooltip(
                              message:
                                  'Enter the URL to which to append the transaction hash',
                              child: Icon(Icons.info_outline),
                            ),
                          ],
                        ),
                        _buildBlockExplorerUrlTextField(),
                      ].addSeparator(kVerticalSpacer),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: kHorizontalPagePaddingDimension,
            ),
            child: _buildSaveButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkNameTextField() {
    return ValueListenableBuilder(
      valueListenable: _networkNameController,
      builder: (_, __, ___) => NetworkNameTextField(
        context: context,
        controller: _networkNameController,
        enabled: _shouldTextFieldsBeEnabled,
        focusNode: _networkNameFocusNode,
        nextFocusNode: _networkUrlFocusNode,
        errorText: _nameError,
      ),
    );
  }

  Widget _buildNetworkUrlTextField() {
    return ValueListenableBuilder(
      valueListenable: _networkUrlController,
      builder: (_, __, ___) => NetworkUrlTextField(
        blockChain: _selectedBlockChain,
        context: context,
        controller: _networkUrlController,
        enabled: _shouldTextFieldsBeEnabled,
        focusNode: _networkUrlFocusNode,
        nextFocusNode: _networkChainIdFocusNode,
      ),
    );
  }

  Widget _buildNetworkChainIdTextField() {
    return ValueListenableBuilder(
      valueListenable: _networkChainIdController,
      builder: (_, __, ___) => NetworkChainIdTextField(
        context: context,
        controller: _networkChainIdController,
        enabled: _shouldTextFieldsBeEnabled,
        focusNode: _networkChainIdFocusNode,
        nextFocusNode: _currencySymbolFocusNode,
      ),
    );
  }

  Widget _buildNetworkCurrencySymbolTextField() {
    return ValueListenableBuilder(
      valueListenable: _currencySymbolController,
      builder: (_, __, ___) => NetworkCurrencySymbolTextField(
        context: context,
        controller: _currencySymbolController,
        enabled: _shouldTextFieldsBeEnabled,
        focusNode: _currencySymbolFocusNode,
        nextFocusNode: _blockExplorerFocusNode,
      ),
    );
  }

  Widget _buildBlockExplorerUrlTextField() {
    final String hintText = _generateBlockChainExplorer(
      _selectedBlockChain,
      _type,
    );

    return ValueListenableBuilder(
      valueListenable: _blockExplorerController,
      builder: (_, __, ___) => NetworkBlockExplorerUrlTextField(
        controller: _blockExplorerController,
        enabled: _shouldTextFieldsBeEnabled,
        focusNode: _blockExplorerFocusNode,
        hintText: hintText,
        onSubmitted: (_) {
          final void Function()? callback =
              _isInputValid() ? _saveNetwork : null;

          callback?.call();
        },
      ),
    );
  }

  List<Widget> _buildBlockChainRadioListTiles() =>
      BlockChain.values.toList().map(_buildBlockChainRadioListTile).toList();

  Widget _buildBlockChainRadioListTile(
    BlockChain appNetwork,
  ) {
    final void Function(BlockChain?)? onChanged = _shouldTextFieldsBeEnabled
        ? (BlockChain? value) {
            if (value != null) {
              setState(() {
                _selectedBlockChain = value;
              });
            }
          }
        : null;

    return RadioListTile<BlockChain>(
      title: Text(appNetwork.displayName),
      value: appNetwork,
      groupValue: _selectedBlockChain,
      onChanged: onChanged,
    );
  }

  List<Widget> _buildNetworkTypeRadioListTiles() =>
      NetworkType.values.toList().map(_buildNetworkTypeRadioListTile).toList();

  Widget _buildNetworkTypeRadioListTile(
    NetworkType bitcoinNetwork,
  ) {
    final void Function(NetworkType?)? onChanged = _shouldTextFieldsBeEnabled
        ? (NetworkType? value) {
            if (value != null) {
              setState(() {
                _type = value;
              });
            }
          }
        : null;

    return RadioListTile<NetworkType>(
      title: Text(bitcoinNetwork.name.capitalize()),
      value: bitcoinNetwork,
      groupValue: _type,
      onChanged: onChanged,
    );
  }

  Widget _buildSaveButton() {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _networkNameController,
        _networkUrlController,
        _networkChainIdController,
        _currencySymbolController,
        _blockExplorerController,
      ]),
      builder: (_, child) => FilledButton(
        onPressed: _isInputValid() ? _saveNetwork : null,
        child: Text(AppLocalizations.of(context)!.save),
      ),
    );
  }

  Future<void> _saveNetwork() async {
    final AppNetworksCompanion userGeneratedAppNetwork =
        _userGeneratedAppNetwork;

    NetworkAssetsCompanion? currency;

    if (widget.appNetwork == null) {
      switch (userGeneratedAppNetwork.blockChain.value) {
        case BlockChain.btc:
          currency = generateBitcoinNetworkCurrency(_currencySymbol);
        case BlockChain.evm:
          currency = generateEthereumNetworkCurrency(
            _currencySymbol,
          );
        case BlockChain.nom:
          break;
      }
    }

    try {
      final int newAppNetworkId =
          await db.appNetworksDao.upsert(userGeneratedAppNetwork);

      final bool isAddMode = widget.mode == AddNetworkScreenMode.add;

      if (isAddMode) {
        if (currency != null) {
          currency = currency.copyWith(
            network: Value(newAppNetworkId),
          );
          final int id = await db.networkAssetsDao.insert(currency);
          userGeneratedAppNetwork.copyWith(
            assets: Value(
              AppNetworkAssetEntries(
                items: [id],
              ),
            ),
          );
        }
      }
      if (isAddMode &&
          userGeneratedAppNetwork.blockChain.value.isSupportedByWalletConnect) {
        final AppNetwork newAppNetwork = await db.managers.appNetworks
            .filter((f) => f.id(newAppNetworkId))
            .getSingle();

        registerWcService(newAppNetwork);
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      String title = 'An error occurred while adding a new network';
      if (e is DriftRemoteException) {
        if (e.remoteCause is SqliteException) {
          final int sqlErrorCode =
              (e.remoteCause as SqliteException).extendedResultCode;

          // Error codes here: https://sqlite.org/rescode.html#constraint_unique
          const int uniqueConstrainErrorCode = 2067;

          // The error code refers to a unique constrain that failed and the
          // name column from app networks table needs to have unique values
          if (sqlErrorCode == uniqueConstrainErrorCode) {
            title = 'Name is not unique';
          }
        }
      }

      sendNotificationError(
        title,
        e.toString(),
      );
    }
  }

  bool _isInputValid() {
    final bool nameIsValid = _name.isNotEmpty && _nameError == null;
    final bool urlIsValid = _url.isNotEmpty &&
        _selectedBlockChain.networkUrlValidator(_url) == null;
    final bool chainId = _isBtcNetwork ||
        _chainId.isNotEmpty && chainIdValidator(_chainId) == null;
    final bool isCurrencySymbolValid = _currencySymbol.isNotEmpty &&
        networkAssetSymbolValidator(_currencySymbol) == null;
    final bool isBlockExplorerValid = _blockExplorerUrl.isEmpty ||
        urlValidator(_blockExplorerUrl) == null;

    return _shouldTextFieldsBeEnabled &&
        nameIsValid &&
        urlIsValid &&
        chainId &&
        isCurrencySymbolValid &&
        isBlockExplorerValid;
  }

  void _initFields(AppNetwork appNetwork) {
    _type = appNetwork.type;
    _selectedBlockChain = appNetwork.blockChain;
    _networkChainIdController.text = appNetwork.chainId.toString();
    _networkNameController.text = appNetwork.name;
    _networkUrlController.text = appNetwork.url;
    _currencySymbolController.text = appNetwork.currencySymbol;
    _blockExplorerController.text = appNetwork.blockExplorerUrl;
  }

  String _generateBlockChainExplorer(
    BlockChain selectedBlockChain,
    NetworkType type,
  ) {
    switch (selectedBlockChain) {
      case BlockChain.btc:
        switch (type) {
          case NetworkType.mainnet:
            return kBtcMainnetExplorer;
          case NetworkType.testnet:
            return kBtcSignetExplorer;
        }
      case BlockChain.evm:
        switch (type) {
          case NetworkType.mainnet:
            return kEthereumMainnetExplorer;
          case NetworkType.testnet:
            return kEthereumTestnetExplorer;
        }
      case BlockChain.nom:
        switch (type) {
          case NetworkType.mainnet:
            return kZenonMainnetExplorer;
          case NetworkType.testnet:
            return kZenonTestnetExplorer;
        }
    }
  }
}
