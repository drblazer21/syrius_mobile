import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/screens/screens.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

enum SeedType {
  seed12,
  seed24,
}

class BackupSeedScreen extends StatefulWidget {
  final bool isOnboardingFlow;

  const BackupSeedScreen({
    required this.isOnboardingFlow,
    super.key,
  });

  @override
  State<BackupSeedScreen> createState() => _BackupSeedScreenState();
}

class _BackupSeedScreenState extends State<BackupSeedScreen> {
  final List<String> _mnemonic = [];

  late Future<List<String>> _mnemonicFuture;

  bool _isHoldEnabled = false;
  bool _wasSeedRevealed = false;
  bool _shouldShowCopySeedButton = false;

  final ValueNotifier<int> _lastTimeSeedWasAccessedNotifier = ValueNotifier(
    sharedPrefsService.get<int>(
      kLastTimeSeedWasShownKey,
      defaultValue: 0,
    )!,
  );

  @override
  void initState() {
    super.initState();
    _mnemonicFuture = getMnemonicAsList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(
          const Duration(
            milliseconds: 1000,
          ), () {
        showModalBottomSheetWithBody(
          context: context,
          title: AppLocalizations.of(context)!.backupWalletTitle,
          body: const _CreateWalletOnboarding(),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isBackedUp = sharedPrefsService.get<bool>(
      kIsBackedUpKey,
      defaultValue: false,
    )!;

    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.backupWalletTitle,
      child: FutureBuilder<List<String>>(
        future: _mnemonicFuture,
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            if (_mnemonic.isEmpty) {
              _mnemonic.addAll(snapshot.data!);
            }
            return _buildWidgetBody(context, isBackedUp);
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
    _lastTimeSeedWasAccessedNotifier.dispose();
    _mnemonic.clearSecurely();
    super.dispose();
  }

  Column _buildWidgetBody(BuildContext context, bool isBackedUp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18.0,
            vertical: 5.0,
          ),
          child: Text(
            AppLocalizations.of(context)!.backupSeedDescription,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(child: _buildSeedAndDescription(context)),
        _buildHoldDetector(context),
        _buildBackupInfo(context),
        Visibility(
          visible: _shouldShowCopySeedButton,
          child: _buildBackupWarning(context),
        ),
        _buildCopySeedCheckBox(),
        if (!isBackedUp)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Visibility(
                visible: _wasSeedRevealed,
                child: SyriusFilledButton(
                  text: AppLocalizations.of(context)!.continueButton,
                  onPressed: () async {
                    showConfirmBackupWalletScreen(
                      context: context,
                      isOnboardingFlow: widget.isOnboardingFlow,
                    );
                  },
                ),
              ),
              kVerticalSpacer,
              Visibility(
                visible: widget.isOnboardingFlow,
                child: SyriusFilledButton.color(
                  color: qsrColor,
                  text: AppLocalizations.of(context)!.skip,
                  onPressed: () {
                    showHomeScreen(context);
                  },
                ),
              ),
            ],
          ),
      ].addSeparator(kVerticalSpacer),
    );
  }

  Widget _buildSeedAndDescription(BuildContext context) {
    return Column(
      children: [
        _buildLastTimeSeedWasAccessed(context),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 25.0),
          child: SvgIcon(
            iconFileName: _mnemonic.length == 12 ? 'seed_12' : 'seed_24',
            iconColor: context.colorScheme.primary,
            size: 20.0,
          ),
        ),
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
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              runSpacing: kIconAndTextHorizontalSpacer.width! * 2,
              spacing: kIconAndTextHorizontalSpacer.width!,
              children: [
                ..._mnemonic.mapIndexed(
                  (i, e) => SeedItem(
                    isSelected: false,
                    onChange: () {},
                    text: _isHoldEnabled ? _mnemonic[i] : "${i + 1}",
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  ValueListenableBuilder<int> _buildLastTimeSeedWasAccessed(
    BuildContext context,
  ) {
    return ValueListenableBuilder(
      valueListenable: _lastTimeSeedWasAccessedNotifier,
      builder: (_, millis, __) {
        final String lastTimeSeedWasShown = DateFormat.yMEd()
            .add_jms()
            .format(DateTime.fromMillisecondsSinceEpoch(millis));

        return Visibility(
          visible: _lastTimeSeedWasAccessedNotifier.value > 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLocalizations.of(context)!
                    .backupSeedLastAccessed(lastTimeSeedWasShown),
                style: TextStyle(color: context.colorScheme.error),
              ),
              kVerticalSpacer,
              _buildBackupSeedAccessedWarning(context),
            ],
          ),
        );
      },
    );
  }

  GestureDetector _buildHoldDetector(BuildContext context) {
    final Color borderColor = _isHoldEnabled
        ? context.colorScheme.outline
        : context.colorScheme.primary;

    final Color? textColor =
        _isHoldEnabled ? context.colorScheme.outline : null;

    final outlinedText = Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(
          color: borderColor,
        ),
      ),
      height: 40,
      child: Text(
        AppLocalizations.of(context)!.backupSeedHoldToReveal,
        style: context.textTheme.titleSmall?.copyWith(
          color: textColor,
        ),
      ),
    );

    return GestureDetector(
      onLongPress: () {
        _saveDateTimeAndEnableHold();
      },
      onLongPressUp: () {
        setState(() {
          _isHoldEnabled = false;
          _wasSeedRevealed = true;
        });
      },
      child: outlinedText,
    );
  }

  void _saveDateTimeAndEnableHold() {
    _saveDateTime();
    setState(() {
      _isHoldEnabled = true;
    });
  }

  void _saveDateTime() {
    _lastTimeSeedWasAccessedNotifier.value =
        DateTime.now().millisecondsSinceEpoch;
    sharedPrefsService.put(
      kLastTimeSeedWasShownKey,
      _lastTimeSeedWasAccessedNotifier.value,
    );
  }

  Widget _buildBackupInfo(BuildContext context) {
    return WarningWidget(
      iconData: Icons.info,
      fillColor: context.colorScheme.primaryContainer,
      textColor: context.colorScheme.onPrimaryContainer,
      text: AppLocalizations.of(context)!.backupSeedInfoDescription,
    );
  }

  Widget _buildBackupWarning(BuildContext context) {
    return WarningWidget(
      iconData: Icons.warning,
      fillColor: context.colorScheme.errorContainer,
      textColor: context.colorScheme.error,
      text: AppLocalizations.of(context)!.backupSeedAlertDescription,
    );
  }

  Widget _buildBackupSeedAccessedWarning(BuildContext context) {
    return WarningWidget(
      iconData: Icons.warning,
      fillColor: context.colorScheme.background,
      textColor: context.colorScheme.error,
      text: AppLocalizations.of(context)!.backupSeedAlertAccessed,
    );
  }

  Widget _buildCopySeedCheckBox() {
    final Widget checkBox = Switch(
      value: _shouldShowCopySeedButton,
      onChanged: (value) {
        setState(() {
          _shouldShowCopySeedButton = value;
        });
      },
    );

    final Widget copySeedButton = CopyToClipboardButton(
      afterCopyCallback: () {
        setState(() {
          _wasSeedRevealed = true;
        });
        _saveDateTime();
        Timer(const Duration(minutes: 1), () {
          clearClipboard();
        });
      },
      iconColor: znnColor,
      text: _mnemonic.join(' '),
    );

    final Text description = Text(
      AppLocalizations.of(context)!.backupSeedCheckbox,
    );

    return Row(
      children: [
        checkBox,
        const SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: description,
        ),
        Visibility(
          visible: _shouldShowCopySeedButton,
          child: copySeedButton,
        ),
      ],
    );
  }
}

class _CreateWalletOnboarding extends StatelessWidget {
  const _CreateWalletOnboarding();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildListTile(
          context: context,
          iconData: Icons.backup_table,
          title: AppLocalizations.of(context)!.backupWalletModalFirstTitle,
          subTitle:
              AppLocalizations.of(context)!.backupWalletModalFirstDescription,
        ),
        _buildListTile(
          context: context,
          iconData: Icons.emergency,
          title: AppLocalizations.of(context)!.backupWalletModalSecondTitle,
          subTitle:
              AppLocalizations.of(context)!.backupWalletModalSecondDescription,
        ),
        _buildListTile(
          context: context,
          iconData: Icons.screen_share,
          title: AppLocalizations.of(context)!.backupWalletModalThirdTitle,
          subTitle:
              AppLocalizations.of(context)!.backupWalletModalThirdDescription,
        ),
        SyriusFilledButton(
          text: AppLocalizations.of(context)!.continueButton,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ].addSeparator(kVerticalSpacer),
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required IconData iconData,
    required String title,
    required String subTitle,
  }) {
    final Widget leading = CircleAvatar(
      backgroundColor: context.colorScheme.primaryContainer,
      child: Icon(iconData),
    );

    final Widget subtitleWidget = Text(
      subTitle,
    );

    final Widget titleWidget = Text(
      title,
    );

    return ListTile(
      leading: leading,
      subtitle: subtitleWidget,
      title: titleWidget,
    );
  }
}
