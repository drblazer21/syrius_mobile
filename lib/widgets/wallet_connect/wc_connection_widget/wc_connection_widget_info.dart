import 'package:flutter/material.dart';
import 'package:syrius_mobile/widgets/wallet_connect/wc_connection_widget/wc_connection_model.dart';

class WCConnectionWidgetInfo extends StatelessWidget {
  const WCConnectionWidgetInfo({
    super.key,
    required this.model,
  });

  final WCConnectionModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        8.0,
      ),
      margin: const EdgeInsetsDirectional.only(
        top: 8.0,
      ),
      child: model.elements != null ? _buildList() : _buildText(),
    );
  }

  Widget _buildList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (model.title != null)
          Text(
            model.title!,
          ),
        if (model.title != null) const SizedBox(height: 8.0),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: model.elements!.map((e) => _buildElement(e)).toList(),
        ),
      ],
    );
  }

  Widget _buildElement(String text) {
    return OutlinedButton(
      onPressed:
          model.elementActions != null ? model.elementActions![text] : () {},
      child: Text(
        text,
      ),
    );
  }

  Widget _buildText() {
    return Text(
      model.text!,
    );
  }
}
