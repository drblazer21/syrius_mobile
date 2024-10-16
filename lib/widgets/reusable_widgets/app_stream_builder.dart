import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/error_widget.dart';
import 'package:syrius_mobile/widgets/reusable_widgets/loading_widget.dart';

class AppStreamBuilder<T> extends StatelessWidget {
  final T? initialData;
  final Widget Function(T) builder;
  final Widget Function(String error)? customErrorWidget;
  final Widget? customLoadingWidget;

  final Stream<T> stream;
  final Function(T)? listener;
  final Function(dynamic)? errorHandler;

  const AppStreamBuilder({
    super.key,
    this.initialData,
    required this.builder,
    required this.stream,
    this.customErrorWidget,
    this.customLoadingWidget,
    this.listener,
    this.errorHandler,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      initialData: initialData,
      stream: stream,
      builder: (BuildContext context, AsyncSnapshot<T> asyncSnapshot) {
        if (asyncSnapshot.hasData) {
          Logger('AppStreamBuilder').log(Level.INFO, asyncSnapshot.data);
          return builder(asyncSnapshot.data as T);
        } else if (asyncSnapshot.hasError) {
          Logger('AppStreamBuilder').log(Level.INFO, asyncSnapshot.data);
          return customErrorWidget?.call(asyncSnapshot.error.toString()) ??
              SyriusErrorWidget(asyncSnapshot.error.toString());
        }
        return customLoadingWidget ?? const SyriusLoadingWidget();
      },
    );
  }
}
