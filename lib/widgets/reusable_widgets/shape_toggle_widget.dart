import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:syrius_mobile/utils/misc_utils.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/address_avatar.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/svg_clipper.dart';

class ShapeToggleWidget extends StatefulWidget {
  final String svgPath;
  final String pathData;
  final double width;
  final double height;
  final double viewBoxWidth;
  final double viewBoxHeight;

  const ShapeToggleWidget({
    super.key,
    required this.svgPath,
    required this.pathData,
    required this.width,
    required this.height,
    required this.viewBoxWidth,
    required this.viewBoxHeight,
  });

  @override
  _ShapeToggleWidgetState createState() =>
      // ignore: no_logic_in_create_state
      _ShapeToggleWidgetState(pathData, viewBoxWidth, viewBoxHeight);
}

class _ShapeToggleWidgetState extends State<ShapeToggleWidget> {
  bool showSvg = true;
  String pathData = '';
  double viewBoxWidth;
  double viewBoxHeight;
  _ShapeToggleWidgetState(this.pathData, this.viewBoxWidth, this.viewBoxHeight);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        setState(() {
          showSvg = !showSvg;
        });
      },
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: showSvg
            ? SvgPicture.asset(
                widget.svgPath,
                fit: BoxFit.cover,
                height: 90.0,
                colorFilter:
                    const ColorFilter.mode(Colors.white60, BlendMode.srcIn),
              )
            : ClipPath(
                clipper: SVGClipper(
                  pathData,
                  Size(viewBoxWidth, viewBoxHeight),
                ),
                child: AddressAvatar(
                  dimension: 90.0,
                  baseString: selectedAddress.hex,
                ),
              ),
      ),
    );
  }
}
