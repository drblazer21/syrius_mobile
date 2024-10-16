import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class PlasmaListScreen extends StatefulWidget {
  const PlasmaListScreen({super.key});

  @override
  State<PlasmaListScreen> createState() => _PlasmaListScreenState();
}

class _PlasmaListScreenState extends State<PlasmaListScreen> {
  final PlasmaListBloc _bloc = PlasmaListBloc();

  String getFormattedDate(DateTime dateTime) {
    final DateFormat format = DateFormat('dd MMM');
    return format.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: 'Plasma Stats',
      child: PaginatedListView(
        bloc: _bloc,
        title: 'Plasma List',
        itemBuilder: (BuildContext context, FusionEntry item, int a) {
          return PlasmaListItem(
            plasmaItem: item,
            plasmaListBloc: _bloc,
          );
        },
      ),
    );
  }
}

class PlasmaListItem extends StatefulWidget {
  final FusionEntry plasmaItem;
  final PlasmaListBloc plasmaListBloc;

  const PlasmaListItem({
    super.key,
    required this.plasmaItem,
    required this.plasmaListBloc,
  });

  @override
  State<PlasmaListItem> createState() => _PlasmaListItemState();
}

class _PlasmaListItemState extends State<PlasmaListItem> {
  final CancelPlasmaBloc _cancelPlasmaBloc = CancelPlasmaBloc();
  bool isLoading = false;

  @override
  void dispose() {
    _cancelPlasmaBloc.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _cancelPlasmaBloc.stream.listen(
      (event) {
        if (event != null) {
          setState(() {
            isLoading = false;
          });
          widget.plasmaListBloc.refreshResults();
        }
      },
      onError: (error) {
        if (!mounted) return;
        sendNotificationError(
          AppLocalizations.of(context)!.plasmaCancelError,
          error,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildLeading(),
      subtitle: _buildSubtitle(context),
      title: _buildTitle(context),
      trailing: _buildTrailing(),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    final String prefix = AppLocalizations.of(context)!.beneficiary;
    final String suffix = widget.plasmaItem.beneficiary.toShortString();

    return RichText(
      text: TextSpan(
        style: context.defaultListTileSubtitleStyle,
        children: [
          TextSpan(
            text: prefix,
          ),
          const TextSpan(
            text: '  ●  ',
            style: TextStyle(
              color: qsrColor,
            ),
          ),
          TextSpan(
            text: suffix,
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      '${AppLocalizations.of(context)!.fused} '
      '${widget.plasmaItem.qsrAmount.toStringWithDecimals(
        kQsrCoin.decimals,
      )} ${kQsrCoin.symbol}',
    );
  }

  Widget _buildTrailing() =>
      _getCancelContainer(widget.plasmaItem, widget.plasmaListBloc);

  Widget _buildLeading() {
    return CircleAvatar(
      backgroundColor: qsrColor.withOpacity(0.2),
      child: const Icon(
        Icons.flash_on,
        color: qsrColor,
        size: 20.0,
      ),
    );
  }

  Widget _getCancelButton(
    CancelPlasmaBloc model,
    String plasmaItemId,
  ) {
    final Widget child = isLoading
        ? const CircularProgressIndicator(
            color: qsrColor,
          )
        : _buildClearButton(model, plasmaItemId);
    return child;
  }

  Widget _buildClearButton(
    CancelPlasmaBloc cancelPlasmaBloc,
    String plasmaItemId,
  ) {
    return IconButton(
      color: context.colorScheme.error,
      icon: const Icon(
        Icons.cancel,
      ),
      onPressed: () {
        cancelPlasmaBloc.cancel(plasmaItemId);
        setState(() {
          isLoading = true;
        });
      },
    );
  }

  Widget _getCancelContainer(
    FusionEntry plasmaItem,
    PlasmaListBloc plasmaModel,
  ) {
    return plasmaItem.isRevocable!
        ? _getCancelButton(_cancelPlasmaBloc, plasmaItem.id.toString())
        : _getCancelCountdownTimer(plasmaItem, plasmaModel);
  }

  Widget _getCancelCountdownTimer(
    FusionEntry plasmaItem,
    PlasmaListBloc model,
  ) {
    final int heightUntilCancellation =
        plasmaItem.expirationHeight - model.lastMomentumHeight!;

    final Duration durationUntilCancellation =
        kIntervalBeforeMomentumRefresh * heightUntilCancellation;

    return CancelTimerPercent(
      durationUntilCancellation,
      const Duration(hours: 10),
      znnColor,
      onTimeFinishedCallback: () {
        model.refreshResults();
      },
    );
  }
}
