part of 'nav_service.dart';

extension NavigatorInheritanceServiceExt on NavService {
  /// Push a new route onto the navigator stack with animation
  ///
  /// Returns a Future that completes to the result value passed to
  ///
  /// See Navigator.push for more details
  Future<T?> push<T>(String path, {Map<String, dynamic>? extra}) async {
    final context = _currentContext;
    if (context == null) return null;

    final navExtra = NavExtra(extra ?? {});
    final route = _routes[path];

    if (route == null) {
      if (_enableLogger) {
        debugPrint('NavService.push: Route not found for path: $path');
      }
      return null;
    }

    final result = await Navigator.of(context).push<T>(
      _buildPageRoute(path: path, extra: navExtra, route: route) as Route<T>,
    );

    return result;
  }

  /// Pop the current route with animation
  ///
  /// [result] is the optional result to return to the previous route
  ///
  /// See Navigator.pop for more details
  void pop<T>([T? result]) {
    final context = _currentContext;
    if (context == null) return;
    if (_steps.isNotEmpty) {
      Navigator.of(context).pop<T>(result);
    }
  }

  /// Pops routes until the given [predicate] returns true
  ///
  /// See Navigator.popUntil for more details
  void popUntil(RoutePredicate predicate) {
    final context = _currentContext;
    if (context == null) return;

    Navigator.of(context).popUntil(predicate);
  }

  /// Check if there is at least one active route to pop
  ///
  /// See Navigator.canPop
  bool canPop() {
    final context = _currentContext;
    if (context == null) return false;
    return Navigator.of(context).canPop();
  }

  /// Pop the top-most route if possible
  ///
  /// See Navigator.maybePop
  Future<bool> maybePop<T>([T? result]) async {
    final context = _currentContext;
    if (context == null) throw Exception('No valid context for NavService');
    return Navigator.of(context).maybePop<T>(result);
  }

  /// Replace the current route with a new one with push animation
  ///
  /// See Navigator.pushReplacement for more details
  void pushReplacement(String path, {Map<String, dynamic>? extra}) {
    final context = _currentContext;
    if (context == null) return;

    final navExtra = NavExtra(extra ?? {});
    final route = _routes[path];

    if (route == null) {
      if (_enableLogger) {
        debugPrint(
          'NavService.pushReplacement: Route not found for path: $path',
        );
      }
      return;
    }

    Navigator.of(context).pushReplacement(
      _buildPageRoute(path: path, extra: navExtra, route: route),
    );
  }

  /// Push a new route and remove routes until the given [predicate] returns true
  ///
  /// See Navigator.pushAndRemoveUntil for more details
  void pushAndRemoveUntil(
    String path,
    RoutePredicate predicate, {
    Map<String, dynamic>? extra,
  }) {
    final context = _currentContext;
    if (context == null) return;

    final navExtra = NavExtra(extra ?? {});
    final route = _routes[path];

    if (route == null) {
      if (_enableLogger) {
        debugPrint(
          'NavService.pushAndRemoveUntil: Route not found for path: $path',
        );
      }
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      _buildPageRoute(path: path, extra: navExtra, route: route),
      predicate,
    );
  }
}
