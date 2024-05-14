import 'package:flutter/material.dart';

class AddressAvatar extends StatelessWidget {
  final String baseString;
  final double dimension;
  final int gridResolution;
  final List<Color> colors;

  const AddressAvatar({
    super.key,
    required this.baseString,
    required this.dimension,
    this.gridResolution = 10,
    this.colors = const [
      Colors.black,
      Colors.white,
      Colors.grey,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.purple,
      Colors.cyan,
      Colors.teal,
      Colors.indigo,
      Colors.deepPurpleAccent,
    ],
  });

  @override
  Widget build(BuildContext context) {
    final List<int> colorIndexes =
        baseString.codeUnits.map((byte) => byte % colors.length).toList();

    final List<Widget> rows = [];
    for (int i = 0; i < gridResolution; i++) {
      final List<Widget> row = [];
      for (int j = 0; j < gridResolution; j++) {
        final int colorIndex =
            colorIndexes[(i * gridResolution + j) % colorIndexes.length];
        row.add(
          Container(
            color: colors[colorIndex],
            width: dimension / gridResolution,
            height: dimension / gridResolution,
          ),
        );
      }
      rows.add(Row(children: row));
    }

    return SizedBox(
      width: dimension,
      height: dimension,
      child: Column(children: rows),
    );
  }
}
