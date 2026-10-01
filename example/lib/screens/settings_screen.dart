import 'package:flutter/material.dart';
import 'package:herald/herald.dart';

import '../analytics/events.dart';

/// Consent, sign-in and a preference: each control needs a different analytics interface, and
/// gets only that one.
class const SettingsScreen({
  required final ConsentService consent,
  required final IdentifiableUserService identity,
  required final PropertyTrackerService properties,
  required final bool dark,
  required final ValueChanged<bool> onDarkChanged,
  super.key,
}) extends StatefulWidget {
  static const route = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  var _consent = false;
  var _signedIn = false;
  late var _dark = widget.dark;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: ListView(
      children: [
        SwitchListTile(
          title: const Text('Share analytics'),
          value: _consent,
          onChanged: (enabled) async {
            setState(() => _consent = enabled);
            await widget.consent.setEnabled(enabled);
          },
        ),
        SwitchListTile(
          title: const Text('Signed in as user-42'),
          value: _signedIn,
          onChanged: (signedIn) async {
            setState(() => _signedIn = signedIn);
            await (signedIn
                ? widget.identity.identify(const Identity('user-42'))
                : widget.identity.reset());
          },
        ),
        SwitchListTile(
          title: const Text('Dark theme'),
          value: _dark,
          onChanged: (dark) async {
            setState(() => _dark = dark);
            widget.onDarkChanged(dark);
            await widget.properties.set(AppTheme(dark: dark));
          },
        ),
      ],
    ),
  );
}
