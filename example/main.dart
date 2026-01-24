import 'package:flutter/material.dart';
import 'package:flutter_nav/flutter_nav.dart';
// Note: Uncomment and add shared_preferences to your pubspec.yaml to enable persistence
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

import 'links/profile_link_handler.dart';
import 'links/settings_link_handler.dart';
import 'scenes/home.dart';
import 'scenes/profile.dart';
import 'scenes/settings.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final restorationId = 'app_restoration_id';

void main() {
  Nav.init(
    NavConfig(
      navigatorKey: navigatorKey,
      routes: navRoutes,
      enableLogger: true,
      linkPrefixes: ['myapp://', 'https://myapp.com/'],
      linkHandlers: [SettingsLinkHandler(), ProfileLinkHandler()],
      // Uncomment to enable persistence (requires shared_preferences package)
      // pagePersistence: NavPagePersistence(
      //   onPersist: (routes) async {
      //     final pref = await SharedPreferences.getInstance();
      //     pref.setString(restorationId, jsonEncode(routes));
      //   },
      //   onRestore: () async {
      //     final pref = await SharedPreferences.getInstance();
      //     final jsonString = pref.getString(restorationId);
      //     if (jsonString != null) {
      //       final List<dynamic> data = jsonDecode(jsonString);
      //       return List<Map<String, dynamic>>.from(data);
      //     }
      //     return [];
      //   },
      //   enableSchedule: true,
      //   schedule: NavPagePersistenceSchedule(immediate: true),
      // ),
    ),
  );
  runApp(const NavServiceExample());
}

class NavServiceExample extends StatefulWidget {
  const NavServiceExample({super.key});

  @override
  State<NavServiceExample> createState() => _NavServiceExampleState();
}

class _NavServiceExampleState extends State<NavServiceExample> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Simulate app launch progress (auth, initialization, etc.)
      await Future.delayed(const Duration(seconds: 2));
      // App started - restore or set initial routes
      Nav.page.launched([NavRouteInfo(path: '/home')]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NavService Example',
      navigatorKey: navigatorKey,
      navigatorObservers: [...Nav.observers],
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const PlashScreen(),
    );
  }
}

class PlashScreen extends StatelessWidget {
  const PlashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

final navRoutes = [
  NavRoute(path: '/home', builder: (context, state) => const HomeScreen()),
  NavRoute(
    path: '/settings',
    builder: (context, state) => SettingsScreen(state: state),
  ),
  NavRoute(
    path: '/profile',
    builder: (context, state) => ProfileScreen(state: state),
  ),
];
