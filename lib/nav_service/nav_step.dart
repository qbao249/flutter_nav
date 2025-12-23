import 'package:flutter/widgets.dart';

import 'nav_state.dart';

class NavStep {
  NavStep({
    required this.path,
    required this.prevState,
    required this.currentState,
    required this.currentRoute,
    this.prevRoute,
  });
  final String path;
  final NavState? prevState;
  final NavState currentState;
  final Route currentRoute;
  final Route? prevRoute;
}
