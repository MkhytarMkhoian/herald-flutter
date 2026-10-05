import 'package:flutter/material.dart';
import 'package:herald/herald.dart';

final class const SettingsScreenViewed() extends ScreenViewEvent {
  @override
  String get name => 'settings';
}

// --8<-- [start:plain]
// Plain Herald, no extra package: the screen tracks its own screen view, once each time it opens.
final class const SettingsPage(final EventTrackerService analytics, {super.key})
    extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

final class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    widget.analytics.track(const SettingsScreenViewed()).ignore(); // Herald never fails a call
  }

  @override
  Widget build(BuildContext context) => const Scaffold();
}
// --8<-- [end:plain]
