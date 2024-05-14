import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:syrius_mobile/utils/utils.dart';

class SyriusNavigatorObserver extends NavigatorObserver {
  @override
  void didPop(Route route, Route? previousRoute) {
    _updateCurrentRoute(newRoute: previousRoute);
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _updateCurrentRoute(newRoute: route);
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _updateCurrentRoute(newRoute: newRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  void _updateCurrentRoute({required Route? newRoute}) {
    Logger('SyriusNavigatorObserver')
        .log(Level.INFO, '_updateCurrentRoute', newRoute?.settings.name);
    currentRoute = newRoute;
  }
}
