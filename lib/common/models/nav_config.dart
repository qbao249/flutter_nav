import '../models/nav_route.dart';
import '../models/nav_link_handler.dart';
import '../models/nav_base_config.dart';
import '../models/nav_page_service_config.dart';

class NavConfig extends NavBaseConfig {
  const NavConfig({
    required this.routes,
    required super.navigatorKey,
    super.enableLogger,
    this.linkPrefixes,
    this.linkHandlers,
    this.pagePersistence,
  });

  /// List of navigation routes
  final List<NavRoute> routes;

  /// List of link prefixes to match incoming URLs against.
  final List<String>? linkPrefixes;

  /// List of link handlers to process specific link patterns.
  final List<NavLinkHandler>? linkHandlers;

  /// Configuration for page persistence.
  final NavPagePersistence? pagePersistence;
}
