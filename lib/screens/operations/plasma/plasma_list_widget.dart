import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/screens/screens.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class PlasmaListWidget extends StatefulWidget {
  const PlasmaListWidget({super.key});

  @override
  State<PlasmaListWidget> createState() => _PlasmaListWidgetState();
}

class _PlasmaListWidgetState extends State<PlasmaListWidget> {
  final PlasmaListBloc _plasmaListBloc = PlasmaListBloc();

  @override
  Widget build(BuildContext context) {
    return PaginatedListView(
      bloc: _plasmaListBloc,
      title: AppLocalizations.of(context)!.plasmaListTitle,
      itemBuilder: (BuildContext context, FusionEntry item, int a) {
        return PlasmaListItem(
          plasmaItem: item,
          plasmaListBloc: _plasmaListBloc,
        );
      },
    );
  }

  @override
  void dispose() {
    _plasmaListBloc.dispose();
    super.dispose();
  }
}
