import 'package:flutter/material.dart';
import 'package:herald_widgets/herald_widgets.dart';

import '../analytics/events.dart';

import '../analytics/timeline_analytics.dart';
import 'product_screen.dart';
import 'settings_screen.dart';

/// Products, and below them every call Herald made, newest first.
class const HomeScreen({required final TimelineAnalytics timeline, super.key})
    extends StatelessWidget {
  static const route = '/';
  static const products = ['day_pass', 'week_pass', 'month_pass'];

  // The screen view comes from herald_widgets: each time Home becomes visible, also when the user
  // comes back to it.
  @override
  Widget build(BuildContext context) => TrackScreenView(
    event: const HomeViewed(),
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Herald example'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed(SettingsScreen.route),
          ),
        ],
      ),
      body: Column(
        children: [
          for (final product in products)
            ListTile(
              title: Text(product),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).pushNamed(ProductScreen.route, arguments: product),
            ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Align(alignment: Alignment.centerLeft, child: Text('What Herald sent')),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: timeline,
              builder: (context, _) => ListView(
                key: const Key('timeline'),
                children: [
                  for (final line in timeline.lines)
                    ListTile(
                      dense: true,
                      title: Text(line, style: const TextStyle(fontFamily: 'monospace')),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
