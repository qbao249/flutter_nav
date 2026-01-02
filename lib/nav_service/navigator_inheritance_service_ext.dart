part of 'nav_service.dart';

extension NavigatorInheritanceServiceExt on NavService {
  /// Push a new route onto the navigator stack with animation
  ///
  /// Returns a Future that completes to the result value passed to
  ///
  /// See Navigator.push for more details
  Future<T?> push<T>(String path, {Map<String, dynamic>? extra}) async {
    try {
      final context = _currentContext;
      if (context == null) {
        if (_enableLogger) {
          debugPrint('NavService.push: No valid context found.');
        }
        return null;
      }

      final navExtra = NavExtra(extra ?? {});
      final route = _routes[path];

      if (route == null) {
        if (_enableLogger) {
          debugPrint('NavService.push: Route not found for path: $path');
        }
        return null;
      }

      final result = await Navigator.of(
        context,
      ).push<T>(_buildPageRoute<T>(path: path, extra: navExtra, route: route));

      return result;
      // ignore: avoid_catches_without_on_clauses
    } catch (e, st) {
      if (_enableLogger) {
        debugPrint('NavService.push.exception: $e\n$st');
      }
      return null;
    }
  }

  /// Pop the current route with animation
  ///
  /// [result] is the optional result to return to the previous route
  ///
  /// See Navigator.pop for more details
  void pop<T extends Object?>([T? result]) {
    try {
      final context = _currentContext;
      if (context == null) {
        if (_enableLogger) {
          debugPrint('NavService.pop: No valid context found.');
        }
        return;
      }
      if (_steps.isNotEmpty) {
        Navigator.of(context).pop<T>(result);
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (e, st) {
      if (_enableLogger) {
        debugPrint('NavService.pop.exception: $e\n$st');
      }
    }
  }

  /// Pops routes until the given [predicate] returns true
  ///
  /// See Navigator.popUntil for more details
  void popUntil(RoutePredicate predicate) {
    try {
      final context = _currentContext;
      if (context == null) {
        if (_enableLogger) {
          debugPrint('NavService.popUntil: No valid context found.');
        }
        return;
      }

      Navigator.of(context).popUntil(predicate);
      // ignore: avoid_catches_without_on_clauses
    } catch (e, st) {
      if (_enableLogger) {
        debugPrint('NavService.popUntil.exception: $e\n$st');
      }
    }
  }

  /// Check if there is at least one active route to pop
  ///
  /// See Navigator.canPop
  bool canPop() {
    final context = _currentContext;
    if (context == null) {
      if (_enableLogger) {
        debugPrint('NavService.canPop: No valid context found.');
      }
      return false;
    }
    return Navigator.of(context).canPop();
  }

  /// Pop the top-most route if possible
  ///
  /// See Navigator.maybePop
  Future<bool> maybePop<T>([T? result]) async {
    try {
      final context = _currentContext;
      if (context == null) {
        if (_enableLogger) {
          debugPrint('NavService.maybePop: No valid context found.');
        }
        return false;
      }
      return await Navigator.of(context).maybePop<T>(result);
      // ignore: avoid_catches_without_on_clauses
    } catch (e, st) {
      if (_enableLogger) {
        debugPrint('NavService.maybePop.exception: $e\n$st');
      }
      return false;
    }
  }

  /// Replace the current route with a new one with push animation
  ///
  /// See Navigator.pushReplacement for more details
  void pushReplacement(String path, {Map<String, dynamic>? extra}) {
    try {
      final context = _currentContext;
      if (context == null) {
        if (_enableLogger) {
          debugPrint('NavService.pushReplacement: No valid context found.');
        }
        return;
      }

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
        _buildPageRoute<dynamic>(path: path, extra: navExtra, route: route),
      );
      // ignore: avoid_catches_without_on_clauses
    } catch (e, st) {
      if (_enableLogger) {
        debugPrint('NavService.pushReplacement.exception: $e\n$st');
      }
    }
  }

  /// Push a new route and remove routes until the given [predicate] returns
  /// true
  ///
  /// See Navigator.pushAndRemoveUntil for more details
  void pushAndRemoveUntil(
    String path,
    RoutePredicate predicate, {
    Map<String, dynamic>? extra,
  }) {
    try {
      final context = _currentContext;
      if (context == null) {
        if (_enableLogger) {
          debugPrint('NavService.pushAndRemoveUntil: No valid context found.');
        }
        return;
      }

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
        _buildPageRoute<dynamic>(path: path, extra: navExtra, route: route),
        predicate,
      );
      // ignore: avoid_catches_without_on_clauses
    } catch (e, st) {
      if (_enableLogger) {
        debugPrint('NavService.pushAndRemoveUntil.exception: $e\n$st');
      }
    }
  }

  /// Replace the current route with a new one without animation
  void replace(String path, {Map<String, dynamic>? extra}) {
    try {
      final context = _currentContext;
      if (context == null) {
        if (_enableLogger) {
          debugPrint('NavService.replace: No valid context found.');
        }
        return;
      }

      final navExtra = NavExtra(extra ?? {});
      final route = _routes[path];

      if (route == null) {
        if (_enableLogger) {
          debugPrint('NavService.replace: Route not found for path: $path');
        }
        return;
      }

      final navigator = Navigator.of(context);

      if (_steps.isEmpty) {
        // handle replace when there is no existing _steps
        // and contains initial route

        navigator.pushAndRemoveUntil(
          _buildPageRouteNoPushAnimation(
            path: path,
            extra: navExtra,
            route: route,
          ),
          (route) => false,
        );
      } else {
        // handle replace when there is existing _steps

        final currentRoute =
            _steps.isNotEmpty ? _steps.last.currentRoute : null;
        if (currentRoute == null) {
          if (_enableLogger) {
            debugPrint(
              'NavService.replace: No previous state found to replace.',
            );
          }
          return;
        }

        navigator.replace(
          newRoute: _buildPageRoute<dynamic>(
            path: path,
            extra: navExtra,
            route: route,
          ),
          oldRoute: currentRoute,
        );
      }

      // ignore: avoid_catches_without_on_clauses
    } catch (e, st) {
      if (_enableLogger) {
        debugPrint('NavService.replace.exception: $e\n$st');
      }
    }
  }
}
