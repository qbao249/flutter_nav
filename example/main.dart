import 'package:flutter/material.dart';
import 'package:flutter_nav/flutter_nav.dart';

import 'links/profile_link_handler.dart';
import 'links/settings_link_handler.dart';
import 'scenes/home.dart';
import 'scenes/profile.dart';
import 'scenes/settings.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  Nav.init(
    NavConfig(
      navigatorKey: navigatorKey,
      routes: navRoutes,
      enableLogger: true,
      linkPrefixes: ['myapp://', 'https://myapp.com/'],
      linkHandlers: [SettingsLinkHandler(), ProfileLinkHandler()],
    ),
  );
  runApp(const NavServiceExample());
}

class NavServiceExample extends StatelessWidget {
  const NavServiceExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NavService Example',
      navigatorKey: navigatorKey,
      navigatorObservers: [...Nav.observers],
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const LaunchScreen(),
    );
  }
}

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Replace with setup process here
      await Future.delayed(const Duration(seconds: 1));
      Nav.page.replaceAll([
        NavRouteInfo(path: '/home'),
        NavRouteInfo(path: '/settings'),
      ]);
    });
  }

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
