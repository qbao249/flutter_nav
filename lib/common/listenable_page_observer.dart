import 'package:flutter/widgets.dart';

class ListenablePageObserver extends RouteObserver<PageRoute> {
  final Set<RouteObserver<PageRoute>> _observers = {};

  /// Adds a [RouteObserver] to listen to navigation events.
  ///
  /// Returns a function to remove the observer when no longer needed.
  void Function() addListener(RouteObserver<PageRoute> observer) {
    _observers.add(observer);
    return () {
      _observers.remove(observer);
    };
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    for (var observer in _observers) {
      observer.didPush(route, previousRoute);
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    for (var observer in _observers) {
      observer.didPop(route, previousRoute);
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    for (var observer in _observers) {
      observer.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    for (var observer in _observers) {
      observer.didRemove(route, previousRoute);
    }
  }
}
