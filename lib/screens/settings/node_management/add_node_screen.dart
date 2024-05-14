import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:logging/logging.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class AddNodeScreen extends StatefulWidget {
  const AddNodeScreen({super.key});

  @override
  State<AddNodeScreen> createState() => _AddNodeScreenState();
}

class _AddNodeScreenState extends State<AddNodeScreen> {
  final TextEditingController _nodeController = TextEditingController();
  final FocusNode _nodeFocusNode = FocusNode();

  String get _node => _nodeController.text;

  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.nodeManagementAddNode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.address,
                style: context.textTheme.titleMedium,
              ),
              kVerticalSpacer,
              TextField(
                controller: _nodeController,
                focusNode: _nodeFocusNode,
                onChanged: (e) {
                  setState(() {});
                },
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  errorText: nodeValidator(_node),
                  hintText: AppLocalizations.of(context)!.nodeManagementAddress,
                  suffixIcon: Visibility(
                    visible: _node.isNotEmpty,
                    child: ClearTextFormFieldButton(
                      onTap: () {
                        setState(() {
                          _nodeController.clear();
                        });
                      },
                    ),
                  ),
                ),
                onSubmitted: (String? node) => _onAddNodePressed(context),
              ),
            ],
          ),
          SyriusFilledButton(
            text: AppLocalizations.of(context)!.nodeManagementAddNode,
            onPressed:
                _isUserInputValid() ? () => _onAddNodePressed(context) : null,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nodeController.dispose();
    _nodeFocusNode.dispose();
    super.dispose();
  }

  bool _isUserInputValid() => _node.isNotEmpty && nodeValidator(_node) == null;

  Future<void> _onAddNodePressed(BuildContext context) async {
    if ([...kDbNodes, ...kDefaultNodes].contains(_node)) {
      sendNotificationError(
        AppLocalizations.of(context)!.nodeManagementAddNodeExists,
        AppLocalizations.of(context)!.nodeManagementAddNodeNew,
      );
    } else {
      _addNodeToDb(context);
    }
  }

  Future<void> _addNodeToDb(BuildContext context) async {
    try {
      if (!Hive.isBoxOpen(kNodesBox)) {
        await Hive.openBox<String>(kNodesBox);
      }
      Hive.box<String>(kNodesBox).add(_node);
      await loadDbNodes();
      _sendAddNodeSuccessNotification();
      setState(() {
        _nodeController.clear();
        _nodeFocusNode.unfocus();
      });
    } catch (e, stackTrace) {
      Logger('AddNodeScreen').log(Level.SEVERE, '_addNodeToDb', e, stackTrace);
      if (context.mounted) {
        sendNotificationError(
          AppLocalizations.of(context)!.nodeManagementErrorAdding,
          e,
        );
      }
    }
  }

  void _sendAddNodeSuccessNotification() {
    sl.get<NotificationsBloc>().addNotification(
          WalletNotification(
            title: 'Successfully added node',
            timestamp: DateTime.now().millisecondsSinceEpoch,
            details: 'Successfully added node $_node',
          ),
        );
  }
}
