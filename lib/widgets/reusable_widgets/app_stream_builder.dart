import 'dart:async';

import 'package:flutter/material.dart';

class AppStreamBuilder<T> extends StatelessWidget {
  final T? initialData;
  final Widget Function(T) builder;
  final Widget Function(String error) customErrorWidget;
  final Widget customLoadingWidget;

  final Stream<T> stream;
  final Function(T)? listener;
  final Function(dynamic)? errorHandler;
  const AppStreamBuilder({
    super.key,
    this.initialData,
    required this.builder,
    required this.stream,
    required this.customErrorWidget,
    required this.customLoadingWidget,
    this.listener,
    this.errorHandler,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      initialData: initialData,
      stream: stream,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        if (snapshot.hasData) {
          return builder(snapshot.data as T);
        } else if (snapshot.hasError) {
          return customErrorWidget(snapshot.error.toString());
        }
        return customLoadingWidget;
      },
    );
  }
}
