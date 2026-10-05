# Herald example

A Flutter app that sends every Herald call to the log and to an on-screen timeline.

It tracks screen views both ways Herald supports, so you can compare them:

- **Home and Product** use `TrackScreenView` from the optional `herald_widgets` package. A screen
  view is tracked each time the screen becomes visible, also when the user comes back to it.
- **Settings** tracks its own screen view with plain Herald, through the `EventTrackerService` it
  is given: once each time it opens. No extra package.

The other screens' events (added to cart, order paid, consent, sign-in) are tracked the plain way,
from the screen that owns them.

Run it with `flutter run`, and watch the timeline on the home screen and the `[herald]` lines in the
console.
