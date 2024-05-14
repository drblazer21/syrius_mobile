import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/screens/screens.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class NodeSelectionScreen extends StatefulWidget {
  const NodeSelectionScreen({
    super.key,
  });

  @override
  State<NodeSelectionScreen> createState() => _NodeSelectionScreenState();
}

class _NodeSelectionScreenState extends State<NodeSelectionScreen> {
  String? _selectedNode;
  final List<String> _nodes = [...kDefaultNodes, ...kDbNodes];
  final List<NodeFilterTag> _selectedFilterTags = [];

  bool get _isSecuredChipSelected => _selectedFilterTags.contains(
        NodeFilterTag.secured,
      );
  bool get _isCommunityChipSelected => _selectedFilterTags.contains(
        NodeFilterTag.community,
      );

  @override
  Widget build(BuildContext context) {
    final List<String> nodes = _filterNodes(originalList: _nodes);
    final EdgeInsetsGeometry padding = context.listTileTheme.contentPadding!;

    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.nodeManagementSelection,
      withLateralPadding: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: padding,
            child: _buildChips(context: context),
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: nodes.map(
                (node) {
                  final int index = _nodes.indexOf(node);
                  return NodeListItem(
                    title: node,
                    onTap: () {
                      setState(() {
                        _selectedNode = node;
                      });
                    },
                    isSelected: _nodes.indexOf(_selectedNode!) == index,
                  );
                },
              ).toList(),
            ),
          ),
          Padding(
            padding: padding,
            child: SyriusFilledButton(
              text: AppLocalizations.of(context)!.save,
              onPressed: _onConfirmNodeButtonPressed,
            ),
          ),
        ].addSeparator(kVerticalSpacer),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedNode ??= kCurrentNode!;
  }

  Future<void> _onConfirmNodeButtonPressed() async {
    try {
      showLoadingDialog(context);
      final bool isConnectionEstablished =
          await establishConnectionToNode(_selectedNode!);

      if (isConnectionEstablished) {
        await sharedPrefsService.put(
          kSelectedNodeKey,
          _selectedNode,
        );
        kCurrentNode = _selectedNode;
        _sendChangingNodeSuccessNotification();
      } else {
        throw 'Connection could not be established to $_selectedNode';
      }
    } catch (e, stackTrace) {
      Logger('AddNodeScreen')
          .log(Level.SEVERE, 'NodeSelectionScreen', e, stackTrace);
      if (mounted) {
        sendNotificationError(
          AppLocalizations.of(context)!.connectionFailed,
          e,
        );
      }
      setState(() {
        _selectedNode = kCurrentNode;
      });
    } finally {
      if (mounted) {
        clearLoadingDialog(context);
      }
    }
  }

  void _sendChangingNodeSuccessNotification() {
    sl.get<NotificationsBloc>().addNotification(
          WalletNotification(
            title: 'Successfully connected',
            timestamp: DateTime.now().millisecondsSinceEpoch,
            details: 'Successfully connected to $_selectedNode',
          ),
        );
  }

  Widget _buildChips({
    required BuildContext context,
  }) {
    final List<Widget> chips = List.generate(
      NodeFilterTag.values.length,
      (index) {
        final NodeFilterTag tag = NodeFilterTag.values.elementAt(index);

        return _buildChip(context: context, tag: tag);
      },
    );

    return Wrap(
      spacing: kIconAndTextHorizontalSpacer.width!,
      children: chips,
    );
  }

  FilterChip _buildChip({
    required BuildContext context,
    required NodeFilterTag tag,
  }) {
    final bool isSelected = _selectedFilterTags.contains(tag);

    return FilterChip(
      label: Text(tag.localizedTitle(context)),
      selected: isSelected,
      onSelected: (bool value) {
        setState(() {
          _updateNodeFilterTag(
            tag: tag,
            isSelected: value,
          );
        });
      },
    );
  }

  List<String> _filterNodes({required List<String> originalList}) {
    return originalList.fold(
      [],
      (previousValue, node) {
        bool shouldAddNode = true;
        if (_isSecuredChipSelected && !node.contains('wss')) {
          shouldAddNode = false;
        }
        if (_isCommunityChipSelected && !kCommunityNodes.contains(node)) {
          shouldAddNode = false;
        }

        if (shouldAddNode) {
          return previousValue + [node];
        } else {
          return previousValue;
        }
      },
    );
  }

  void _updateNodeFilterTag({
    required NodeFilterTag tag,
    required bool isSelected,
  }) {
    if (isSelected) {
      _selectedFilterTags.add(tag);
    } else {
      _selectedFilterTags.remove(tag);
    }
  }
}
