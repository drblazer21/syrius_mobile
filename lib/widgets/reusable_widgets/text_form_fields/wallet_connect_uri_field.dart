import 'package:flutter/material.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:wallet_connect_uri_validator/wallet_connect_uri_validator.dart';

class WalletConnectUriField extends StatefulWidget {
  const WalletConnectUriField({
    required this.uriController,
    required this.uriFocusNode,
    super.key,
  });

  final TextEditingController uriController;
  final FocusNode uriFocusNode;

  @override
  State<WalletConnectUriField> createState() => _WalletConnectUriFieldState();
}

class _WalletConnectUriFieldState extends State<WalletConnectUriField> {
  final _uriKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: _uriKey,
      child: TextFormField(
        onChanged: (value) {
          setState(() {});
        },
        controller: widget.uriController,
        focusNode: widget.uriFocusNode,
        validator: _uriValidator,
        decoration: InputDecoration(
          suffixIcon: _buildSuffixIcon(context),
          hintText: 'WalletConnect URI',
        ),
      ),
    );
  }

  Widget _buildSuffixIcon(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PasteIntoTextFormFieldButton(
          afterPasteCallback: (value) {
            setState(() {
              widget.uriController.text = value;
            });
          },
        ),
        Visibility(
          visible: widget.uriController.text.isNotEmpty,
          child: ClearTextFormFieldButton(
            onTap: () {
              setState(() {
                widget.uriController.clear();
              });
            },
          ),
        ),
      ],
    );
  }

  String? _uriValidator(String? uri) {
    if (WalletConnectUri.tryParse(uri ?? '') != null) {
      return null;
    } else {
      return 'URI invalid';
    }
  }
}
