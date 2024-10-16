import 'package:flutter/material.dart';
import 'package:syrius_mobile/blocs/accelerator/accelerator.dart';
import 'package:syrius_mobile/utils/global.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class AcceleratorProjectDetailsScreen extends StatefulWidget {
  final AcceleratorProject project;
  final PillarInfo? pillarInfo;

  const AcceleratorProjectDetailsScreen({
    required this.project,
    required this.pillarInfo,
    super.key,
  });

  @override
  State<AcceleratorProjectDetailsScreen> createState() =>
      _AcceleratorProjectDetailsScreenState();
}

class _AcceleratorProjectDetailsScreenState
    extends State<AcceleratorProjectDetailsScreen> {
  final RefreshProjectBloc _refreshProjectBloc = RefreshProjectBloc();

  @override
  void initState() {
    super.initState();
    _refreshProjectBloc.refreshProject(widget.project.id);
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: widget.project.name,
      child: RefreshIndicator.adaptive(
        onRefresh: () async {
          _refreshProjectBloc.refreshProject(widget.project.id);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: _getStreamBuilder(),
        ),
      ),
    );
  }

  Widget _getScreenLayout(
    BuildContext context,
    Project project,
  ) {
    return Column(
      children: [
        ProjectsStats(
          project: project,
        ),
        if (project.owner.toString() == kSelectedAddress!.hex)
          CreatePhase(
            project: project,
          ),
        if (project.phases.isEmpty)
          const SyriusErrorWidget('The project has no phases')
        else
          AcceleratorProjectPhaseList(
            widget.pillarInfo,
            project.phases.reversed.toList(),
            projects: project,
          ),
      ],
    );
  }

  Widget _getStreamBuilder() {
    return StreamBuilder<Project?>(
      stream: _refreshProjectBloc.stream,
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          return SyriusErrorWidget(snapshot.error!);
        }
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return _getScreenLayout(context, snapshot.data!);
          }
          return const SyriusLoadingWidget();
        }
        return const SyriusLoadingWidget();
      },
    );
  }
}
