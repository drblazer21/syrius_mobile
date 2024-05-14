import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/constants.dart';
import 'package:syrius_mobile/utils/notifiers/screenshot_feature_notifier.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/custom_appbar_screen.dart';

class ScreenshotScreen extends StatefulWidget {
  const ScreenshotScreen({super.key});

  @override
  State<ScreenshotScreen> createState() => _ScreenshotScreenState();
}

class _ScreenshotScreenState extends State<ScreenshotScreen> {
  late bool _isScreenshotFeatureEnabled;

  @override
  void initState() {
    super.initState();
    _isScreenshotFeatureEnabled = sharedPrefsService.get<bool>(
      kIsScreenshotFeatureEnabledKey,
      defaultValue: false,
    )!;
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.screenshotTitle,
      child: Row(
        children: [
          _buildSwitch(),
          const SizedBox(
            width: 8.0,
          ),
          _buildSwitchDescription(context),
        ],
      ),
    );
  }

  Widget _buildSwitchDescription(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.enableScreenshotFeature,
    );
  }

  Widget _buildSwitch() {
    return Switch(
      value: _isScreenshotFeatureEnabled,
      onChanged: (bool value) {
        sharedPrefsService.put(kIsScreenshotFeatureEnabledKey, value).then(
          (_) {
            final ScreenshotFeatureNotifier screenshotFeatureNotifier =
                Provider.of<ScreenshotFeatureNotifier>(context, listen: false);

            setState(() {
              _isScreenshotFeatureEnabled = value;
            });

            screenshotFeatureNotifier.isEnabled = value;
          },
        );
      },
    );
  }
}
