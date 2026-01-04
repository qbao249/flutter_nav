import 'package:flutter/widgets.dart';

import 'nav_state.dart';

/// A class representing a navigation route.
class NavRoute {
  NavRoute({required this.path, required this.builder});
  final String path;
  final Widget Function(BuildContext context, NavState state) builder;
}
