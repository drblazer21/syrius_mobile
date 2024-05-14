import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/blocs/general_stats_bloc.dart';
import 'package:syrius_mobile/model/general_stats.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/custom_appbar_screen.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/custom_expandable_panel.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/error_widget.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/loading_widget.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  @override
  State createState() {
    return InformationScreenState();
  }
}

class InformationScreenState extends State<InformationScreen> {
  late GeneralStatsBloc _generalStatsBloc;
  late Directory main;
  late Directory cache;

  @override
  void initState() {
    super.initState();

    _generalStatsBloc = GeneralStatsBloc();

    Future.microtask(() async {
      main = await znnDefaultMainDirectory;
      cache = await znnDefaultCacheDirectory;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.information,
      child: _buildStreamBuilder(),
    );
  }

  @override
  void dispose() {
    _generalStatsBloc.dispose();
    super.dispose();
  }

  Widget _getBody(GeneralStats generalStats) {
    return ListView(
      shrinkWrap: true,
      children: [
        ListTile(
          title: Text(
            'Mobile Wallet',
            style: context.textTheme.titleSmall
                ?.copyWith(color: znnColor, fontWeight: FontWeight.bold),
          ),
        ),
        const CustomExpandablePanel(
          'Version',
          kWalletVersion,
        ),
        CustomExpandablePanel(
          'App Signature',
          generalStats.appIntegrity.signature ??
              AppLocalizations.of(context)!.notAvailable,
        ),
        CustomExpandablePanel(
          'App Checksum',
          generalStats.appIntegrity.checksum ??
              AppLocalizations.of(context)!.notAvailable,
        ),
        CustomExpandablePanel(
          AppLocalizations.of(context)!.chainIdentifier,
          getChainIdentifier().toString(),
        ),
        const CustomExpandablePanel(
          'Zenon SDK version',
          znnSdkVersion,
        ),
        CustomExpandablePanel(
          'Main data path',
          main.absolute.path,
        ),
        CustomExpandablePanel(
          'Cache path',
          cache.absolute.path,
        ),
        ListTile(
          title: Text(
            'Device',
            style: context.textTheme.titleSmall
                ?.copyWith(color: znnColor, fontWeight: FontWeight.bold),
          ),
        ),
        CustomExpandablePanel(
          'Hostname',
          Platform.localHostname,
        ),
        CustomExpandablePanel(
          'Operating System',
          Platform.operatingSystem,
        ),
        CustomExpandablePanel(
          'OS version',
          Platform.operatingSystemVersion,
        ),
        CustomExpandablePanel(
          'Number of processors',
          Platform.numberOfProcessors.toString(),
        ),
        CustomExpandablePanel(
          Platform.isIOS ? 'Jailbreak Status' : 'Root Status',
          (generalStats.appIntegrity.isRooted ??
                  AppLocalizations.of(context)!.notAvailable)
              .toString(),
        ),
        CustomExpandablePanel(
          'Real Device Status',
          ((generalStats.appIntegrity.isRealDevice) ??
                  AppLocalizations.of(context)!.notAvailable)
              .toString(),
        ),
        if (Platform.isIOS)
          CustomExpandablePanel(
            'Tampered Status',
            (generalStats.appIntegrity.isTampered ??
                    AppLocalizations.of(context)!.notAvailable)
                .toString(),
          ),
        if (Platform.isAndroid)
          CustomExpandablePanel(
            'App Location External Storage',
            (generalStats.appIntegrity.isOnExternalStorage ??
                    AppLocalizations.of(context)!.notAvailable)
                .toString(),
          ),
        ListTile(
          title: Text(
            'Node',
            style: context.textTheme.titleSmall
                ?.copyWith(color: znnColor, fontWeight: FontWeight.bold),
          ),
        ),
        CustomExpandablePanel(
          AppLocalizations.of(context)!.chainIdentifier,
          generalStats.frontierMomentum.chainIdentifier.toString(),
        ),
        CustomExpandablePanel(
          'Build version',
          generalStats.processInfo.version,
        ),
        CustomExpandablePanel(
          'Git commit hash',
          generalStats.processInfo.commit,
        ),
        CustomExpandablePanel(
          'Kernel version',
          generalStats.osInfo.kernelVersion,
        ),
        CustomExpandablePanel(
          'Operating system',
          generalStats.osInfo.os,
        ),
        CustomExpandablePanel(
          'Platform',
          generalStats.osInfo.platform,
        ),
        CustomExpandablePanel(
          'Platform version',
          generalStats.osInfo.platformVersion,
        ),
        CustomExpandablePanel(
          'Number of processors',
          generalStats.osInfo.numCPU.toString(),
        ),
      ],
    );
  }

  Widget _buildStreamBuilder() {
    return StreamBuilder<GeneralStats>(
      stream: _generalStatsBloc.stream,
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          return _getBody(snapshot.data!);
        } else if (snapshot.hasError) {
          return SyriusErrorWidget(
            snapshot.error.toString(),
          );
        }
        return const SyriusLoadingWidget();
      },
    );
  }
}
