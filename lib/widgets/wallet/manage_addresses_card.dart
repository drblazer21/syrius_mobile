import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class ManageAddressesCard extends StatefulWidget {
  const ManageAddressesCard({
    required this.address,
    required this.onChangedLabel,
    required this.onPressed,
    super.key,
  });

  final AppAddress address;
  final VoidCallback onChangedLabel;
  final Future<void> Function(AppAddress) onPressed;

  @override
  State<ManageAddressesCard> createState() => _ManageAddressesCardState();
}

class _ManageAddressesCardState extends State<ManageAddressesCard> {
  final TextEditingController _newLabelController = TextEditingController();

  bool _isLabelEditable = false;

  String get _newLabel => _newLabelController.text;

  String get _currentLabel => widget.address.label;

  @override
  void initState() {
    super.initState();
    _newLabelController.text = _currentLabel;
  }

  @override
  Widget build(BuildContext context) {
    final Widget title =
        _isLabelEditable ? _buildLabelTextFormField() : _buildLabel();

    final EdgeInsetsGeometry contentPadding =
        context.listTileTheme.contentPadding! / 2;

    return RadioListTile<AppAddress>(
      contentPadding: contentPadding,
      value: widget.address,
      groupValue: selectedAddress,
      onChanged: (AppAddress? value) {
        if (value != null) {
          widget.onPressed(value);
        } else {
          showNotificationSnackBar(
            context,
            content: AppLocalizations.of(context)!.changeAddressError,
          );
        }
      },
      title: title,
      subtitle: _buildSubtitle(context),
    );
  }

  @override
  void dispose() {
    _newLabelController.dispose();
    super.dispose();
  }

  Row _buildSubtitle(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            widget.address.hex,
          ),
        ),
        CopyToClipboardButton(
          text: widget.address.hex,
        ),
      ],
    );
  }

  Row _buildLabel() {
    return Row(
      children: [
        Flexible(
          child: Text(
            _currentLabel,
          ),
        ),
        EditButton(
          onPressed: () {
            setState(() {
              _isLabelEditable = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildLabelTextFormField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _newLabelController,
            decoration: InputDecoration(
              errorText: _newLabelValidator(context),
              hintText: 'New label',
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (value) {
              if (_newLabel != _currentLabel) {
                _onChangeButtonPressed();
              }
            },
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _newLabelController.text = _currentLabel;
              _isLabelEditable = false;
            });
          },
          icon: const Icon(
            Icons.clear_rounded,
          ),
        ),
        Visibility(
          visible: _isNewLabelValid(),
          child: IconButton(
            onPressed: _onChangeButtonPressed,
            icon: const Icon(
              Icons.check,
            ),
          ),
        ),
      ],
    );
  }

  bool _isNewLabelValid() => _newLabelValidator(context) == null;

  Future<void> _onChangeButtonPressed() async {
    try {
      final AppAddress updatedAppAddress = widget.address.copyWith(
        label: _newLabel,
      );

      if (selectedAddress.id == updatedAppAddress.id) {
        selectedAddress = updatedAppAddress;
      }
      await db.appAddressesDao.updateData(
        updatedAppAddress,
      );
      if (!mounted) return;
      Provider.of<SelectedAddressNotifier>(
        context,
        listen: false,
      ).changedAddressLabel();
      setState(() {
        _isLabelEditable = false;
      });
    } catch (e, stackTrace) {
      Logger('ManageAddressesCard').log(
        Level.SEVERE,
        '_onChangeButtonPressed',
        e,
        stackTrace,
      );
      sendNotificationError(
        AppLocalizations.of(context)!.addressChangeError,
        e,
      );
    }
  }

  String? _newLabelValidator(BuildContext context) {
    if (_newLabel.isNotEmpty) {
      if (_newLabel.length <= kAddressLabelMaxLength) {
        final Iterable<String> labels = addressList.map((e) => e.label);
        if (!labels.contains(_newLabel)) {
          return null;
        } else {
          return AppLocalizations.of(context)!.newLabelAlreadyExists;
        }
      } else {
        return AppLocalizations.of(context)!.newLabelHasTooManyCharacters;
      }
    } else {
      return AppLocalizations.of(context)!.newLabelCannotBeEmpty;
    }
  }
}
