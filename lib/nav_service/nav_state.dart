import 'package:flutter/widgets.dart';

import 'nav_extra.dart';

/// A class representing the state of a route.
class NavState {
  NavState({required this.path, this.extra});
  final String path;
  final NavExtra? extra;

  static bool isNavExtra(Object? extra) {
    return extra is NavExtra;
  }

  static NavState? fromRoute(Route route) {
    final routeName = route.settings.name ?? '';
    if (routeName.isEmpty) return null;

    final args = route.settings.arguments;
    if (isNavExtra(args)) {
      return NavState(path: routeName, extra: args! as NavExtra);
    }
    return null;
  }
}
