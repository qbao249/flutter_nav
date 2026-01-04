import '../models/nav_link_handler.dart';
import '../models/nav_base_config.dart';

class NavLinkServiceConfig extends NavBaseConfig {
  const NavLinkServiceConfig({
    required super.navigatorKey,
    super.enableLogger = true,
    this.linkPrefixes,
    this.linkHandlers,
  });

  /// List of link prefixes to match incoming URLs against.
  final List<String>? linkPrefixes;

  /// List of link handlers to process specific link patterns.
  final List<NavLinkHandler>? linkHandlers;
}
