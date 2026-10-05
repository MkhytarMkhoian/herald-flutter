import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:herald/herald.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'herald_scope.dart';

/// Tracks [event] once, when at least [threshold] of [child] is on screen. With a
/// [minVisibleDuration], it has to stay that visible for that long first; leaving earlier cancels
/// the count.
///
/// It counts once per appearance: once [child] has left the screen completely, coming back counts
/// again. To count it once per session, keep that rule in the caller.
///
/// A new, unequal [event] starts the count again, so give events value equality.
///
/// It needs a [HeraldScope] above it. Throws an [ArgumentError] if [threshold] isn't between 0
/// and 1.
final class const TrackImpression({
  super.key,
  required final Event event,
  final double threshold = 0.5,
  final Duration minVisibleDuration = Duration.zero,
  required final Widget child,
}) extends StatefulWidget {
  @override
  State<TrackImpression> createState() => _TrackImpressionState();
}

final class _TrackImpressionState extends State<TrackImpression> {
  final Key _detectorKey = UniqueKey();
  late EventTrackerService _analytics;
  double _visibleFraction = 0;
  bool _tracked = false;
  Timer? _pending;

  @override
  void initState() {
    super.initState();
    _checkThreshold();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _analytics = HeraldScope.of(context);
  }

  @override
  void didUpdateWidget(TrackImpression oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkThreshold();
    if (widget.event != oldWidget.event) _restart();
    _evaluate(); // the detector reports only changes, so look again with the new settings
  }

  void _checkThreshold() {
    final threshold = widget.threshold;
    if (threshold < 0 || threshold > 1) {
      throw ArgumentError.value(threshold, 'threshold', 'must be between 0 and 1');
    }
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!mounted) return;
    _visibleFraction = info.visibleFraction;
    _evaluate();
  }

  void _evaluate() {
    if (_visibleFraction == 0) {
      _restart(); // gone: the next appearance counts again
      return;
    }
    if (_tracked) return;
    if (_visibleFraction < widget.threshold) {
      _cancelPending();
    } else if (widget.minVisibleDuration == Duration.zero) {
      _track();
    } else {
      _pending ??= Timer(widget.minVisibleDuration, _track);
    }
  }

  void _track() {
    _pending = null;
    _tracked = true;
    final event = widget.event;
    final analytics = _analytics;
    // A new event is checked during a build, and a tracker that updates the UI can't run then.
    scheduleMicrotask(() => analytics.track(event).ignore());
  }

  void _restart() {
    _tracked = false;
    _cancelPending();
  }

  void _cancelPending() {
    _pending?.cancel();
    _pending = null;
  }

  @override
  void dispose() {
    _cancelPending();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => VisibilityDetector(
    key: _detectorKey,
    onVisibilityChanged: _onVisibilityChanged,
    child: widget.child,
  );
}
