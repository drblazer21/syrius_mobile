import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:rxdart/rxdart.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class AcceleratorProjectList extends StatefulWidget {
  final PillarInfo? pillarInfo;

  const AcceleratorProjectList({
    required this.pillarInfo,
    super.key,
  });

  @override
  State<AcceleratorProjectList> createState() => _AcceleratorProjectListState();
}

class _AcceleratorProjectListState extends State<AcceleratorProjectList> {
  final ScrollController _scrollController = ScrollController();
  final PagingController<int, Project> _pagingController = PagingController(
    firstPageKey: 0,
  );
  late StreamSubscription _blocListingStateSubscription;
  late ProjectListBloc _bloc;

  final TextEditingController _searchKeyWordController =
      TextEditingController();

  final StreamController<String> _textChangeStreamController =
      StreamController();
  late StreamSubscription _textChangesSubscription;

  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _bloc = ProjectListBloc(
      pillarInfo: widget.pillarInfo,
    );
    _textChangesSubscription = _textChangeStreamController.stream
        .debounceTime(
          const Duration(seconds: 1),
        )
        .distinct()
        .listen((text) {
      _bloc.onSearchInputChangedSink.add(text);
    });
    _pagingController.addPageRequestListener((pageKey) {
      _bloc.onPageRequestSink.add(pageKey);
    });
    _blocListingStateSubscription = _bloc.onNewListingState.listen(
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
    return _getInfiniteScrollList();
  }

  Widget _getInfiniteScrollList() {
    return Column(
      children: [
        _getSearchInputField(),
        kVerticalSpacer,
        _getProjectsFilterTags(),
        kVerticalSpacer,
        Expanded(
          child: RefreshIndicator.adaptive(
            onRefresh: () async {
              _searchKeyWordController.clear();
              _bloc.refreshResults();
            },
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: PagedListView.separated(
                scrollController: _scrollController,
                pagingController: _pagingController,
                separatorBuilder: (_, __) => const SizedBox(
                  height: 15.0,
                ),
                builderDelegate: PagedChildBuilderDelegate<Project>(
                  itemBuilder: (_, project, __) => AcceleratorProjectListItem(
                    key: ValueKey(
                      project.id.toString(),
                    ),
                    pillarInfo: widget.pillarInfo,
                    acceleratorProject: project,
                  ),
                  firstPageProgressIndicatorBuilder: (_) =>
                      const SyriusLoadingWidget(),
                  firstPageErrorIndicatorBuilder: (_) => SyriusErrorWidget(
                    _pagingController.error.toString(),
                  ),
                  newPageProgressIndicatorBuilder: (_) =>
                      const SyriusLoadingWidget(),
                  noMoreItemsIndicatorBuilder: (_) =>
                      const SyriusErrorWidget('No more items'),
                  noItemsFoundIndicatorBuilder: (_) =>
                      const SyriusErrorWidget('No items found'),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _getSearchInputField() {
    return TextField(
      controller: _searchKeyWordController,
      decoration: const InputDecoration(
        hintText: 'Search by id, owner, name, description, or URL',
        suffixIcon: Icon(
          Icons.search,
          color: Colors.green,
        ),
      ),
      onChanged: _textChangeStreamController.add,
    );
  }

  Widget _getProjectsFilterTags() {
    final List<Widget> children = [];

    for (final tag in AccProjectsFilterTag.values) {
      if (widget.pillarInfo == null) {
        if ([
          AccProjectsFilterTag.votingOpened,
          AccProjectsFilterTag.alreadyVoted,
        ].contains(tag)) {
          continue;
        }
      }
      children.add(_getProjectsFilterTag(tag));
    }

    children.add(
      IconButton(
        onPressed: _sortProjectListByLastUpdate,
        icon: Icon(
          Icons.unfold_more,
          color: Theme.of(context).iconTheme.color,
        ),
      ),
    );

    return Wrap(
      spacing: 5.0,
      children: children,
    );
  }

  Widget _getProjectsFilterTag(AccProjectsFilterTag filterTag) {
    return FilterChip(
      label: Text(extractNameFromEnum(filterTag)),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      selected: _bloc.selectedProjectsFilterTag.contains(filterTag),
      onSelected: (isSelected) {
        if (isSelected) {
          _bloc.selectedProjectsFilterTag.add(filterTag);
        } else {
          _bloc.selectedProjectsFilterTag.remove(filterTag);
        }
        _bloc.refreshResults();
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _textChangesSubscription.cancel();
    _blocListingStateSubscription.cancel();
    _textChangeStreamController.sink.close();
    _textChangeStreamController.close();
    _bloc.onPageRequestSink.close();
    _bloc.onSearchInputChangedSink.close();
    _bloc.dispose();
    _pagingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sortProjectListByLastUpdate() {
    if (_pagingController.itemList != null &&
        _pagingController.itemList!.isNotEmpty) {
      _sortAscending
          ? _pagingController.itemList!.sort(
              (a, b) => a.lastUpdateTimestamp.compareTo(b.lastUpdateTimestamp),
            )
          : _pagingController.itemList!.sort(
              (a, b) => b.lastUpdateTimestamp.compareTo(a.lastUpdateTimestamp),
            );
      setState(() {
        _sortAscending = !_sortAscending;
      });
    }
  }
}
