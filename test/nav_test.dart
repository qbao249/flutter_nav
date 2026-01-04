import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_nav/flutter_nav.dart';

void main() {
  group('PageService', () {
    late GlobalKey<NavigatorState> navigatorKey;

    setUp(() {
      navigatorKey = GlobalKey<NavigatorState>();
    });

    test('should be a singleton', () {
      final instance1 = Nav.page;
      final instance2 = Nav.page;
      expect(instance1, same(instance2));
    });

    test('should initialize with configuration', () {
      final routes = [
        NavRoute(path: '/home', builder: (context, state) => Container()),
        NavRoute(path: '/settings', builder: (context, state) => Container()),
      ];

      final config = NavConfig(
        routes: routes,
        navigatorKey: navigatorKey,
        enableLogger: false,
      );

      Nav.init(config);

      // Test navigation history
      expect(Nav.page.navigationHistory, isEmpty);
    });

    testWidgets('should navigate between routes', (WidgetTester tester) async {
      final routes = [
        NavRoute(
          path: '/home',
          builder:
              (context, state) => Scaffold(
                appBar: AppBar(title: const Text('Home Page')),
                body: Column(
                  children: [
                    const Text('Home Content'),
                    ElevatedButton(
                      onPressed: () => Nav.page.push('/settings'),
                      child: const Text('Go to Settings'),
                    ),
                  ],
                ),
              ),
        ),
        NavRoute(
          path: '/settings',
          builder: (context, state) => const Scaffold(body: Text('Settings')),
        ),
      ];

      Nav.init(
        NavConfig(
          routes: routes,
          navigatorKey: navigatorKey,
          enableLogger: false,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          navigatorObservers: Nav.observers,
          home: Builder(
            builder:
                (context) => Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => Nav.page.push('/home'),
                        child: const Text('Go Home'),
                      ),
                      ElevatedButton(
                        onPressed: () => Nav.page.push('/settings'),
                        child: const Text('Go Settings'),
                      ),
                    ],
                  ),
                ),
          ),
        ),
      );

      // Test navigation to home
      await tester.tap(find.text('Go Home'));
      await tester.pumpAndSettle();
      expect(find.text('Home Content'), findsOneWidget);

      // Navigate to settings from home page
      await tester.tap(find.text('Go to Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);

      // Verify navigation history
      expect(Nav.page.navigationHistory.length, equals(2));
      expect(
        Nav.page.navigationHistory.last.currentState.path,
        equals('/settings'),
      );
    });

    testWidgets('should handle extra data', (WidgetTester tester) async {
      String? receivedData;

      final routes = [
        NavRoute(
          path: '/test',
          builder: (context, state) {
            receivedData = state.extra?.data['message'];
            return Scaffold(body: Text('Test: $receivedData'));
          },
        ),
      ];

      Nav.init(
        NavConfig(
          routes: routes,
          navigatorKey: navigatorKey,
          enableLogger: false,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          navigatorObservers: Nav.observers,
          home: Builder(
            builder:
                (context) => Scaffold(
                  body: ElevatedButton(
                    onPressed:
                        () => Nav.page.push(
                          '/test',
                          extra: {'message': 'Hello World'},
                        ),
                    child: const Text('Navigate'),
                  ),
                ),
          ),
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(receivedData, equals('Hello World'));
      expect(find.text('Test: Hello World'), findsOneWidget);
    });

    testWidgets('should handle pop operations', (WidgetTester tester) async {
      final routes = [
        NavRoute(
          path: '/first',
          builder:
              (context, state) => Scaffold(
                appBar: AppBar(title: const Text('First Page')),
                body: Column(
                  children: [
                    const Text('First Content'),
                    ElevatedButton(
                      onPressed: () => Nav.page.push('/second'),
                      child: const Text('Push Second'),
                    ),
                  ],
                ),
              ),
        ),
        NavRoute(
          path: '/second',
          builder:
              (context, state) => Scaffold(
                appBar: AppBar(title: const Text('Second Page')),
                body: Column(
                  children: [
                    const Text('Second Content'),
                    ElevatedButton(
                      onPressed: () => Nav.page.pop(),
                      child: const Text('Pop'),
                    ),
                  ],
                ),
              ),
        ),
      ];

      Nav.init(
        NavConfig(
          routes: routes,
          navigatorKey: navigatorKey,
          enableLogger: false,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          navigatorObservers: Nav.observers,
          home: Builder(
            builder:
                (context) => Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => Nav.page.push('/first'),
                        child: const Text('Push First'),
                      ),
                    ],
                  ),
                ),
          ),
        ),
      );

      // Push first route
      await tester.tap(find.text('Push First'));
      await tester.pumpAndSettle();
      expect(Nav.page.navigationHistory.length, equals(1));
      expect(find.text('First Content'), findsOneWidget);

      // Push second route from first route
      await tester.tap(find.text('Push Second'));
      await tester.pumpAndSettle();
      expect(Nav.page.navigationHistory.length, equals(2));
      expect(find.text('Second Content'), findsOneWidget);

      // Pop from second route
      expect(Nav.page.canPop(), isTrue);
      await tester.tap(find.text('Pop'));
      await tester.pumpAndSettle();

      expect(find.text('First Content'), findsOneWidget);
      expect(Nav.page.navigationHistory.length, equals(1));
    });

    testWidgets('should handle replace operations', (
      WidgetTester tester,
    ) async {
      final routes = [
        NavRoute(
          path: '/original',
          builder:
              (context, state) => Scaffold(
                appBar: AppBar(title: const Text('Original Page')),
                body: Column(
                  children: [
                    const Text('Original Content'),
                    ElevatedButton(
                      onPressed: () => Nav.page.pushReplacement('/replacement'),
                      child: const Text('Replace'),
                    ),
                  ],
                ),
              ),
        ),
        NavRoute(
          path: '/replacement',
          builder:
              (context, state) => const Scaffold(body: Text('Replacement')),
        ),
      ];

      Nav.init(
        NavConfig(
          routes: routes,
          navigatorKey: navigatorKey,
          enableLogger: false,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          navigatorObservers: Nav.observers,
          home: Builder(
            builder:
                (context) => Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => Nav.page.push('/original'),
                        child: const Text('Push Original'),
                      ),
                    ],
                  ),
                ),
          ),
        ),
      );

      // Push original route
      await tester.tap(find.text('Push Original'));
      await tester.pumpAndSettle();
      expect(find.text('Original Content'), findsOneWidget);

      // Replace with new route
      await tester.tap(find.text('Replace'));
      await tester.pumpAndSettle();
      expect(find.text('Replacement'), findsOneWidget);
      expect(find.text('Original Content'), findsNothing);
    });
  });

  group('NavAware', () {
    testWidgets('calls lifecycle callbacks', (WidgetTester tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();

      var initCalled = false;
      var afterCalled = false;
      var disposeCalled = false;

      final routes = [
        NavRoute(
          path: '/other',
          builder: (context, state) => const Scaffold(body: Text('Other')),
        ),
      ];

      Nav.init(
        NavConfig(
          routes: routes,
          navigatorKey: navigatorKey,
          enableLogger: false,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          navigatorObservers: Nav.observers,
          home: PageAware(
            onInit: () => initCalled = true,
            onAfterFirstFrame: () => afterCalled = true,
            onDispose: () => disposeCalled = true,
            child: const Scaffold(body: Text('Home')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(initCalled, isTrue);
      expect(afterCalled, isTrue);
      expect(disposeCalled, isFalse);

      // Replace the current route to trigger dispose on the Home route.
      Nav.page.replace('/other');
      await tester.pumpAndSettle();

      expect(disposeCalled, isTrue);
    });
  });

  group('NavExtra', () {
    test('should store and retrieve data', () {
      final extra = NavExtra({'key1': 'value1', 'key2': 42});

      expect(extra.data['key1'], equals('value1'));
      expect(extra.data['key2'], equals(42));
      expect(extra.data, equals({'key1': 'value1', 'key2': 42}));
    });
  });

  group('NavState', () {
    test('should create NavState from route with NavExtra', () {
      final extra = NavExtra({'test': 'data'});
      final route = MaterialPageRoute(
        settings: RouteSettings(name: '/test', arguments: extra),
        builder: (context) => Container(),
      );

      final state = NavState.fromRoute(route);

      expect(state, isNotNull);
      expect(state!.path, equals('/test'));
      expect(state.extra, equals(extra));
    });

    test('should return null for route without NavExtra', () {
      final route = MaterialPageRoute(
        settings: const RouteSettings(
          name: '/test',
          arguments: 'regular string',
        ),
        builder: (context) => Container(),
      );

      final state = NavState.fromRoute(route);
      expect(state, isNull);
    });
  });

  group('NavRouteInfo', () {
    test('should create route info with path and extra data', () {
      final routeInfo = NavRouteInfo(path: '/test', extra: {'data': 'value'});

      expect(routeInfo.path, equals('/test'));
      expect(routeInfo.extra, equals({'data': 'value'}));
    });

    test('should create route info with path only', () {
      final routeInfo = NavRouteInfo(path: '/test');

      expect(routeInfo.path, equals('/test'));
      expect(routeInfo.extra, isNull);
    });
  });

  group('Deep Linking', () {
    late TestNavLinkHandler testHandler;
    late GlobalKey<NavigatorState> navigatorKey;

    setUp(() {
      testHandler = TestNavLinkHandler();
      navigatorKey = GlobalKey<NavigatorState>();
    });

    test('should initialize with link prefixes and handlers', () {
      final routes = [
        NavRoute(path: '/home', builder: (context, state) => Container()),
      ];

      final config = NavConfig(
        routes: routes,
        navigatorKey: navigatorKey,
        enableLogger: false,
        linkPrefixes: ['myapp://', 'https://myapp.com/'],
        linkHandlers: [testHandler],
      );

      expect(() => Nav.init(config), returnsNormally);
    });

    testWidgets('should handle URL with scheme prefix', (
      WidgetTester tester,
    ) async {
      final routes = [
        NavRoute(path: '/home', builder: (context, state) => Container()),
      ];

      Nav.init(
        NavConfig(
          routes: routes,
          navigatorKey: navigatorKey,
          enableLogger: false,
          linkPrefixes: ['myapp://'],
          linkHandlers: [testHandler],
        ),
      );

      // Create widget tree so navigator context is available
      await tester.pumpWidget(
        MaterialApp(navigatorKey: navigatorKey, home: Container()),
      );

      Nav.link.openUrl('myapp://product/123?category=electronics');

      expect(testHandler.lastResult?.matchedRoutePath, equals('/product/:id'));
      expect(testHandler.lastResult?.pathParameters, equals({'id': '123'}));
      expect(
        testHandler.lastResult?.queryParameters,
        equals({'category': 'electronics'}),
      );
    });

    testWidgets('should handle URL with domain prefix', (
      WidgetTester tester,
    ) async {
      final routes = [
        NavRoute(path: '/home', builder: (context, state) => Container()),
      ];

      Nav.init(
        NavConfig(
          routes: routes,
          navigatorKey: navigatorKey,
          enableLogger: false,
          linkPrefixes: ['https://myapp.com'],
          linkHandlers: [testHandler],
        ),
      );

      // Create widget tree so navigator context is available
      await tester.pumpWidget(
        MaterialApp(navigatorKey: navigatorKey, home: Container()),
      );

      Nav.link.openUrl('https://myapp.com/user/profile?tab=settings');

      expect(testHandler.lastResult?.matchedRoutePath, equals('/user/profile'));
      expect(testHandler.lastResult?.pathParameters, isEmpty);
      expect(
        testHandler.lastResult?.queryParameters,
        equals({'tab': 'settings'}),
      );
    });

    testWidgets('should extract path parameters correctly', (
      WidgetTester tester,
    ) async {
      final routes = [
        NavRoute(path: '/home', builder: (context, state) => Container()),
      ];

      Nav.init(
        NavConfig(
          routes: routes,
          navigatorKey: navigatorKey,
          enableLogger: false,
          linkPrefixes: ['myapp://'],
          linkHandlers: [testHandler],
        ),
      );

      // Create widget tree so navigator context is available
      await tester.pumpWidget(
        MaterialApp(navigatorKey: navigatorKey, home: Container()),
      );

      Nav.link.openUrl('myapp://product/abc123/review/456');

      expect(
        testHandler.lastResult?.matchedRoutePath,
        equals('/product/:productId/review/:reviewId'),
      );
      expect(
        testHandler.lastResult?.pathParameters,
        equals({'productId': 'abc123', 'reviewId': '456'}),
      );
    });

    test('should throw error for duplicate redirect paths', () {
      final routes = [
        NavRoute(path: '/home', builder: (context, state) => Container()),
      ];

      final duplicateHandler = TestNavLinkHandler();

      expect(
        () => Nav.init(
          NavConfig(
            routes: routes,
            navigatorKey: navigatorKey,
            enableLogger: false,
            linkPrefixes: ['myapp://'],
            linkHandlers: [testHandler, duplicateHandler],
          ),
        ),
        throwsException,
      );
    });

    testWidgets('should not handle URL without matching prefix', (
      WidgetTester tester,
    ) async {
      final routes = [
        NavRoute(path: '/home', builder: (context, state) => Container()),
      ];

      Nav.init(
        NavConfig(
          routes: routes,
          navigatorKey: navigatorKey,
          enableLogger: false,
          linkPrefixes: ['myapp://'],
          linkHandlers: [testHandler],
        ),
      );

      // Create widget tree so navigator context is available
      await tester.pumpWidget(
        MaterialApp(navigatorKey: navigatorKey, home: Container()),
      );

      testHandler.clearResults();
      Nav.link.openUrl('https://other.com/product/123');

      expect(testHandler.lastResult, isNull);
    });

    test('NavLinkResult should contain correct data', () {
      final result = NavLinkResult(
        matchedRoutePath: '/product/:id',
        pathParameters: {'id': '123'},
        queryParameters: {'tab': 'details'},
      );

      expect(result.matchedRoutePath, equals('/product/:id'));
      expect(result.pathParameters, equals({'id': '123'}));
      expect(result.queryParameters, equals({'tab': 'details'}));
    });
  });
}

// Test helper class
class TestNavLinkHandler extends NavLinkHandler {
  NavLinkResult? lastResult;

  @override
  List<String> get redirectPaths => [
    '/product/:id',
    '/user/profile',
    '/product/:productId/review/:reviewId',
  ];

  @override
  void onRedirect(BuildContext context, NavLinkResult result) {
    lastResult = result;
  }

  void clearResults() {
    lastResult = null;
  }
}
