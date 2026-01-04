import 'package:flutter/material.dart';
import 'package:flutter_nav/flutter_nav.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.state});

  final NavState state;

  @override
  Widget build(BuildContext context) {
    final extraData = state.extra?.data ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Screen'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Settings Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (extraData.isNotEmpty) ...[
              const Text(
                'Extra Data Received:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      extraData.entries
                          .map((e) => Text('${e.key}: ${e.value}'))
                          .toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],
            ElevatedButton(
              onPressed: () {
                Nav.page.push('/home');
              },
              child: const Text('Push Home'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Nav.page.push(
                  '/profile',
                  extra: {'userId': 789, 'source': 'settings'},
                );
              },
              child: const Text('Push Profile'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Nav.page.replaceAll([
                  NavRouteInfo(path: '/home'),
                  NavRouteInfo(path: '/profile', extra: {'resetNav': true}),
                ]);
              },
              child: const Text('Replace All with Home → Profile'),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const Text(
              'Deep Linking Demo:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Test deep linking with scheme URL
                Nav.link.openUrl('myapp://profile/123?source=app');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Test Deep Link: Profile'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Test deep linking with domain URL
                Nav.link.openUrl(
                  'https://myapp.com/settings/notifications?enabled=true',
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Test Deep Link: Settings'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Test user profile deep link
                Nav.link.openUrl('myapp://user/456?tab=activity');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Test User Profile Link'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        Nav.page.canPop()
                            ? () => Nav.page.pop('settings_result')
                            : null,
                    child: const Text('Pop with Result'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Nav.page.popUntilPath('/home');
                    },
                    child: const Text('Pop Until Home'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
