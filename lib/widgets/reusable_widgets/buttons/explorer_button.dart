import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:syrius_mobile/utils/utils.dart';

class ExplorerButton extends IconButton {
  ExplorerButton({
    required String url,
    Color? iconColor,
    super.key,
  }) : super(
          onPressed: () {
            launchUrl(url);
          },
          icon: Icon(
            MdiIcons.compass,
            color: iconColor,
          ),
        );
}
