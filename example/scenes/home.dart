import 'package:flutter/material.dart';
import 'package:flutter_nav/flutter_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageAware(
      onAfterFirstFrame: () => debugPrint('HomeScreen: after first frame'),
      onAppear: () => debugPrint('HomeScreen: onAppear'),
      onDisappear: () => debugPrint('HomeScreen: onDisappear'),
      onDidPush: () => debugPrint('HomeScreen: onDidPush'),
      onDidPop: () => debugPrint('HomeScreen: onDidPop'),
      onDispose: () => debugPrint('HomeScreen: onDispose'),
      onInit: () => debugPrint('HomeScreen: onInit'),
      waitForTransition: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home Screen'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                _showNavigationInfo(context);
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Home Screen',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Demonstrates basic navigation operations:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Nav.page.push('/settings');
                },
                child: const Text('Push Settings'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Nav.page.push(
                    '/profile',
                    extra: {
                      'userId': 456,
                      'name': 'John Doe',
                      'email': 'john@example.com',
                    },
                  );
                },
                child: const Text('Push Profile with Data'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Nav.page.pushReplacement('/settings');
                },
                child: const Text('Replace with Settings'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Nav.page.navigate('/profile');
                },
                child: const Text('Navigate (Smart Navigation)'),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          Nav.page.canPop() ? () => Nav.page.pop() : null,
                      child: const Text('Pop'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (Nav.page.navigationHistory.length > 1) {
                          Nav.page.popAll();
                        }
                      },
                      child: const Text('Pop All'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNavigationInfo(BuildContext context) {
    final history = Nav.page.navigationHistory;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Navigation Info'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Location: ${Nav.page.joinedLocation}'),
                const SizedBox(height: 8),
                Text('History Count: ${history.length}'),
                const SizedBox(height: 8),
                const Text('Navigation Stack:'),
                ...history.map((step) => Text('• ${step.currentState.path}')),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
