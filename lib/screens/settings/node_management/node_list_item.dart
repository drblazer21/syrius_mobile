import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class NodeListItem extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final bool isSelected;

  const NodeListItem({
    required this.isSelected,
    required this.onTap,
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(16.0);

    return ListTile(
      leading: _buildLeading(context),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: context.colorScheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      title: _buildTitle(),
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
      child: SvgIcon(
        iconFileName: 'settings/node_management',
        iconColor: context.colorScheme.onPrimaryContainer,
      ),
    );
  }
}
