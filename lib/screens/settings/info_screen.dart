import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/blocs/zenon_node_stats_bloc.dart';
import 'package:syrius_mobile/model/app_integrity.dart';
import 'package:syrius_mobile/model/model.dart';
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
  final ZenonNodeStatsBloc _zenonNodeStatsBloc = ZenonNodeStatsBloc();
  final EvmNodeStatsBloc _evmNodeStatsBloc = EvmNodeStatsBloc();
  final BtcNodeStatsBloc _btcNodeStatsBloc = BtcNodeStatsBloc();
  late Directory main;
  late Directory cache;

  @override
  void initState() {
    super.initState();
    final BlockChain blockChain = kSelectedAppNetworkWithAssets!.network.blockChain;
    switch (blockChain) {
      case BlockChain.btc:
        _btcNodeStatsBloc.fetch();
      case BlockChain.nom:
        _zenonNodeStatsBloc.fetch();
      case BlockChain.evm:
        _evmNodeStatsBloc.fetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.information,
      child: FutureBuilder<List<Directory>>(
        future: _initMainAndCacheFields(),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            final List<Directory> data = snapshot.data!;
            main = data[0];
            cache = data[1];
            return _buildBody();
          } else if (snapshot.hasError) {
            return SyriusErrorWidget(snapshot.error.toString());
          }

          return const SyriusLoadingWidget();
        },
      ),
    );
  }

  @override
  void dispose() {
    _evmNodeStatsBloc.dispose();
    _zenonNodeStatsBloc.dispose();
    super.dispose();
  }

  Widget _buildBody() {
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
        FutureBuilder<AppIntegrity>(
          future: getAppIntegrityStatus(),
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              return _buildDevicePanels(snapshot.data!);
            } else if (snapshot.hasError) {
              return SyriusErrorWidget(snapshot.error.toString());
            }
            return const SyriusLoadingWidget();
          },
        ),
        ListTile(
          title: Text(
            'Node',
            style: context.textTheme.titleSmall
                ?.copyWith(color: znnColor, fontWeight: FontWeight.bold),
          ),
        ),
        _buildNodeStats(),
      ],
    );
  }

  Column _buildNomNodePanels(ZenonNodeStats generalStats) {
    return Column(
      children: [
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

  Column _buildDevicePanels(AppIntegrity appIntegrity) {
    return Column(
      children: [
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
          'App Signature',
          appIntegrity.signature ?? AppLocalizations.of(context)!.notAvailable,
        ),
        CustomExpandablePanel(
          'App Checksum',
          appIntegrity.checksum ?? AppLocalizations.of(context)!.notAvailable,
        ),
        CustomExpandablePanel(
          Platform.isIOS ? 'Jailbreak Status' : 'Root Status',
          (appIntegrity.isRooted ?? AppLocalizations.of(context)!.notAvailable)
              .toString(),
        ),
        CustomExpandablePanel(
          'Real Device Status',
          ((appIntegrity.isRealDevice) ??
                  AppLocalizations.of(context)!.notAvailable)
              .toString(),
        ),
        if (Platform.isIOS)
          CustomExpandablePanel(
            'Tampered Status',
            (appIntegrity.isTampered ??
                    AppLocalizations.of(context)!.notAvailable)
                .toString(),
          ),
        if (Platform.isAndroid)
          CustomExpandablePanel(
            'App Location External Storage',
            (appIntegrity.isOnExternalStorage ??
                    AppLocalizations.of(context)!.notAvailable)
                .toString(),
          ),
      ],
    );
  }

  Widget _buildNomStatsStreamBuilder() {
    return StreamBuilder<ZenonNodeStats>(
      stream: _zenonNodeStatsBloc.stream,
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          return _buildNomNodePanels(snapshot.data!);
        } else if (snapshot.hasError) {
          return SyriusErrorWidget(
            snapshot.error.toString(),
          );
        }
        return const SyriusLoadingWidget();
      },
    );
  }

  Widget _buildEvmStatsStreamBuilder() {
    return StreamBuilder<EvmNodeStats>(
      stream: _evmNodeStatsBloc.stream,
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          return _buildEvmNodePanels(snapshot.data!);
        } else if (snapshot.hasError) {
          return SyriusErrorWidget(
            snapshot.error.toString(),
          );
        }
        return const SyriusLoadingWidget();
      },
    );
  }

  Future<List<Directory>> _initMainAndCacheFields() async {
    return Future.wait([
      znnDefaultMainDirectory,
      znnDefaultCacheDirectory,
    ]);
  }

  Column _buildEvmNodePanels(EvmNodeStats evmNodeStats) {
    return Column(
      children: [
        CustomExpandablePanel(
          'Block number',
          evmNodeStats.blockNumber.toString(),
        ),
        CustomExpandablePanel(
          'Client version',
          evmNodeStats.clientVersion,
        ),
        CustomExpandablePanel(
          AppLocalizations.of(context)!.chainIdentifier,
          evmNodeStats.chainId.toString(),
        ),
        CustomExpandablePanel(
          'Network ID',
          evmNodeStats.networkId.toString(),
        ),
        CustomExpandablePanel(
          'Peer count',
          evmNodeStats.peerCount.toString(),
        ),
      ],
    );
  }

  Widget _buildBtcStatsStreamBuilder() {
    return StreamBuilder<ElectrumBtcNodeStats>(
      stream: _btcNodeStatsBloc.stream,
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          return _buildElectrumBtcNodePanels(snapshot.data!);
        } else if (snapshot.hasError) {
          return SyriusErrorWidget(
            snapshot.error.toString(),
          );
        }
        return const SyriusLoadingWidget();
      },
    );
  }

  Column _buildElectrumBtcNodePanels(ElectrumBtcNodeStats electrumBtcNodeStats) {
    return Column(
      children: [
        CustomExpandablePanel(
          'Genesis hash',
          electrumBtcNodeStats.genesisHash,
        ),
        CustomExpandablePanel(
          'Server version',
          electrumBtcNodeStats.serverVersion,
        ),
        CustomExpandablePanel(
          'Hash function',
          electrumBtcNodeStats.hashFunction,
        ),
        CustomExpandablePanel(
          'Protocol min',
          electrumBtcNodeStats.protocolMin,
        ),
        CustomExpandablePanel(
          'Protocol max',
          electrumBtcNodeStats.protocolMax,
        ),
      ],
    );
  }

  Widget _buildNodeStats() {
    final BlockChain blockChain = kSelectedAppNetworkWithAssets!.network.blockChain;

    return switch (blockChain) {
      BlockChain.btc => _buildBtcStatsStreamBuilder(),
      BlockChain.nom => _buildNomStatsStreamBuilder(),
      BlockChain.evm => _buildEvmStatsStreamBuilder(),
    };
  }
}
