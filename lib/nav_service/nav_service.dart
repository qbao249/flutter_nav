import 'dart:async';

import 'package:flutter/material.dart';
import 'nav_extra.dart';
import 'nav_route.dart';
import 'nav_route_info.dart';
import 'nav_state.dart';
import 'nav_step.dart';

part 'navigator_inheritance_service_ext.dart';

class NavServiceConfig {
  const NavServiceConfig({
    required this.routes,
    required this.navigatorKey,
    this.enableLogger = true,
  });
  final bool enableLogger;
  final List<NavRoute> routes;
  final GlobalKey<NavigatorState> navigatorKey;
}

class NavService {
  // Singleton instance
  static final NavService instance = NavService._internal();

  // Factory returns the single instance
  factory NavService() => instance;

  // Private constructor
  NavService._internal();

  // Commonly used navigator key (you can remove or extend as needed)
  GlobalKey<NavigatorState>? _navigatorKey;

  final List<NavStep> _steps = [];

  final Map<String, NavRoute> _routes = {};

  BuildContext? get _currentContext => _navigatorKey?.currentContext;

  /// Route observer to monitor navigation events
  NavigatorObserver get routeObserver => _RouteObserver();

  bool _enableLogger = true;

  void init(NavServiceConfig config) {
    _routes.clear();
    _routes.addAll({for (var route in config.routes) route.path: route});

    _enableLogger = config.enableLogger;

    _navigatorKey = config.navigatorKey;
  }

  /// context.go():
  ///  - route is the last route in full path
  ///  - previousRoute is the route before go(), not is the previous route in full path
  ///
  /// context.push():
  /// - route is the new route being pushed
  /// - previousRoute is the current route before push()
  void _didPush(Route route, Route? previousRoute) {
    // // You can add custom logic here if needed

    final routeName = route.settings.name ?? '';
    if (routeName.isEmpty) return;

    final context = route.navigator?.context;
    if (context == null) return;

    route.settings.arguments;

    final state = NavState.fromRoute(route);

    final prevState = _steps.isNotEmpty ? _steps.last.currentState : null;

    if (state != null) {
      if (_enableLogger) {
        debugPrint('NavService.didPush - $routeName extra is NavigatorExtra');
      }
      _steps.add(
        NavStep(
          path: routeName,
          prevState: prevState,
          currentState: state,
          currentRoute: route,
          prevRoute: previousRoute,
        ),
      );
    } else {
      // from context.go()
      if (_enableLogger) {
        debugPrint(
          'NavService.didPush - ${route.settings.name} extra is NOT NavigatorExtra',
        );
      }
      _steps.removeRange(0, _steps.length);
    }

    if (_enableLogger) {
      debugPrint('NavService._didPush location: $joinedLocation');
    }
  }

  void _didPop(Route route, Route? previousRoute) {
    final routeName = route.settings.name ?? '';
    if (routeName.isEmpty) return;

    if (_steps.isNotEmpty) {
      _steps.removeLast();
    }
    if (_enableLogger) {
      debugPrint('NavService._didPop location: $joinedLocation');
    }
  }

  void _didReplace({Route? newRoute, Route? oldRoute}) {
    if (oldRoute != null && newRoute != null) {
      // Find and update the step with the old route
      for (int i = 0; i < _steps.length; i++) {
        if (_steps[i].currentRoute == oldRoute) {
          final oldStep = _steps[i];
          final newState = NavState.fromRoute(newRoute);

          if (newState != null) {
            _steps[i] = NavStep(
              path: newState.path,
              prevState: oldStep.prevState,
              currentState: newState,
              currentRoute: newRoute,
              prevRoute: oldStep.prevRoute,
            );
          } else {
            // If new route doesn't have NavExtra, remove the step
            _steps.removeAt(i);
          }
          break;
        }
      }
    }
    if (_enableLogger) {
      debugPrint('NavService._didReplace location: $joinedLocation');
    }
  }

  void _didRemove({Route? oldRoute, Route? previousRoute}) {
    if (oldRoute != null) {
      // Remove the step that matches the removed route
      _steps.removeWhere((step) => step.currentRoute == oldRoute);
    }
    if (_enableLogger) {
      debugPrint('NavService._didRemove location: $joinedLocation');
    }
  }

  String get joinedLocation {
    final context = _currentContext;
    if (context == null) return '';
    return _steps.map((e) => e.currentState.path).join();
  }

  MaterialPageRoute _buildPageRoute({
    required String path,
    required NavExtra extra,
    required NavRoute route,
  }) {
    return MaterialPageRoute(
      settings: RouteSettings(name: path, arguments: extra),
      builder: (ctx) => route.builder(ctx, NavState(path: path, extra: extra)),
    );
  }

  //
  // Main navigation methods
  //

  /// If the path exists in the navigation history, navigate back to it.
  /// If not, push a new route.
  ///
  /// [forcePush] forces pushing a new route even if it exists in history.
  void navigate(
    String path, {
    Map<String, dynamic>? extra,
    bool forcePush = false,
  }) {
    final context = _currentContext;
    if (context == null) return;

    final navExtra = NavExtra(extra ?? {});
    final route = _routes[path];

    if (route == null) {
      if (_enableLogger) {
        debugPrint('NavService.navigate: Route not found for path: $path');
      }
      return;
    }

    final navigator = Navigator.of(context);
    final newRoute = _buildPageRoute(path: path, extra: navExtra, route: route);

    // Find if path exists in navigation history
    int existingIndex = -1;
    if (!forcePush) {
      for (int i = _steps.length - 1; i >= 0; i--) {
        if (_steps[i].currentState.path == path) {
          existingIndex = i;
          break;
        }
      }
    }

    if (existingIndex != -1) {
      // Calculate how many routes to remove (all routes after and including the target)
      final routesToRemoveCount = _steps.length - existingIndex;
      int removeCounter = 0;

      navigator.pushAndRemoveUntil(newRoute, (route) {
        // Remove routes from top until we reach the desired point
        removeCounter++;
        return removeCounter > routesToRemoveCount;
      });
    } else {
      // Path doesn't exist or forcePush is true, push new
      navigator.push(newRoute);
    }
  }

  /// Pop all routes with animation
  void popAll() {
    final context = _currentContext;
    if (context == null) return;

    if (_steps.isEmpty) return;

    final navigator = Navigator.of(context);
    final routesToPop = _steps.length;

    if (routesToPop == 1) {
      // Only one route, pop with animation
      navigator.pop();
    } else {
      // Get all routes in the navigator
      final List<Route> allRoutes = [];
      navigator.popUntil((route) {
        allRoutes.add(route);
        return allRoutes.length > routesToPop;
      });
    }
  }

  /// Pops routes until the given [path] is reached
  void popUntilPath(String path) {
    final context = _currentContext;
    if (context == null) return;

    Navigator.of(context).popUntil((route) => route.settings.name == path);
  }

  /// Remove all routes without animation
  void removeAll() {
    final context = _currentContext;
    if (context == null) return;

    if (_steps.isEmpty) return;

    final navigator = Navigator.of(context);

    // Create a copy of steps to avoid ConcurrentModificationError
    final stepsToRemove = List<NavStep>.from(_steps.reversed);

    // Remove routes without animation in reverse order using routes from steps
    for (final step in stepsToRemove) {
      if (step.currentRoute.isActive) {
        navigator.removeRoute(step.currentRoute);
      }
    }

    // Clear internal navigation history will be handled in _didRemove
  }

  /// Replace the current route with a new one without animation
  void replace(String path, {Map<String, dynamic>? extra}) {
    final context = _currentContext;
    if (context == null) return;

    final navExtra = NavExtra(extra ?? {});
    final route = _routes[path];

    if (route == null) {
      if (_enableLogger) {
        debugPrint('NavService.replace: Route not found for path: $path');
      }
      return;
    }

    final currentRoute = _steps.isNotEmpty ? _steps.last.currentRoute : null;
    if (currentRoute == null) {
      if (_enableLogger) {
        debugPrint('NavService.replace: No previous state found to replace.');
      }
      return;
    }

    Navigator.of(context).replace(
      newRoute: _buildPageRoute(path: path, extra: navExtra, route: route),
      oldRoute: currentRoute,
    );
  }

  /// Replace last route with new routes with push animation
  void pushReplacementAll(List<NavRouteInfo> routeInfos) {
    final context = _currentContext;
    if (context == null) return;

    final navigator = Navigator.of(context);

    // Remove last existing route
    if (_steps.isNotEmpty) {
      final lastStep = _steps.last;
      if (lastStep.currentRoute.isActive) {
        navigator.removeRoute(lastStep.currentRoute);
      }
    }

    pushAll(routeInfos);
  }

  /// Adds the corresponding pages to given [routeInfos] list to the _steps stack at once
  /// Similar to AutoRoute's pushAll method
  void pushAll(List<NavRouteInfo> routeInfos) {
    final context = _currentContext;
    if (context == null) return;

    if (routeInfos.isEmpty) return;

    final navigator = Navigator.of(context);

    // Push all routes sequentially
    for (int i = 0; i < routeInfos.length; i++) {
      final routeInfo = routeInfos[i];
      final route = _routes[routeInfo.path];

      if (route != null) {
        final navExtra = NavExtra(routeInfo.extra ?? {});

        if (i == routeInfos.length - 1) {
          // Last route with animation
          navigator.push(
            _buildPageRoute(
              path: routeInfo.path,
              extra: navExtra,
              route: route,
            ),
          );
        } else {
          // Other routes without push animation but with pop animation
          navigator.push(
            _NoTransitionMaterialPageRoute(
              settings: RouteSettings(
                name: routeInfo.path,
                arguments: navExtra,
              ),
              builder:
                  (context) => route.builder(
                    context,
                    NavState(path: routeInfo.path, extra: navExtra),
                  ),
            ),
          );
        }
      } else {
        if (_enableLogger) {
          debugPrint(
            'NavService.pushAll: Route not found for path: ${routeInfo.path}',
          );
        }
      }
    }
  }

  /// Replace all existing routes with new routes with push animation
  ///
  /// The behavior is similar to GoRouter's go method and AutoRoute's replaceAll method
  void replaceAll(List<NavRouteInfo> routeInfos) {
    final context = _currentContext;
    if (context == null) return;

    final navigator = Navigator.of(context);

    // Remove all existing routes
    for (final step in List<NavStep>.from(_steps.reversed)) {
      if (step.currentRoute.isActive) {
        navigator.removeRoute(step.currentRoute);
      }
    }

    // Push new routes in order
    for (final routeInfo in routeInfos) {
      final route = _routes[routeInfo.path];
      if (route != null) {
        final navExtra = NavExtra(routeInfo.extra ?? {});
        navigator.push(
          _buildPageRoute(path: routeInfo.path, extra: navExtra, route: route),
        );
      } else {
        if (_enableLogger) {
          debugPrint(
            'NavService.replaceAll: Route not found for path: ${routeInfo.path}',
          );
        }
      }
    }
  }

  // Get navigation history
  List<NavStep> get navigationHistory => List.unmodifiable(_steps);
}

class _RouteObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    NavService.instance._didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    NavService.instance._didPop(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    NavService.instance._didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    NavService.instance._didRemove(
      oldRoute: route,
      previousRoute: previousRoute,
    );
  }
}

// Follow MaterialPageRoute
const Duration _kDefaultTransitionDuration = Duration(milliseconds: 300);

/// Custom MaterialPageRoute that has no push animation but keeps pop animation
class _NoTransitionMaterialPageRoute<T> extends MaterialPageRoute<T> {
  _NoTransitionMaterialPageRoute({required super.builder, super.settings});

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Duration get reverseTransitionDuration => _kDefaultTransitionDuration;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // No animation when pushing (entering)
    if (animation.status == AnimationStatus.forward) {
      return child;
    }

    // Use default material transition when popping (exiting)
    return super.buildTransitions(
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }
}
