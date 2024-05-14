import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';

class ScrollBarListView extends StatelessWidget {
  final Widget child;
  final ScrollController? scrollController;
  const ScrollBarListView({
    super.key,
    required this.child,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return RawScrollbar(
      thumbColor: context.colorScheme.onBackground,
      radius: const Radius.circular(20),
      thickness: 3,
      controller: scrollController,
      child: child,
    );
  }
}
