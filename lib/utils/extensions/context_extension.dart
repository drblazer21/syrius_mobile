import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  ThemeData get themeData => Theme.of(this);

  ColorScheme get colorScheme => themeData.colorScheme;

  TextTheme get textTheme => themeData.textTheme;

  ListTileThemeData get listTileTheme => themeData.listTileTheme;

  TextStyle get defaultListTileSubtitleStyle => textTheme.bodyMedium!.copyWith(
        color: colorScheme.onSurfaceVariant,
      );

  BorderRadius get defaultCardShapeBorderRadius => const BorderRadius.all(
        Radius.circular(12.0),
      );
}
