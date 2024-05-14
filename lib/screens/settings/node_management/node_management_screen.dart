import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class NodeManagementScreen extends StatelessWidget {
  const NodeManagementScreen({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.nodeManagement,
      withLateralPadding: false,
      child: Column(
        children: [
          SettingsListItem(
            image: 'settings/node_management',
            title: AppLocalizations.of(context)!.nodeManagementSelection,
            onTap: () => showNodeSelectionScreen(
              context,
            ),
          ),
          SettingsListItem(
            image: 'settings/add_node_management',
            title: AppLocalizations.of(context)!.nodeManagementAddNode,
            onTap: () => showAddNodeScreen(context),
          ),
        ],
      ),
    );
  }
}
