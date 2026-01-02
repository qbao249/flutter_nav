# Advanced Nav Service

A powerful and comprehensive navigation service package for Flutter applications that provides advanced routing, navigation state management, and declarative navigation utilities.

## Features

- **🎯 Singleton Navigation Service**: Access navigation functionality from anywhere in your app
- **📊 Navigation History Tracking**: Keep track of navigation stack and history
- **💾 Extra Data Support**: Pass and receive data between routes with type safety
- **🔄 Advanced Route Management**: Smart navigation, replace operations, and stack manipulation
- **📝 Route Observers**: Monitor navigation events with built-in observer
- **🚀 Declarative API**: Intuitive methods for all navigation scenarios
- **🔍 Navigation Debugging**: Built-in logging and navigation history inspection
- **⚡ Performance Optimized**: Efficient route management with minimal overhead
- **🔗 Deep Linking System**: Complete infrastructure for handling custom URLs and app links
- **🎯 Smart URL Routing**: Automatic path parameter extraction and query parameter support
- **🛠 Flexible Link Handlers**: Create custom handlers for different URL patterns
- **🌐 Universal Link Support**: Both custom schemes and domain-based deep links

## Getting Started

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  advanced_nav_service: ^0.3.0
```

Then run:

```bash
flutter pub get
```

## Quick Setup

### 1. Define Your Routes

```dart
import 'package:advanced_nav_service/nav_service.dart';

final routes = [
  NavRoute(
    path: '/home',
    builder: (context, state) => HomeScreen(state: state),
  ),
  NavRoute(
    path: '/profile',
    builder: (context, state) => ProfileScreen(state: state),
  ),
  NavRoute(
    path: '/settings',
    builder: (context, state) => SettingsScreen(state: state),
  ),
];
```

### 2. Initialize NavService

```dart
void main() {
  final navigatorKey = GlobalKey<NavigatorState>();
  
  NavService.instance.init(
    NavServiceConfig(
      routes: routes,
      navigatorKey: navigatorKey,
      enableLogger: true, // Enable navigation logging
    ),
  );
  
  runApp(MyApp(navigatorKey: navigatorKey));
}
```

### 3. Setup Your App

```dart
class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  
  const MyApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      navigatorObservers: [NavService.instance.routeObserver],
      home: const LaunchScreen(),
    );
  }
}
```

## Core Navigation Methods

### Basic Navigation

```dart
// Push a new route
NavService.instance.push('/profile');

// Push with extra data
NavService.instance.push('/profile', extra: {
  'userId': 123,
  'name': 'John Doe',
});

// Pop current route
NavService.instance.pop();

// Pop with result data
NavService.instance.pop({'result': 'success'});

// Check if can pop
if (NavService.instance.canPop()) {
  NavService.instance.pop();
}
```

### Smart Navigation

```dart
// Navigate intelligently - if route exists in stack, pop to it; otherwise push
NavService.instance.navigate('/home');

// Force push even if route exists in history
NavService.instance.navigate('/home', forcePush: true);
```

### Replace Operations

```dart
// Replace current route with push animation
NavService.instance.pushReplacement('/settings');

// Replace current route without animation
NavService.instance.replace('/settings');
```

### Stack Management

```dart
// Push and remove all previous routes
NavService.instance.pushAndRemoveUntil('/home', (route) => false);

// Pop until specific condition
NavService.instance.popUntil((route) => route.settings.name == '/home');

// Pop until specific path
NavService.instance.popUntilPath('/home');

// Pop all routes
NavService.instance.popAll();

// Remove all routes without animation
NavService.instance.removeAll();
```

### Bulk Operations

```dart
// Push multiple routes at once
NavService.instance.pushAll([
  NavRouteInfo(path: '/home'),
  NavRouteInfo(path: '/profile', extra: {'userId': 123}),
  NavRouteInfo(path: '/settings'),
]);

// Replace all routes with new stack
NavService.instance.replaceAll([
  NavRouteInfo(path: '/home'),
  NavRouteInfo(path: '/dashboard'),
]);

// Replace last route with multiple routes
NavService.instance.pushReplacementAll([
  NavRouteInfo(path: '/profile'),
  NavRouteInfo(path: '/edit'),
]);
```

## Deep Linking

Advanced Nav Service provides a comprehensive deep linking system that allows you to handle custom URLs and app links seamlessly.

### 1. Setup Deep Linking

#### Define Link Handlers

Create custom link handlers by extending `NavLinkHandler`:

```dart
import 'package:advanced_nav_service/nav_service.dart';

class ProfileLinkHandler extends NavLinkHandler {
  @override
  List<String> get redirectPaths => [
    '/profile',
    '/profile/:id',
    '/user/:userId',
  ];

  @override
  void onRedirect(NavLinkResult result) {
    // Handle the deep link navigation
    NavService.instance.navigate('/profile', extra: {
      ...result.pathParameters,  // e.g., {'id': '123'}
      ...result.queryParameters, // e.g., {'tab': 'settings'}
    });
  }
}

class SettingsLinkHandler extends NavLinkHandler {
  @override
  List<String> get redirectPaths => [
    '/settings',
    '/settings/:tab',
    '/preferences/:section',
  ];

  @override
  void onRedirect(NavLinkResult result) {
    final extra = <String, dynamic>{
      ...result.pathParameters,
      ...result.queryParameters,
    };
    
    NavService.instance.navigate('/settings', extra: extra);
  }
}
```

#### Configure Deep Linking

Add link prefixes and handlers to your `NavServiceConfig`:

```dart
void main() {
  final navigatorKey = GlobalKey<NavigatorState>();
  
  NavService.instance.init(
    NavServiceConfig(
      navigatorKey: navigatorKey,
      routes: routes,
      enableLogger: true,
      // Deep linking configuration
      linkPrefixes: [
        'myapp://',                    // Custom scheme
        'https://myapp.com/',          // Universal links
        'https://www.myapp.com/',      // Alternative domain
      ],
      linkHandlers: [
        ProfileLinkHandler(),
        SettingsLinkHandler(),
      ],
    ),
  );
  
  runApp(MyApp(navigatorKey: navigatorKey));
}
```

### 2. Handle Deep Links

#### Opening URLs Programmatically

```dart
// Handle custom scheme URLs
NavService.instance.openUrl('myapp://profile/123?tab=settings');

// Handle universal links
NavService.instance.openUrl('https://myapp.com/profile/456?source=share');

// Handle settings deep links
NavService.instance.openUrl('myapp://settings/notifications?enabled=true');
```

#### Path Parameter Extraction

The system automatically extracts path parameters using `:paramName` syntax:

```dart
class ProductLinkHandler extends NavLinkHandler {
  @override
  List<String> get redirectPaths => [
    '/product/:productId',
    '/category/:categoryId/product/:productId',
    '/shop/:storeId/product/:productId/review/:reviewId',
  ];

  @override
  void onRedirect(NavLinkResult result) {
    // URL: myapp://product/abc123?color=red&size=large
    // result.pathParameters = {'productId': 'abc123'}
    // result.queryParameters = {'color': 'red', 'size': 'large'}
    
    final productId = result.pathParameters['productId'];
    final color = result.queryParameters['color'];
    
    NavService.instance.navigate('/product', extra: {
      'productId': productId,
      'color': color,
      'size': result.queryParameters['size'],
    });
  }
}
```

### 3. Deep Link Features

#### URL Pattern Matching

- **Static paths**: `/profile`, `/settings`
- **Dynamic parameters**: `/user/:userId`, `/product/:id`
- **Nested parameters**: `/category/:catId/product/:prodId`
- **Query parameters**: Automatically parsed and available

#### Link Prefixes

Support for multiple URL schemes:

- **Custom schemes**: `myapp://`, `yourapp://`
- **Universal links**: `https://domain.com/`, `https://www.domain.com/`
- **Mixed prefixes**: Combine schemes and domains as needed

#### Error Handling

- **Duplicate path detection**: Prevents conflicts between handlers
- **Invalid URL handling**: Graceful handling of malformed URLs
- **Missing handler**: Logs when no handler matches a URL

#### NavLinkResult

Contains complete information about the matched deep link:

```dart
class NavLinkResult {
  final String matchedRoutePath;        // '/user/:userId'
  final Map<String, String> pathParameters;    // {'userId': '123'}  
  final Map<String, String> queryParameters;   // {'tab': 'profile'}
}
```

## Integration Guides

### GoRouter Integration

Advanced Nav Service can work alongside GoRouter for hybrid navigation scenarios.

#### Setup

1. **Install dependencies**:

```yaml
dependencies:
  advanced_nav_service: ^0.3.0
  go_router: ^latest_version
```

2. **Configure both systems**:

```dart
import 'package:go_router/go_router.dart';
import 'package:advanced_nav_service/nav_service.dart';

final navigatorKey = GlobalKey<NavigatorState>();

// Configure GoRouter
final GoRouter goRouter = GoRouter(
  navigatorKey: navigatorKey,
  observers: [
    NavService.instance.routeObserver,
  ],
  routes: [
    GoRoute(
      path: '/go-home',
      builder: (context, state) => const GoHomeScreen(),
    ),
    GoRoute(
      path: '/go-profile/:userId',
      builder: (context, state) => GoProfileScreen(
        userId: state.pathParameters['userId']!,
      ),
    ),
  ],
);

void main() {
  // Configure NavService with the same navigator key
  NavService.instance.init(
    NavServiceConfig(
      navigatorKey: navigatorKey,
      routes: [
        NavRoute(
          path: '/nav-home',
          builder: (context, state) => const NavHomeScreen(),
        ),
        NavRoute(
          path: '/nav-settings',
          builder: (context, state) => NavSettingsScreen(state: state),
        ),
      ],
      enableLogger: true,
    ),
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: goRouter,
    );
  }
}
```

#### Usage with .removeAll()

When switching from NavService navigation to GoRouter's context.go(), call `removeAll()` first to clear NavService's internal navigation stack:

```dart
class HybridNavigationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hybrid Navigation')),
      body: Column(
        children: [
          // Use NavService for internal app navigation
          ElevatedButton(
            onPressed: () {
              NavService.instance.push('/nav-settings', extra: {
                'theme': 'dark',
              });
            },
            child: Text('NavService Navigation'),
          ),
          
          // Clear NavService stack before using GoRouter
          ElevatedButton(
            onPressed: () {
              // IMPORTANT: Clear NavService stack first
              NavService.instance.removeAll();
              
              // Then use GoRouter navigation
              context.go('/go-profile/123');
            },
            child: Text('Switch to GoRouter'),
          ),
          
          // Direct GoRouter navigation (no cleanup needed)
          ElevatedButton(
            onPressed: () => context.go('/go-home'),
            child: Text('Direct GoRouter Navigation'),
          ),
        ],
      ),
    );
  }
}
```

#### Best Practices

- **Call `removeAll()` before `context.go()`**: This ensures NavService doesn't interfere with GoRouter's routing
- **Use consistent navigator key**: Both systems should share the same `GlobalKey<NavigatorState>`
- **Include NavService route observer**: Add `NavService.instance.routeObserver` to GoRouter's observers for complete navigation tracking
- **Separate concerns by use case**:
  - **Use GoRouter for**: Static routes, initial redirects, resetting all routes completely, resetting history
  - **Use NavService for**: Dynamic routes like push notifications, duplicate stacks, unpredictable navigation flows
- **Monitor navigation state**: Enable logging to debug navigation conflicts

#### Integration Pattern

```dart
class NavigationHelper {
  static void switchToGoRouter(BuildContext context, String goRoute) {
    // Clear NavService navigation history
    NavService.instance.removeAll();
    
    // Switch to GoRouter navigation
    context.go(goRoute);
  }
  
  static void switchToNavService(String navRoute, {Map<String, dynamic>? extra}) {
    // NavService handles its own stack - no cleanup needed
    NavService.instance.navigate(navRoute, extra: extra);
  }
}

// Usage
NavigationHelper.switchToGoRouter(context, '/go-profile/456');
NavigationHelper.switchToNavService('/nav-settings', extra: {'theme': 'light'});
```

### app_links Integration

Integrate with the `app_links` package to handle incoming deep links from the system.

#### Setup

1. **Install dependencies**:

```yaml
dependencies:
  advanced_nav_service: ^0.3.0
  app_links: ^latest_version
```

2. **Configure app_links** (follow their platform-specific setup for iOS/Android)

3. **Setup deep link handling**:

```dart
import 'package:app_links/app_links.dart';
import 'package:advanced_nav_service/nav_service.dart';

class DeepLinkService {
  static final AppLinks _appLinks = AppLinks();
  
  static Future<void> initializeDeepLinks() async {
    // Handle the initial link when app is launched
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _handleDeepLink(initialLink);
    }
    
    // Handle incoming links when app is already running
    _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        debugPrint('Deep link error: $err');
      },
    );
  }
  
  static void _handleDeepLink(Uri uri) {
    // Convert URI to string and pass to NavService
    final url = uri.toString();
    debugPrint('Handling deep link: $url');
    
    // Use NavService's openUrl method
    NavService.instance.openUrl(url);
  }
}
```

#### Usage

1. **Initialize in main.dart**:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure NavService with deep linking
  NavService.instance.init(
    NavServiceConfig(
      navigatorKey: navigatorKey,
      routes: routes,
      enableLogger: true,
      linkPrefixes: [
        'myapp://',
        'https://myapp.com/',
      ],
      linkHandlers: [
        ProfileLinkHandler(),
        SettingsLinkHandler(),
        ProductLinkHandler(),
      ],
    ),
  );
  
  // Initialize deep link handling
  await DeepLinkService.initializeDeepLinks();
  
  runApp(MyApp());
}
```

2. **Handle app lifecycle states**:

```dart
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle deep links when app resumes
    if (state == AppLifecycleState.resumed) {
      // Re-check for any pending deep links
      DeepLinkService.checkPendingLinks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      navigatorObservers: [NavService.instance.routeObserver],
      home: LaunchScreen(),
    );
  }
}
```

#### Advanced Setup

```dart
class AdvancedDeepLinkService {
  static final AppLinks _appLinks = AppLinks();
  
  static Future<void> initializeWithDelay() async {
    // Wait for NavService initialization
    await Future.delayed(Duration(milliseconds: 500));
    
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      // Handle with delay to ensure app is fully loaded
      Future.delayed(Duration(seconds: 1), () {
        NavService.instance.openUrl(initialLink.toString());
      });
    }
    
    _appLinks.uriLinkStream.listen((Uri uri) {
      // Immediate handling for runtime links
      NavService.instance.openUrl(uri.toString());
    });
  }
  
  // Method to programmatically test deep links
  static void testDeepLink(String url) {
    debugPrint('Testing deep link: $url');
    NavService.instance.openUrl(url);
  }
}
```

#### Testing Deep Links

```dart
class DeepLinkTester extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Deep Link Tester')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              AdvancedDeepLinkService.testDeepLink('myapp://profile/123?tab=settings');
            },
            child: Text('Test Profile Link'),
          ),
          ElevatedButton(
            onPressed: () {
              AdvancedDeepLinkService.testDeepLink('https://myapp.com/settings/notifications');
            },
            child: Text('Test Settings Link'),
          ),
        ],
      ),
    );
  }
}
```

## Working with Extra Data

### Passing Data

```dart
NavService.instance.push('/profile', extra: {
  'userId': 123,
  'name': 'John Doe',
  'email': 'john@example.com',
  'preferences': {
    'theme': 'dark',
    'notifications': true,
  },
});
```

### Receiving Data in Screens

```dart
class ProfileScreen extends StatelessWidget {
  final NavState state;
  
  const ProfileScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // Access extra data
    final extraData = state.extra?.data ?? {};
    final userId = extraData['userId'];
    final name = extraData['name'];
    
    return Scaffold(
      appBar: AppBar(title: Text('Profile: $name')),
      body: Column(
        children: [
          Text('User ID: $userId'),
          Text('Name: $name'),
          // ... rest of your UI
        ],
      ),
    );
  }
}
```

## Navigation History & Debugging

### Accessing Navigation History

```dart
// Get current navigation stack
List<NavStep> history = NavService.instance.navigationHistory;

// Get current location path
String currentLocation = NavService.instance.joinedLocation;

// Print navigation history
for (int i = 0; i < history.length; i++) {
  print('${i + 1}. ${history[i].currentState.path}');
}
```

### Navigation Observer

The package includes a built-in route observer that automatically tracks navigation events:

```dart
MaterialApp(
  navigatorObservers: [NavService.instance.routeObserver],
  // ...
)
```

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:nav_service/nav_service.dart';

void main() {
  final navigatorKey = GlobalKey<NavigatorState>();
  
  NavService.instance.init(
    NavServiceConfig(
      routes: [
        NavRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        NavRoute(
          path: '/profile',
          builder: (context, state) => ProfileScreen(state: state),
        ),
      ],
      navigatorKey: navigatorKey,
      enableLogger: true,
    ),
  );
  
  runApp(MyApp(navigatorKey: navigatorKey));
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  
  const MyApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      navigatorObservers: [NavService.instance.routeObserver],
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                NavService.instance.push('/profile', extra: {
                  'userId': 123,
                  'name': 'John Doe',
                });
              },
              child: const Text('Go to Profile'),
            ),
            ElevatedButton(
              onPressed: () {
                final history = NavService.instance.navigationHistory;
                print('Navigation history: ${history.length} items');
              },
              child: const Text('Print Navigation History'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final NavState state;
  
  const ProfileScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final extra = state.extra?.data ?? {};
    
    return Scaffold(
      appBar: AppBar(title: Text('Profile: ${extra['name']}')),
      body: Center(
        child: Column(
          children: [
            Text('User ID: ${extra['userId']}'),
            Text('Name: ${extra['name']}'),
            ElevatedButton(
              onPressed: () => NavService.instance.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## API Reference

### NavService

Main navigation service singleton.

#### Configuration Methods
- `init(NavServiceConfig config)` - Initialize the service with routes and configuration

#### Navigation Methods
- `push<T>(String path, {Map<String, dynamic>? extra})` - Push new route
- `pop<T>([T? result])` - Pop current route
- `popUntil(RoutePredicate predicate)` - Pop until condition
- `popUntilPath(String path)` - Pop until specific path
- `canPop()` - Check if can pop
- `maybePop<T>([T? result])` - Pop if possible

#### Smart Navigation
- `navigate(String path, {Map<String, dynamic>? extra, bool forcePush = false})` - Intelligent navigation

#### Replace Operations
- `pushReplacement(String path, {Map<String, dynamic>? extra})` - Replace with animation
- `replace(String path, {Map<String, dynamic>? extra})` - Replace without animation

#### Stack Management
- `pushAndRemoveUntil(String path, RoutePredicate predicate, {Map<String, dynamic>? extra})` - Push and remove until condition
- `popAll()` - Pop all routes with animation
- `removeAll()` - Remove all routes without animation

#### Bulk Operations
- `pushAll(List<NavRouteInfo> routeInfos)` - Push multiple routes
- `replaceAll(List<NavRouteInfo> routeInfos)` - Replace all routes
- `pushReplacementAll(List<NavRouteInfo> routeInfos)` - Replace last with multiple

#### Properties
- `navigationHistory` - List of navigation steps
- `joinedLocation` - Current location path
- `routeObserver` - Built-in route observer

### Core Classes

#### NavRoute
Defines a route with path and builder function.

#### NavState
Contains route path and extra data for each navigation state.

#### NavExtra
Container for extra data passed between routes.

#### NavStep
Represents a step in navigation history.

#### NavRouteInfo
Simple route information for bulk operations.

#### NavServiceConfig
Configuration object for initializing NavService.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
