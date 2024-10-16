import 'package:flutter/material.dart';
import 'package:syrius_mobile/database/database.dart';

/// Dropdown used to select the address on which to receive the change
/// from the transaction

class ChangeAddressDropdownMenu extends StatelessWidget {
  final List<AppAddress> addresses;
  final AppAddress initialSelection;
  final ValueChanged<AppAddress?> onSelected;

  const ChangeAddressDropdownMenu({
    required this.addresses,
    required this.initialSelection,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuEntry<AppAddress>> entries = List.generate(
      addresses.length, (index) => _buildEntry(addresses[index]),);

    return DropdownMenu<AppAddress>(
      dropdownMenuEntries: entries,
      initialSelection: initialSelection,
      helperText: 'Change address',
      width: double.infinity,
      onSelected: onSelected,
    );
  }

  DropdownMenuEntry<AppAddress> _buildEntry(AppAddress address) {
    return DropdownMenuEntry<AppAddress>(
      value: address,
      label: address.label,
    );
  }
}
