library;

import 'package:flutter/widgets.dart';
import 'services/page_service/page_service.dart';
import 'services/link_service/link_service.dart';
import 'common/page_route_observer_instance.dart';
import 'common/common.dart';

export 'common/common.dart';
export 'services/services.dart';
export 'widgets/widgets.dart';

class Nav {
  static final observers = <NavigatorObserver>[pageRouteObserverInstance];

  static final PageService page = PageService.instance;

  static final LinkService link = LinkService.instance;

  /// Initialize the Nav system with the provided configuration
  ///
  /// [config] The navigation configuration
  static init(NavConfig config) {
    page.init(
      NavPageServiceConfig(
        navigatorKey: config.navigatorKey,
        enableLogger: config.enableLogger,
        routes: config.routes,
      ),
    );
    link.init(
      NavLinkServiceConfig(
        navigatorKey: config.navigatorKey,
        enableLogger: config.enableLogger,
        linkPrefixes: config.linkPrefixes,
        linkHandlers: config.linkHandlers,
      ),
    );
  }
}
