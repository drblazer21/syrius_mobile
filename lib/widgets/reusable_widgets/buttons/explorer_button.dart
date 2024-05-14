import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:syrius_mobile/utils/utils.dart';

class ExplorerButton extends IconButton {
  ExplorerButton({
    required String hash,
    super.key,
    Color? iconColor,
  }) : super(
          onPressed: () {
            launchUrl('$kZenonHubExplorer/explorer/transaction/$hash');
          },
          icon: Icon(
            MdiIcons.compass,
            color: iconColor,
          ),
        );
}
