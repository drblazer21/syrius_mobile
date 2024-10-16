import 'package:flutter/material.dart';
import 'package:syrius_mobile/blocs/accelerator/accelerator.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class AcceleratorProjectListScreen extends StatefulWidget {
  const AcceleratorProjectListScreen({super.key});

  @override
  State<AcceleratorProjectListScreen> createState() => _AcceleratorProjectListScreenState();
}

class _AcceleratorProjectListScreenState extends State<AcceleratorProjectListScreen> {
  final PillarsBloc _pillarsBloc = PillarsBloc();


  @override
  void initState() {
    super.initState();
    _pillarsBloc.fetchInfo();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbarScreen(
      appbarTitle: 'Project List',
      child: StreamBuilder<List<PillarInfo>>(
        stream: _pillarsBloc.stream,
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            return SyriusErrorWidget(snapshot.error.toString());
          } else if (snapshot.hasData) {
            return AcceleratorProjectList(
              pillarInfo:
                  snapshot.data!.isNotEmpty ? snapshot.data!.first : null,
            );
          }
          return const SyriusLoadingWidget();
        },
      ),
    );
  }
}
