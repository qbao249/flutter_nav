import '../models/nav_route.dart';
import '../models/nav_base_config.dart';

class NavPageServiceConfig extends NavBaseConfig {
  const NavPageServiceConfig({
    required this.routes,
    required super.navigatorKey,
    super.enableLogger = true,
    this.persistence,
  });

  /// List of navigation routes
  final List<NavRoute> routes;

  /// Configuration for page persistence.
  final NavPagePersistence? persistence;
}

class NavPagePersistence {
  const NavPagePersistence({
    required this.onPersist,
    required this.onRestore,
    this.enableSchedule = false,
    this.schedule,
  });

  /// Whether to enable scheduled persistence.
  final bool enableSchedule;

  /// Callback to persist the current navigation state.
  final Future<void> Function(List<Map<String, dynamic>> data) onPersist;

  /// Callback to restore the navigation state.
  final Future<List<Map<String, dynamic>>> Function() onRestore;

  /// Schedule configuration for persistence.
  final NavPagePersistenceSchedule? schedule;
}

class NavPagePersistenceSchedule {
  const NavPagePersistenceSchedule({this.interval, this.immediate});

  /// Interval duration for scheduled persistence.
  final Duration? interval;

  /// Whether to perform immediate persistence on route changes.
  final bool? immediate;
}
