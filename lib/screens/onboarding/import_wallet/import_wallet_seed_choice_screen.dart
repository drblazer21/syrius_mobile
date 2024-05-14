import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:syrius_mobile/screens/screens.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class ImportWalletScreen extends StatefulWidget {
  const ImportWalletScreen({
    super.key,
  });

  @override
  State<ImportWalletScreen> createState() => _ImportWalletPasswordScreenState();
}

class _ImportWalletPasswordScreenState extends State<ImportWalletScreen> {
  int _activeImportWalletIndex = -1;

  List<String> _words = [];
  List<String> _disabledCharacters = [];
  List<String> _recommendedMnemonicWords = [];

  final TextEditingController _mnemonicWordController = TextEditingController();

  final GlobalKey<BlinkAnimationWidgetState> _blinkKey =
      GlobalKey<BlinkAnimationWidgetState>();

  bool get _isMnemonicValid => Mnemonic.validateMnemonic(_words);
  bool get _isEntryDone => _words.length == 12 || _words.length == 24;

  String get _mnemonicWord => _mnemonicWordController.text;

  @override
  void initState() {
    super.initState();
    _mnemonicWordController.addListener(() {
      _recommendedMnemonicWords =
          enWordlist.where((e) => e.startsWith(_mnemonicWord)).toList();

      final set1 = Set.from(_recommendedMnemonicWords);
      final set2 = Set.from(_words);

      _recommendedMnemonicWords = List.from(set1.difference(set2));
      if (_mnemonicWord.isEmpty) {
        _recommendedMnemonicWords.clear();
      }

      final List<String> toEnableCharacter = _recommendedMnemonicWords
          .map((e) {
            final String removedString =
                e.replaceFirst(RegExp(_mnemonicWord), '');
            if (removedString.isNotEmpty) {
              return removedString[0];
            }
            return '';
          })
          .toSet()
          .toList();
      _disabledCharacters =
          characters.where((a) => !toEnableCharacter.contains(a)).toList();

      if (_mnemonicWord.isEmpty) {
        _disabledCharacters = [];
      }
      setState(() {});
    });
    Future.delayed(const Duration(seconds: 1), () {
      _blinkKey.currentState?.start();
    });
  }

  final List<String> characters = List.generate(
    26,
    (index) => String.fromCharCode(
      97 + index,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.importWallet,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPasteIntoTextFormFieldButton(),
              _buildClearIcon(
                onTap: () {
                  setState(() {
                    _activeImportWalletIndex = -1;
                    _recommendedMnemonicWords.clearSecurely();
                    _disabledCharacters.clearSecurely();
                    _words.clearSecurely();
                  });
                },
              ),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInputtedMnemonicBox(context),
                if (_isEntryDone)
                  _importButton()
                else
                  _textFieldAndRecommendation(),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                MdiIcons.shield,
                color: znnColor,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  'Secure Keyboard',
                  style: context.textTheme.titleSmall?.copyWith(
                    color: znnColor,
                  ),
                ),
              ),
            ],
          ),
          Visibility(
            visible: !_isMnemonicValid,
            child: Container(
              padding: const EdgeInsets.only(
                top: 10.0,
              ),
              child: AlphaVirtualKeyboard(
                controller: _mnemonicWordController,
                disabledCharacters: _disabledCharacters,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mnemonicWordController.dispose();
    _recommendedMnemonicWords.clearSecurely();
    _disabledCharacters.clearSecurely();
    _words.clearSecurely();
    super.dispose();
  }

  Widget _buildInputtedMnemonicBox(BuildContext context) {
    final Color emptyBoxBorderColor = context.colorScheme.outline;
    final Color borderColor = _isMnemonicValid
        ? context.colorScheme.primary
        : context.colorScheme.error;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.only(
          left: 10.0,
          top: 10.0,
          bottom: 10.0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            width: 0.5,
            color: _words.isNotEmpty ? borderColor : emptyBoxBorderColor,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _words.isNotEmpty
                  ? _buildSeed(context)
                  : _buildSeedPhraseHint(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textFieldAndRecommendation() {
    return Column(
      children: [
        Container(
          height: 50.0,
          margin: const EdgeInsets.symmetric(vertical: 15.0),
          padding: const EdgeInsets.only(left: 15.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: context.colorScheme.outline,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      _mnemonicWord,
                      style: context.textTheme.titleMedium,
                    ),
                    BlinkAnimationWidget(
                      key: _blinkKey,
                      child: Container(
                        margin: const EdgeInsets.only(left: 2.0),
                        height: 22.0,
                        width: 2.0,
                        color: context.colorScheme.primary,
                      ),
                    ),
                    if (_mnemonicWord.isEmpty)
                      Text(
                        AppLocalizations.of(context)!.mnemonicWord,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colorScheme.outline,
                        ),
                      ),
                  ],
                ),
              ),
              if (_mnemonicWord.isNotEmpty)
                _buildClearIcon(
                  onTap: () {
                    setState(() {
                      _mnemonicWordController.clear();
                    });
                  },
                ),
            ],
          ),
        ),
        if (_recommendedMnemonicWords.isNotEmpty)
          Column(
            children: [
              SizedBox(
                height: 40.0,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _recommendedMnemonicWords.length > 3
                      ? 3
                      : _recommendedMnemonicWords.length,
                  separatorBuilder: (_, __) => kIconAndTextHorizontalSpacer,
                  itemBuilder: (context, index) {
                    return SeedItemImportWallet(
                      onChange: () {
                        if (_activeImportWalletIndex >= 0) {
                          _words[_activeImportWalletIndex] =
                              _recommendedMnemonicWords[index];
                          final int nextEmpty =
                              _words.indexWhere((element) => element.isEmpty);
                          _activeImportWalletIndex = nextEmpty;
                        } else {
                          _words.add(_recommendedMnemonicWords[index]);
                        }
                        _recommendedMnemonicWords.clear();
                        _mnemonicWordController.clear();
                        _disabledCharacters = [];

                        setState(() {});
                      },
                      text: _recommendedMnemonicWords[index],
                    );
                  },
                ),
              ),
              kVerticalSpacer,
            ],
          ),
      ],
    );
  }

  Future<void> _onNextPressed() async {
    _activeImportWalletIndex = _words.length;
    final String mnemonic = _words.join(' ');
    final KeyStore keyStore = KeyStore.fromMnemonic(mnemonic);
    final String entropy = keyStore.entropy;

    await saveEntropy(entropy).then(
      (value) => showCreatePincodeScreen(
        context: context,
      ),
    );
  }

  Widget _importButton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: kVerticalSpacer.height!),
      child: SyriusFilledButton(
        text: AppLocalizations.of(context)!.import,
        onPressed: _onNextPressed,
      ),
    );
  }

  Widget _buildPasteIntoTextFormFieldButton() {
    return IconButton(
      onPressed: () {
        pasteToClipboard(
          (seed) {
            _words.clear();
            _words = seed.trim().split(' ');
            setState(() {});
          },
        );
      },
      icon: const Icon(
        Icons.paste,
      ),
    );
  }

  Text _buildSeedPhraseHint(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.importWalletMnemonicHint,
      style: context.textTheme.labelMedium?.copyWith(
        color: context.colorScheme.outline,
      ),
    );
  }

  Widget _buildSeed(BuildContext context) {
    return Text(
      _words.join(' '),
      style: context.textTheme.titleSmall,
    );
  }

  Widget _buildClearIcon({required VoidCallback onTap}) {
    return IconButton(
      onPressed: onTap,
      icon: const Icon(
        Icons.clear,
      ),
    );
  }
}
