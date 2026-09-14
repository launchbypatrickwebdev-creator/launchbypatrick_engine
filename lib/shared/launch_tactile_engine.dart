// lib/shared/launch_tactile_engine.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';

class LaunchTactileEngine extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  // 🛰️ FIXED: Optional externally-owned FocusNode. This lets a parent page
  // (like GrowthEnginePage) reclaim scroll-keyboard-focus after something
  // else (e.g. a TextField) takes focus and later gives it up. Without this,
  // the internal autofocus only ever fires once on first mount, and page
  // arrow-key scrolling dies permanently the first time focus moves away.
  final FocusNode? focusNode;

  const LaunchTactileEngine({
    super.key,
    required this.child,
    required this.onRefresh,
    this.focusNode,
  });

  @override
  State<LaunchTactileEngine> createState() => _LaunchTactileEngineState();
}

class _LaunchTactileEngineState extends State<LaunchTactileEngine>
    with SingleTickerProviderStateMixin {
  // 🛰️ FIXED: only create (and later dispose) our own FocusNode if the
  // parent didn't supply one. If a parent-owned node was disposed by the
  // parent, we never touch it here.
  FocusNode? _internalFocusNode;
  FocusNode get _focusNode => widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  final ScrollController _scrollController = ScrollController();

  // 🛰️ FIXED: hold-to-scroll engine. Tracks which scroll keys are physically
  // down and drives movement every frame via a Ticker for as long as
  // they're held, with a short ramp-up so it starts gentle and speeds up
  // the longer you hold it — matching native browser behavior, instead of
  // relying on OS key-repeat (which has its own startup delay and caused
  // stuttering when combined with a fixed-duration animateTo() per press).
  final Set<LogicalKeyboardKey> _heldScrollKeys = {};
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;
  final Stopwatch _holdStopwatch = Stopwatch();

  static const double _baseSpeed = 500.0; // px/sec the instant a key is pressed
  static const double _maxSpeed = 2600.0; // px/sec once fully ramped up
  static const double _rampUpMs = 650.0; // time to reach max speed

  static final Set<LogicalKeyboardKey> _scrollKeys = {
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.pageDown,
    LogicalKeyboardKey.pageUp,
    LogicalKeyboardKey.space,
  };

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    // Safety net: if focus moves away mid-hold (e.g. Tab into a text field),
    // release any held keys so we don't get stuck scrolling forever.
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _stopHolding();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _ticker.dispose();
    _internalFocusNode?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _stopHolding() {
    _heldScrollKeys.clear();
    if (_ticker.isTicking) _ticker.stop();
    _holdStopwatch
      ..stop()
      ..reset();
    _lastTick = Duration.zero;
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    final key = event.logicalKey;
    if (!_scrollKeys.contains(key)) return KeyEventResult.ignored;

    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      final wasEmpty = _heldScrollKeys.isEmpty;
      _heldScrollKeys.add(key);
      if (wasEmpty) {
        _holdStopwatch
          ..reset()
          ..start();
        _lastTick = Duration.zero;
        if (!_ticker.isTicking) _ticker.start();
      }
      return KeyEventResult.handled;
    }

    if (event is KeyUpEvent) {
      _heldScrollKeys.remove(key);
      if (_heldScrollKeys.isEmpty) _stopHolding();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _onTick(Duration elapsed) {
    if (_heldScrollKeys.isEmpty || !_scrollController.hasClients) {
      _lastTick = elapsed;
      return;
    }

    final double dtSeconds = _lastTick == Duration.zero
        ? 0.0
        : (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    if (dtSeconds <= 0) return;

    double direction = 0;
    double weight = 1.0;
    for (final key in _heldScrollKeys) {
      switch (key) {
        case LogicalKeyboardKey.arrowDown:
          direction += 1;
          break;
        case LogicalKeyboardKey.arrowUp:
          direction -= 1;
          break;
        case LogicalKeyboardKey.arrowRight:
          direction += 1;
          weight = weight < 0.5 ? weight : 0.5;
          break;
        case LogicalKeyboardKey.arrowLeft:
          direction -= 1;
          weight = weight < 0.5 ? weight : 0.5;
          break;
        case LogicalKeyboardKey.pageDown:
          direction += 1;
          weight = weight > 3.0 ? weight : 3.0;
          break;
        case LogicalKeyboardKey.pageUp:
          direction -= 1;
          weight = weight > 3.0 ? weight : 3.0;
          break;
        case LogicalKeyboardKey.space:
          direction += 1;
          weight = weight > 2.5 ? weight : 2.5;
          break;
      }
    }
    if (direction == 0) return;

    final double heldMs = _holdStopwatch.elapsedMilliseconds.toDouble();
    final double rampProgress = (heldMs / _rampUpMs).clamp(0.0, 1.0);
    final double speed = _baseSpeed + (_maxSpeed - _baseSpeed) * rampProgress;

    final double delta = direction.sign * speed * weight * dtSeconds;
    final double current = _scrollController.offset;
    final double target = (current + delta).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    if (target != current) {
      _scrollController.jumpTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFF0A0B10),
      backgroundColor: const Color(0xFF00E5FF),
      strokeWidth: 3.0,
      onRefresh: widget.onRefresh,

      child: Focus(
        autofocus: true,
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,

        // 🛰️ FIXED: single real SingleChildScrollView, no duplicate/offstage
        // copy of your content. Always correctly extends to match your
        // content's real height (safe with GridView/ListView/anything),
        // never renders your widgets twice, and never fires their side
        // effects (timers, network calls, etc.) more than once.
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// 🛰️ STICKY FOOTER SPACER
// =========================================================================
// Drop this in a page's content Column right before its footer widget
// (in place of a fixed-height SizedBox gap). It measures where it sits
// within the enclosing Scrollable's content coordinate space — independent
// of current scroll offset — after each frame, and sizes itself to fill
// exactly the remaining space if everything above it is shorter than the
// viewport, pushing the footer to the true bottom of the screen. On tall
// pages it naturally shrinks to zero, leaving normal scrolling untouched.
//
// Deliberately avoids IntrinsicHeight (breaks with GridView/ListView/nested
// scrollables) and SliverFillRemaining(hasScrollBody:false) (silently caps
// how far a tall page can scroll) — it only reads real, already-rendered
// layout geometry, and renders your content exactly once.
class StickyFooterSpacer extends StatefulWidget {
  const StickyFooterSpacer({super.key});

  @override
  State<StickyFooterSpacer> createState() => _StickyFooterSpacerState();
}

class _StickyFooterSpacerState extends State<StickyFooterSpacer> {
  double _gap = 0;

  void _recalculate() {
    if (!mounted) return;
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;

    final scrollableState = Scrollable.maybeOf(context);
    if (scrollableState == null) return;
    final viewportRenderObject = scrollableState.context.findRenderObject();
    if (viewportRenderObject == null) return;

    // Position of this spacer within the scrollable's own content space —
    // deliberately independent of the current scroll offset.
    final Offset posInViewport = renderObject.localToGlobal(
      Offset.zero,
      ancestor: viewportRenderObject,
    );

    final double viewportHeight = scrollableState.position.viewportDimension;
    final double contentAboveHeight = posInViewport.dy;
    final double neededGap = (viewportHeight - contentAboveHeight).clamp(0.0, double.infinity);

    if ((neededGap - _gap).abs() > 0.5) {
      setState(() => _gap = neededGap);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _recalculate());
    return SizedBox(height: _gap);
  }
}