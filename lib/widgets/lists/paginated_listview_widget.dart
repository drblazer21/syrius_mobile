import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';

class PaginatedListView<T> extends StatefulWidget {
  final InfiniteScrollBloc<T> bloc;
  final bool disposeBloc;
  final ItemWidgetBuilder<T> itemBuilder;
  final String? title;

  const PaginatedListView({
    required this.bloc,
    required this.itemBuilder,
    super.key,
    this.disposeBloc = true,
    this.title,
  });

  @override
  State createState() => _InfiniteScrollTableState<T>();
}

class _InfiniteScrollTableState<T> extends State<PaginatedListView<T>> {
  final PagingController<int, T> _pagingController = PagingController(
    firstPageKey: 0,
  );
  late StreamSubscription _blocListingStateSubscription;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      widget.bloc.onPageRequestSink.add(pageKey);
    });
    _blocListingStateSubscription =
        widget.bloc.onNewListingState.listen((listingState) {
      _pagingController.value = PagingState(
        nextPageKey: listingState.nextPageKey,
        error: listingState.error,
        itemList: listingState.itemList,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) _buildHeader(),
        Expanded(
          child: RefreshIndicator.adaptive(
            onRefresh: () async {
              widget.bloc.refreshResults();
            },
            child: PagedListView<int, T>.separated(
              pagingController: _pagingController,
              physics: const AlwaysScrollableScrollPhysics(),
              builderDelegate: PagedChildBuilderDelegate<T>(
                itemBuilder: widget.itemBuilder,
                firstPageProgressIndicatorBuilder: (_) =>
                    const SyriusLoadingWidget(),
                newPageProgressIndicatorBuilder: (_) =>
                    const SyriusLoadingWidget(),
                noItemsFoundIndicatorBuilder: (_) => SyriusErrorWidget(
                  AppLocalizations.of(context)!.nothingToShow,
                ),
              ),
              separatorBuilder: (_, __) => const SizedBox(
                height: 20.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _blocListingStateSubscription.cancel();
    if (widget.disposeBloc) {
      widget.bloc.dispose();
    }
    super.dispose();
  }

  Widget _buildHeader() {
    final title = _buildTitle();

    return Padding(
      padding: context.listTileTheme.contentPadding!,
      child: Column(
        children: [
          title,
          kVerticalSpacer,
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.title!,
      style: context.textTheme.titleMedium,
    );
  }

  List<T>? getTableItems() => _pagingController.value.itemList;
}
