import '../models/nav_route.dart';
import '../models/nav_base_config.dart';

class NavPageServiceConfig extends NavBaseConfig {
  const NavPageServiceConfig({
    required this.routes,
    required super.navigatorKey,
    super.enableLogger = true,
  });

  /// List of navigation routes
  final List<NavRoute> routes;
}
