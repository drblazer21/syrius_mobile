import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class SettingsListItem extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String? image;
  final Widget? imageWidget;

  const SettingsListItem({
    required this.onTap,
    required this.title,
    super.key,
    this.image,
    this.imageWidget,
  }) : assert(image != null || imageWidget != null);

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(7);

    return InkWell(
      borderRadius: borderRadius,
      onTap: onTap,
      child: ListTile(
        leading: _buildLeading(context),
        title: _buildTitle(),
        trailing: _buildTrailing(),
      ),
    );
  }

  Icon _buildTrailing() {
    return const Icon(
      Icons.chevron_right_rounded,
    );
  }

  Text _buildTitle() {
    return Text(
      title,
    );
  }

  Widget _buildLeading(BuildContext context) {
    return CircleAvatar(
      backgroundColor: context.colorScheme.primaryContainer,
      child: image != null
          ? SvgIcon(
              iconFileName: image!,
              iconColor: context.colorScheme.onPrimaryContainer,
              size: 15.0,
            )
          : imageWidget,
    );
  }
}
