import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen>
    with AutomaticKeepAliveClientMixin {
  final LatestTransactionsBloc _latestTransactionsBloc =
      sl.get<LatestTransactionsBloc>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _latestTransactionsBloc.refreshResults();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.activity,
      withLateralPadding: false,
      withBottomPadding: false,
      child: Consumer<SelectedAddressNotifier>(
        builder: (BuildContext context, value, Widget? child) {
          _latestTransactionsBloc.refreshResults();
          return child!;
        },
        child: PaginatedListView<AccountBlock>(
          bloc: _latestTransactionsBloc,
          disposeBloc: false,
          itemBuilder: (_, accountBlock, __) {
            return ActivityItem(
              accountBlock: accountBlock,
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _latestTransactionsBloc.dispose();
    super.dispose();
  }
}
