import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/model/block_chain.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class UnwrapSignedRequestsScreen extends StatefulWidget {
  final UnwrapSignedRequestsBloc unwrapSignedRequestsBloc;

  const UnwrapSignedRequestsScreen({
    required this.unwrapSignedRequestsBloc,
    super.key,
  });

  @override
  State<UnwrapSignedRequestsScreen> createState() =>
      _UnwrapSignedRequestsScreenState();
}

class _UnwrapSignedRequestsScreenState extends State<UnwrapSignedRequestsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (kSelectedAppNetworkWithAssets!.network.blockChain == BlockChain.evm) {
      return const SyriusErrorWidget(
        'Switch to Zenon to check pending wZNN unwrap requests',
      );
    }
    return Consumer<SelectedAddressNotifier>(
      builder: (BuildContext context, value, Widget? child) {
        widget.unwrapSignedRequestsBloc.refreshResults();
        return child!;
      },
      child: PaginatedListView<UnwrapTokenRequest>(
        bloc: widget.unwrapSignedRequestsBloc,
        itemBuilder: (_, unwrapTokenRequest, __) {
          return UnwrapSignedRequest(
            unwrapTokenRequest: unwrapTokenRequest,
          );
        },
      ),
    );
  }
}
