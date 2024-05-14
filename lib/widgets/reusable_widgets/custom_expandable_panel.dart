import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/buttons/copy_to_clipboard_button.dart';

class CustomExpandablePanel extends StatefulWidget {
  final String expandedHeader;
  final String expandedBody;

  const CustomExpandablePanel(
    this.expandedHeader,
    this.expandedBody, {
    super.key,
  });

  @override
  State<CustomExpandablePanel> createState() => _CustomExpandablePanelState();
}

class _CustomExpandablePanelState extends State<CustomExpandablePanel> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        this.isExpanded = isExpanded;
        setState(() {});
      },
      expandedHeaderPadding: const EdgeInsets.all(10.0),
      children: [
        ExpansionPanel(
          isExpanded: isExpanded,
          backgroundColor: context.colorScheme.background,
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(
                widget.expandedHeader,
                style: context.textTheme.titleMedium,
              ),
            );
          },
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              children: [
                CopyToClipboardButton(
                  text: widget.expandedBody,
                  iconColor: Colors.white,
                ),
                Flexible(
                  flex: 3,
                  child: Text(
                    widget.expandedBody,
                    style: context.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
