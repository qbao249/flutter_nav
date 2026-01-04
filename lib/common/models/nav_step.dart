import 'package:flutter/widgets.dart';

import 'nav_state.dart';

/// A class representing a navigation step.
class NavStep {
  NavStep({
    required this.path,
    required this.currentState,
    required this.currentRoute,
    this.prevState,
    this.prevRoute,
  });
  final String path;
  final NavState currentState;
  final Route currentRoute;
  final NavState? prevState;
  final Route? prevRoute;
}
