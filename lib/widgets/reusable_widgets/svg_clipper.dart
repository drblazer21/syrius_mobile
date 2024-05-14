import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:svg_path_parser/svg_path_parser.dart';

class SVGClipper extends CustomClipper<Path> {
  final String pathData;
  final Size viewBoxSize;

  SVGClipper(this.pathData, this.viewBoxSize);

  @override
  Path getClip(Size size) {
    final Path path = parseSvgPath(pathData);
    return scalePathToFit(path, viewBoxSize, size);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

Path scalePathToFit(Path originalPath, Size viewBoxSize, Size widgetSize) {
  final double scaleX = widgetSize.width / viewBoxSize.width;
  final double scaleY = widgetSize.height / viewBoxSize.height;
  final double scale = ui.lerpDouble(scaleX, scaleY, 0.5)!;

  final Matrix4 matrix = Matrix4.identity()
    ..scale(scale, scale)
    ..translate(
      (widgetSize.width - viewBoxSize.width * scale) / 2,
      (widgetSize.height - viewBoxSize.height * scale) / 2,
    );

  return originalPath.transform(matrix.storage);
}
