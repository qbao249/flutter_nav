import 'package:flutter/widgets.dart';

class NavBaseConfig {
  const NavBaseConfig({required this.navigatorKey, this.enableLogger = true});

  /// Navigator key to access navigator state
  final GlobalKey<NavigatorState> navigatorKey;

  /// Enable logging for navigation actions
  final bool enableLogger;
}
