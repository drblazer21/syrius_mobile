import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/screens/screens.dart';
import 'package:syrius_mobile/utils/notifiers/backed_up_seed_notifier.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class ConfirmBackupScreen extends StatefulWidget {
  final bool isOnboardingFlow;

  const ConfirmBackupScreen({
    required this.isOnboardingFlow,
    super.key,
  });

  @override
  State<ConfirmBackupScreen> createState() => _ConfirmBackupScreenState();
}

class _ConfirmBackupScreenState extends State<ConfirmBackupScreen> {
  final List<String> _mnemonic = [];
  final List<String> _mnemonicShuffledCopy = [];
  final List<String> _mnemonicInputted = [];
  late Future<List<String>> _mnemonicFuture;
  bool _doMnemonicsMatch = true;
  int activeInputSeedItemIndex = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _mnemonicFuture = getMnemonicAsList();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.backupSeedConfirmTitle,
      child: FutureBuilder<List<String>>(
        future: _mnemonicFuture,
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            if (_mnemonic.isEmpty) {
              _initMnemonicVariables(snapshot.data!);
            }
            return _buildWidgetBody(context);
          } else if (snapshot.hasError) {
            return SyriusErrorWidget(snapshot.error!);
          }
          return const SyriusLoadingWidget();
        },
      ),
    );
  }

  @override
  void dispose() {
    _mnemonic.clearSecurely();
    _mnemonicShuffledCopy.clearSecurely();
    _mnemonicInputted.clearSecurely();
    super.dispose();
  }

  bool _isEntryDone() =>
      _mnemonicInputted.every((element) => element.isNotEmpty);

  void _initMnemonicVariables(List<String> mnemonic) {
    _mnemonic.addAll(mnemonic);
    _mnemonicInputted.addAll(List.generate(_mnemonic.length, (index) => ''));
    _mnemonicShuffledCopy.addAll(_mnemonic);
    _mnemonicShuffledCopy.shuffle();
  }

  Column _buildWidgetBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          child: Text(
            AppLocalizations.of(context)!.backupSeedConfirmDescription,
            textAlign: TextAlign.center,
          ),
        ),
        kVerticalSpacer,
        Expanded(child: _buildOutlinedSeedContainer(context)),
        kVerticalSpacer,
        Expanded(child: _buildShuffledMnemonicCopy()),
        kVerticalSpacer,
        _buildFinishButton(context),
      ],
    );
  }

  ShakeWidget _buildOutlinedSeedContainer(BuildContext context) {
    final Color borderColor = _doMnemonicsMatch
        ? context.colorScheme.outline
        : context.colorScheme.error;

    return ShakeWidget(
      controller: (controller) {
        _animationController = controller;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text(
                _mnemonic.length == 12
                    ? AppLocalizations.of(context)!.backupSeed12Title
                    : AppLocalizations.of(context)!.backupSeed24Title,
                style: context.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(child: _buildInputtedMnemonic()),
          ],
        ),
      ),
    );
  }

  Widget _buildInputtedMnemonic() {
    return GridView.builder(
      itemCount: _mnemonicInputted.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 2.5,
        crossAxisSpacing: kIconAndTextHorizontalSpacer.width! * 2,
        crossAxisCount: 3,
        mainAxisSpacing: kIconAndTextHorizontalSpacer.width!,
      ),
      itemBuilder: (_, index) {
        final bool isSelected = activeInputSeedItemIndex == index;
        final String word = _mnemonicInputted[index];

        return SeedItem(
          isSelected: isSelected,
          onChange: () {
            if (_mnemonicInputted[index].isEmpty) {
              activeInputSeedItemIndex = index;
            } else {
              activeInputSeedItemIndex = index;
            }
            if (isSelected) {
              _mnemonicInputted[index] = '';
            }
            setState(() {});
          },
          text: word,
        );
      },
    );
  }

  Widget _buildShuffledMnemonicCopy() {
    return GridView.builder(
      itemCount: _mnemonicShuffledCopy.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 2.5,
        crossAxisSpacing: kIconAndTextHorizontalSpacer.width! * 2,
        crossAxisCount: 3,
        mainAxisSpacing: kIconAndTextHorizontalSpacer.width!,
      ),
      itemBuilder: (_, index) {
        final String word = _mnemonicShuffledCopy[index];
        final bool isDisabled = _mnemonicInputted.contains(word);

        return SeedItem(
          isSelected: false,
          isDisabled: isDisabled,
          onChange: () {
            if (!isDisabled) {
              setState(() {
                _mnemonicInputted[activeInputSeedItemIndex] = word;
                ++activeInputSeedItemIndex;
              });
            }
          },
          text: word,
        );
      },
    );
  }

  SyriusFilledButton _buildFinishButton(BuildContext context) {
    return SyriusFilledButton(
      text: AppLocalizations.of(context)!.finish,
      onPressed: _isEntryDone()
          ? () {
              if (listEquals(_mnemonic, _mnemonicInputted)) {
                _doMnemonicsMatch = true;
                sharedPrefs
                    .setBool(
                  kIsBackedUpKey,
                  true,
                )
                    .then(
                  (_) {
                    if (context.mounted) {
                      final BackedUpSeedNotifier backedUpSeedNotifier =
                          Provider.of<BackedUpSeedNotifier>(
                        context,
                        listen: false,
                      );
                      backedUpSeedNotifier.isBackedUp = true;
                      _showConfirmationDialog(context);
                    }
                  },
                );
              } else {
                _doMnemonicsMatch = false;
                _animationController.forward(from: 0);
              }
              setState(() {
                activeInputSeedItemIndex = _mnemonic.length;
              });
            }
          : null,
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showModalBottomSheetWithButtons(
      context: context,
      dialogImage: Icon(
        Icons.shield,
        color: context.colorScheme.primary,
        size: 45.0,
      ),
      title: AppLocalizations.of(context)!.backupSeedDone,
      subTitle: AppLocalizations.of(context)!.seedBackupCompleted,
      btn1Text: AppLocalizations.of(context)!.continueButton,
      btn1Action: () {
        if (widget.isOnboardingFlow) {
          _navigateToHomeScreen(context);
        } else {
          _returnToSettingsPage(context);
        }
      },
    );
  }

  void _returnToSettingsPage(BuildContext context) {
    return Navigator.popUntil(
      context,
      (route) => route.isFirst,
    );
  }

  Future<dynamic> _navigateToHomeScreen(BuildContext context) {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
      (Route<dynamic> route) => false,
    );
  }
}
