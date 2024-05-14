import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.settings,
      withLateralPadding: false,
      child: ListView.builder(
        itemBuilder: (_, index) => _buildSettingItems(context)[index],
        itemCount: _buildSettingItems(context).length,
      ),
    );
  }

  List<Widget> _buildSettingItems(BuildContext context) {
    return [
      ListTile(
        title: Text(
          'General',
          style: context.textTheme.titleSmall
              ?.copyWith(color: znnColor, fontWeight: FontWeight.bold),
        ),
      ),
      SettingsListItem(
        image: 'settings/node_management',
        title: AppLocalizations.of(context)!.nodeManagement,
        onTap: () => showNodeManagementScreen(
          context,
        ),
      ),
      SettingsListItem(
        image: 'settings/wallet_connect',
        title: AppLocalizations.of(context)!.walletConnectTitle,
        onTap: () {
          showWalletConnectScreen(context);
        },
      ),
      SettingsListItem(
        image: 'settings/update',
        title: AppLocalizations.of(context)!.update,
        onTap: () {
          launchUrl(kSyriusMobileGithub);
        },
      ),
      SettingsListItem(
        imageWidget: Icon(
          MdiIcons.shredder,
          color: context.colorScheme.onPrimaryContainer,
        ),
        onTap: () {
          showKeyStoreAuthentication(
            context: context,
            onSuccess: (_) {
              Navigator.pop(context);
              final bool shouldCheckForOtp = sharedPrefsService.get(
                kUseOtpForDeletingWalletKey,
                defaultValue: false,
              )!;
              if (shouldCheckForOtp) {
                showOtpCodeConfirmationScreen(
                  context: context,
                  onCodeValid: (_) {
                    Navigator.pop(context);
                    showDeleteWalletScreen(context: context);
                  },
                );
              } else {
                showDeleteWalletScreen(context: context);
              }
            },
          );
        },
        title: AppLocalizations.of(context)!.deleteWallet,
      ),
      ListTile(
        title: Text(
          'Security',
          style: context.textTheme.titleSmall
              ?.copyWith(color: znnColor, fontWeight: FontWeight.bold),
        ),
      ),
      SettingsListItem(
        image: 'settings/backup',
        title: AppLocalizations.of(context)!.seedBackup,
        onTap: () {
          showKeyStoreAuthentication(
            context: context,
            onSuccess: (_) {
              Navigator.pop(context);
              final bool shouldCheckForOtp = sharedPrefsService.get(
                kUseOtpForRevealingSeedKey,
                defaultValue: false,
              )!;
              if (shouldCheckForOtp) {
                showOtpCodeConfirmationScreen(
                  context: context,
                  onCodeValid: (_) {
                    Navigator.pop(context);
                    showBackupWalletScreen(context);
                  },
                );
              } else {
                showBackupWalletScreen(context);
              }
            },
          );
        },
      ),
      SettingsListItem(
        imageWidget: Icon(
          Icons.fingerprint_outlined,
          color: context.colorScheme.onPrimaryContainer,
        ),
        title: AppLocalizations.of(context)!.biometry,
        onTap: () {
          showKeyStoreAuthentication(
            context: context,
            onSuccess: (pin) {
              Navigator.pop(context);
              final bool shouldCheckForOtp = sharedPrefsService.get(
                kUseOtpForModifyingBiometryUseKey,
                defaultValue: false,
              )!;
              if (shouldCheckForOtp) {
                showOtpCodeConfirmationScreen(
                  context: context,
                  onCodeValid: (_) {
                    Navigator.pop(context);
                    _navigateToActivateBiometryPage(context, pin);
                  },
                );
              } else {
                _navigateToActivateBiometryPage(context, pin);
              }
            },
          );
        },
      ),
      SettingsListItem(
        image: 'settings/lock',
        title: AppLocalizations.of(context)!.otp,
        onTap: () {
          showKeyStoreAuthentication(
            context: context,
            onSuccess: (_) {
              Navigator.pop(context);
              final bool shouldCheckForOtp = sharedPrefsService.get(
                kWasOtpSecretKeyStoredKey,
                defaultValue: false,
              )!;
              if (shouldCheckForOtp) {
                showOtpCodeConfirmationScreen(
                  context: context,
                );
              } else {
                showOtpScreen(context);
              }
            },
          );
        },
      ),
      SettingsListItem(
        imageWidget: Icon(
          Icons.screenshot_outlined,
          color: context.colorScheme.onPrimaryContainer,
        ),
        onTap: () {
          showKeyStoreAuthentication(
            context: context,
            onSuccess: (_) {
              Navigator.pop(context);
              showScreenshotScreen(context: context);
            },
          );
        },
        title: AppLocalizations.of(context)!.screenshotTitle,
      ),
      ListTile(
        title: Text(
          'Community',
          style: context.textTheme.titleSmall
              ?.copyWith(color: znnColor, fontWeight: FontWeight.bold),
        ),
      ),
      SettingsListItem(
        imageWidget: Icon(
          MdiIcons.compassOutline,
          color: context.colorScheme.onPrimaryContainer,
        ),
        title: 'ZenonHub Explorer',
        onTap: () {
          launchUrl('$kZenonHubExplorer/explorer');
        },
      ),
      SettingsListItem(
        imageWidget: Icon(
          MdiIcons.tools,
          color: context.colorScheme.onPrimaryContainer,
        ),
        title: 'ZenonTools',
        onTap: () {
          launchUrl(kZenonTools);
        },
      ),
      SettingsListItem(
        imageWidget: Icon(
          MdiIcons.forum,
          color: context.colorScheme.onPrimaryContainer,
        ),
        title: 'ZenonORG Forum',
        onTap: () {
          launchUrl(kOrgForum);
        },
      ),
      SettingsListItem(
        imageWidget: Icon(
          MdiIcons.forumOutline,
          color: context.colorScheme.onPrimaryContainer,
        ),
        title: 'HyperCore Forum',
        onTap: () {
          launchUrl(kHyperCoreForum);
        },
      ),
      ListTile(
        title: Text(
          'Social',
          style: context.textTheme.titleSmall
              ?.copyWith(color: znnColor, fontWeight: FontWeight.bold),
        ),
      ),
      SettingsListItem(
        imageWidget: Icon(
          Icons.telegram,
          color: context.colorScheme.onPrimaryContainer,
        ),
        title: 'Chat',
        onTap: () {
          launchUrl(kTelegram);
        },
      ),
      SettingsListItem(
        imageWidget: Icon(
          FontAwesomeIcons.xTwitter,
          color: context.colorScheme.onPrimaryContainer,
        ),
        title: 'Follow',
        onTap: () {
          launchUrl(kTwitterX);
        },
      ),
      SettingsListItem(
        imageWidget: Icon(
          Icons.discord,
          color: context.colorScheme.onPrimaryContainer,
        ),
        title: 'Discuss',
        onTap: () {
          launchUrl(kDiscord);
        },
      ),
      SettingsListItem(
        imageWidget: Icon(
          Icons.reddit,
          color: context.colorScheme.onPrimaryContainer,
        ),
        title: 'Post',
        onTap: () {
          launchUrl(kReddit);
        },
      ),
      SettingsListItem(
        imageWidget: Icon(
          FontAwesomeIcons.github,
          color: context.colorScheme.onPrimaryContainer,
        ),
        title: 'Contribute',
        onTap: () {
          launchUrl(kGithub);
        },
      ),
      SettingsListItem(
        imageWidget: Icon(
          FontAwesomeIcons.medium,
          color: context.colorScheme.onPrimaryContainer,
        ),
        title: 'Learn',
        onTap: () {
          launchUrl(kMedium);
        },
      ),
      SettingsListItem(
        imageWidget: Icon(
          MdiIcons.web,
          color: context.colorScheme.onPrimaryContainer,
        ),
        title: 'CoinGecko',
        onTap: () {
          launchUrl(kCoinGecko);
        },
      ),
      ListTile(
        title: Text(
          'About',
          style: context.textTheme.titleSmall
              ?.copyWith(color: znnColor, fontWeight: FontWeight.bold),
        ),
      ),
      SettingsListItem(
        image: 'settings/terms_of_use',
        title: AppLocalizations.of(context)!.termsOfServiceSettingsButton,
        onTap: () {},
      ),
      SettingsListItem(
        image: 'settings/privacy_policy',
        title: AppLocalizations.of(context)!.privacyPolicySettingsButton,
        onTap: () {},
      ),
      SettingsListItem(
        imageWidget: Icon(
          Icons.info,
          color: context.colorScheme.onPrimaryContainer,
        ),
        title: AppLocalizations.of(context)!.information,
        onTap: () {
          showInfoScreen(context: context);
        },
      ),
    ];
  }

  void _navigateToActivateBiometryPage(BuildContext context, String pin) {
    showActivateBiometryScreen(
      context: context,
      onboardingFlow: false,
      pin: pin,
    );
  }
}
