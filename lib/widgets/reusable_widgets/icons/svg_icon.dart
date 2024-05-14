import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:syrius_mobile/utils/utils.dart';

class SvgIcon extends SvgPicture {
  SvgIcon({
    Key? key,
    required String iconFileName,
    double size = 12.0,
    Color? iconColor,
  }) : super.asset(
          getSvgImagePath(iconFileName),
          key: key,
          colorFilter: iconColor != null
              ? ColorFilter.mode(
                  iconColor,
                  BlendMode.srcIn,
                )
              : null,
          width: size,
          fit: BoxFit.fitWidth,
        );
}
