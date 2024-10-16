import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/extensions/context_extension.dart';
import 'package:syrius_mobile/widgets/wallet_connect/wc_connection_widget/wc_connection_model.dart';
import 'package:syrius_mobile/widgets/wallet_connect/wc_connection_widget/wc_connection_widget_info.dart';

class WCConnectionWidget extends StatelessWidget {
  const WCConnectionWidget({
    super.key,
    required this.title,
    required this.info,
  });

  final String title;
  final List<WCConnectionModel> info;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          16.0,
        ),
      ),
      padding: const EdgeInsets.all(
        8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(context, title),
          const SizedBox(height: 8.0),
          ...info.map(
            (e) => WCConnectionWidgetInfo(
              model: e,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context, String text) {
    return Text(
      text,
      style: context.textTheme.titleMedium,
    );
  }
}
