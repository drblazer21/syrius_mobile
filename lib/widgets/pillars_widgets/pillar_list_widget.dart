import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:logging/logging.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class PillarsListWidget extends StatefulWidget {
  final String? title;

  const PillarsListWidget({super.key, this.title});

  @override
  State<PillarsListWidget> createState() => _PillarsListWidgetState();
}

class _PillarsListWidgetState extends State<PillarsListWidget> {
  final PagingController<int, PillarInfo> _pagingController = PagingController(
    firstPageKey: 0,
  );
  late StreamSubscription _blocListingStateSubscription;

  final PillarsListBloc _pillarsListBloc = PillarsListBloc();
  final DelegationInfoBloc _delegationInfoBloc = DelegationInfoBloc();

  DelegationInfo? _delegationInfo;

  List<PillarDetail> pillarDetails = [];
  late Future<List<PillarDetail>> _listPillarDetails;

  @override
  void initState() {
    super.initState();
    refreshBalanceAndTx();
    _listPillarDetails = getPillarDetail();
    _pagingController.addPageRequestListener((pageKey) {
      _pillarsListBloc.onPageRequestSink.add(pageKey);
    });
    _blocListingStateSubscription = _pillarsListBloc.onNewListingState.listen(
      (listingState) {
        _pagingController.value = PagingState(
          nextPageKey: listingState.nextPageKey,
          error: listingState.error,
          itemList: listingState.itemList,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _getDelegationInfo(
      _pillarsListBloc,
      _delegationInfoBloc,
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _pillarsListBloc.dispose();
    _delegationInfoBloc.dispose();
    _blocListingStateSubscription.cancel();
    super.dispose();
  }

  Widget _getList(PillarsListBloc pillarsListBloc) {
    return FutureBuilder<List<PillarDetail>>(
      future: _listPillarDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SyriusLoadingWidget();
        }
        if (snapshot.hasData) {
          Logger('PillarsListWidget')
              .log(Level.INFO, '_getList', snapshot.data);
          pillarDetails = snapshot.data!;
        }
        return PaginatedListView(
          bloc: pillarsListBloc,
          itemBuilder: (_, PillarInfo pillarInfo, index) {
            return InkWell(
              borderRadius: BorderRadius.circular(7.0),
              onTap: () {
                showPillarDetailScreen(
                  context: context,
                  delegationInfo: _delegationInfo,
                  delegationInfoBloc: _delegationInfoBloc,
                  pillarInfo: pillarInfo,
                  pillarsListBloc: pillarsListBloc,
                );
              },
              child: PillarListItem(
                pillarInfo: pillarInfo,
                delegationInfo: _delegationInfo,
                count: index + 1,
              ),
            );
          },
          title: AppLocalizations.of(context)!.pillarListTitle,
        );
      },
    );
  }

  Widget _getDelegationInfo(
    PillarsListBloc pillarsListBloc,
    DelegationInfoBloc delegationInfoBloc,
  ) {
    return StreamBuilder<DelegationInfo?>(
      stream: _delegationInfoBloc.stream,
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          return SyriusErrorWidget(snapshot.error!);
        }
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            Logger('PillarsListWidget')
                .log(Level.INFO, '_getDelegationInfo', snapshot.data);
            _delegationInfo = snapshot.data;
          } else {
            _delegationInfo = null;
          }
          return _getList(pillarsListBloc);
        }
        return const SyriusLoadingWidget();
      },
    );
  }
}
