import 'package:flutter/material.dart';
import 'package:herald/herald.dart';

import 'analytics/events.dart';
import 'analytics/herald_setup.dart';
import 'analytics/screen_view_observer.dart';
import 'analytics/timeline_analytics.dart';
import 'screens/home_screen.dart';
import 'screens/product_screen.dart';
import 'screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final timeline = TimelineAnalytics();
  final herald = buildHerald(timeline);

  // Start the vendors, then re-apply the stored consent: some vendors forget it between launches.
  // This app stores nothing, so it starts without consent.
  await herald.start();
  await herald.setEnabled(false);

  runApp(HeraldExampleApp(herald: herald, timeline: timeline));
}

class const HeraldExampleApp({
  /// Each screen gets only the interface it needs.
  required final Herald herald,
  required final TimelineAnalytics timeline,
  super.key,
}) extends StatefulWidget {
  @override
  State<HeraldExampleApp> createState() => _HeraldExampleAppState();
}

class _HeraldExampleAppState extends State<HeraldExampleApp> {
  late final _screenViews = ScreenViewObserver(
    widget.herald,
    (route) => switch (route.settings) {
      RouteSettings(name: HomeScreen.route) => const HomeViewed(),
      RouteSettings(name: ProductScreen.route, :final String arguments) => ProductViewed(arguments),
      RouteSettings(name: SettingsScreen.route) => const SettingsViewed(),
      _ => null,
    },
  );

  var _dark = false;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Herald example',
    theme: ThemeData(colorSchemeSeed: Colors.indigo),
    darkTheme: ThemeData(colorSchemeSeed: Colors.indigo, brightness: Brightness.dark),
    themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
    navigatorObservers: [_screenViews],
    initialRoute: HomeScreen.route,
    onGenerateRoute: (settings) => MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => switch (settings.name) {
        ProductScreen.route => ProductScreen(
          productId: settings.arguments! as String,
          analytics: widget.herald,
          properties: widget.herald,
        ),
        SettingsScreen.route => SettingsScreen(
          consent: widget.herald,
          identity: widget.herald,
          properties: widget.herald,
          dark: _dark,
          onDarkChanged: (dark) => setState(() => _dark = dark),
        ),
        _ => HomeScreen(timeline: widget.timeline),
      },
    ),
  );
}
