import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:jailbreak_root_detection/jailbreak_root_detection.dart';
import 'package:syrius_mobile/utils/ui/banner.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class AccessWalletScreen extends StatefulWidget {
  const AccessWalletScreen({super.key});

  @override
  State<AccessWalletScreen> createState() => _AccessWalletScreenState();
}

class _AccessWalletScreenState extends State<AccessWalletScreen> {
  bool isNotTrust = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      isNotTrust = await JailbreakRootDetection.instance.isNotTrust;
    }).whenComplete(
      () => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navState.currentContext!.mounted && isNotTrust) {
          if (Platform.isAndroid) {
            showMaterialBanner(
              context: navState.currentContext!,
              title: AppLocalizations.of(context)!.untrustedDevice,
              icon: MdiIcons.shieldAlert,
              actionButtonText: AppLocalizations.of(context)!.learnMore,
              actionButtonUrl: kRootedWiki,
            );
          } else if (Platform.isIOS) {
            showMaterialBanner(
              context: navState.currentContext!,
              title: AppLocalizations.of(context)!.untrustedDevice,
              icon: MdiIcons.shieldAlert,
              actionButtonText: AppLocalizations.of(context)!.learnMore,
              actionButtonUrl: kJailbrokenWiki,
            );
          }
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Spacer(),
            SvgIcon(
              iconFileName: 'zn_icon',
              iconColor: znnColor,
              size: 72.0,
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton(
                  onPressed: () {
                    showImportWalletScreen(context);
                  },
                  child: Text(AppLocalizations.of(context)!.importWallet),
                ),
                kVerticalSpacer,
                SyriusFilledButton(
                  text: AppLocalizations.of(context)!.createWallet,
                  onPressed: () {
                    showCreatePincodeScreen(context: context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
