import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/accelerator/accelerator.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

enum AcceleratorPhaseFilterTag {
  myProjects,
  onlyAccepted,
  votingOpened;
}

class AcceleratorProjectPhaseList extends StatefulWidget {
  final PillarInfo? pillarInfo;
  final List<AcceleratorProject> acceleratorProjects;
  final Project? projects;

  const AcceleratorProjectPhaseList(
    this.pillarInfo,
    this.acceleratorProjects, {
    this.projects,
    super.key,
  });

  @override
  State<AcceleratorProjectPhaseList> createState() =>
      _AcceleratorProjectPhaseListState();
}

class _AcceleratorProjectPhaseListState
    extends State<AcceleratorProjectPhaseList> {
  final TextEditingController _searchKeyWordController =
      TextEditingController();

  final List<AcceleratorPhaseFilterTag> _selectedProjectsFilterTag = [];

  final ScrollController _scrollController = ScrollController();

  String _searchKeyWord = '';

  @override
  Widget build(BuildContext context) {
    final Set<AcceleratorProject> items =
        _filterBaseProjects(widget.acceleratorProjects);

    final List<Widget> itemWidgets = items.map((e) => _generateItem(e)).toList();

    return Column(
      children: [
        const SizedBox(
          height: 10.0,
        ),
        _getSearchInputField(),
        const SizedBox(
          height: 10.0,
        ),
        if (widget.acceleratorProjects.first is Project)
          _getProjectsFilterTags(),
        if (widget.acceleratorProjects.first is Project)
          const SizedBox(
            height: 10.0,
          ),
        ...itemWidgets.addSeparator(kVerticalSpacer),
      ],
    );
  }

  AcceleratorProjectListItem _generateItem(AcceleratorProject phase) {
    return AcceleratorProjectListItem(
      key: ValueKey(
        phase.id.toString(),
      ),
      pillarInfo: widget.pillarInfo,
      acceleratorProject: phase,
      project: widget.projects,
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
      onChanged: (value) {
        setState(() {
          _searchKeyWord = value;
        });
      },
    );
  }

  Set<AcceleratorProject> _filterBaseProjects(
    List<AcceleratorProject> acceleratorProjects,
  ) {
    var filteredBaseProjects =
        _filterBaseProjectsBySearchKeyWord(acceleratorProjects);
    if (widget.acceleratorProjects.first is Project &&
        _selectedProjectsFilterTag.isNotEmpty) {
      filteredBaseProjects = _filterProjectsByFilterTags(
        filteredBaseProjects.map((e) => e as Project).toList(),
      );
    }
    return filteredBaseProjects;
  }

  Set<AcceleratorProject> _filterBaseProjectsBySearchKeyWord(
    List<AcceleratorProject> acceleratorProjects,
  ) {
    final filteredBaseProjects = <AcceleratorProject>{};
    filteredBaseProjects.addAll(
      acceleratorProjects.where(
        (element) => element.id.toString().toLowerCase().contains(
              _searchKeyWord.toLowerCase(),
            ),
      ),
    );
    if (acceleratorProjects.first is Project) {
      filteredBaseProjects.addAll(
        acceleratorProjects.where(
          (element) =>
              (element as Project).owner.toString().toLowerCase().contains(
                    _searchKeyWord.toLowerCase(),
                  ),
        ),
      );
    }
    filteredBaseProjects.addAll(
      acceleratorProjects.where(
        (element) => element.name.toLowerCase().contains(
              _searchKeyWord.toLowerCase(),
            ),
      ),
    );
    filteredBaseProjects.addAll(
      acceleratorProjects.where(
        (element) => element.description.toLowerCase().contains(
              _searchKeyWord.toLowerCase(),
            ),
      ),
    );
    filteredBaseProjects.addAll(
      acceleratorProjects.where(
        (element) => element.url.toLowerCase().contains(
              _searchKeyWord.toLowerCase(),
            ),
      ),
    );
    return filteredBaseProjects;
  }

  Widget _getProjectsFilterTags() {
    return Row(
      children: [
        _getProjectsFilterTag(AcceleratorPhaseFilterTag.myProjects),
        _getProjectsFilterTag(AcceleratorPhaseFilterTag.onlyAccepted),
        if (widget.pillarInfo != null)
          _getProjectsFilterTag(AcceleratorPhaseFilterTag.votingOpened),
      ],
    );
  }

  Widget _getProjectsFilterTag(AcceleratorPhaseFilterTag filterTag) {
    return FilterChip(
      label: Text(extractNameFromEnum(filterTag)),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      selected: _selectedProjectsFilterTag.contains(filterTag),
      onSelected: (isSelected) {
        setState(() {
          if (isSelected) {
            _selectedProjectsFilterTag.add(filterTag);
          } else {
            _selectedProjectsFilterTag.remove(filterTag);
          }
        });
      },
    );
  }

  Set<AcceleratorProject> _filterProjectsByFilterTags(List<Project> projects) {
    var filteredBaseProjects = const Iterable<Project>.empty();
    if (_selectedProjectsFilterTag
        .contains(AcceleratorPhaseFilterTag.myProjects)) {
      filteredBaseProjects = projects.where(
        (project) => project.owner.toString() == kSelectedAddress?.hex,
      );
    }
    if (_selectedProjectsFilterTag
        .contains(AcceleratorPhaseFilterTag.onlyAccepted)) {
      if (filteredBaseProjects.isNotEmpty) {
        filteredBaseProjects = filteredBaseProjects.where(
          (project) => project.status == AcceleratorProjectStatus.active,
        );
      } else {
        filteredBaseProjects = projects.where(
          (project) => project.status == AcceleratorProjectStatus.active,
        );
      }
    }
    if (_selectedProjectsFilterTag
        .contains(AcceleratorPhaseFilterTag.votingOpened)) {
      if (filteredBaseProjects.isNotEmpty) {
        filteredBaseProjects = filteredBaseProjects.where(
          (project) => project.status == AcceleratorProjectStatus.voting,
        );
      } else {
        filteredBaseProjects = projects.where(
          (project) => project.status == AcceleratorProjectStatus.voting,
        );
      }
    }
    return filteredBaseProjects.toSet();
  }

  @override
  void dispose() {
    _searchKeyWordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
