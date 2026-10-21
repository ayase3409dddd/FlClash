import 'package:flutter/animation.dart';
import 'package:flutter/physics.dart';

const fadeTabDuration = Duration(milliseconds: 220);
const fadeTabCurve = Curves.easeInOut;

/// The slide between tabs eases in and out without the late, slow crawl of a
/// pure ease-out; the middle stays even and the settle is short.
const slideTabCurve = Cubic(0.25, 0.1, 0.25, 1);

const minTabAnimationSpeed = 0.5;
const maxTabAnimationSpeed = 2.0;

/// Scales a tab transition's base [duration] by the user's speed multiplier:
/// faster runs in less time, and values outside the slider's range clamp.
Duration tabAnimationDurationOf(Duration duration, double speed) {
  final clamped = speed.clamp(minTabAnimationSpeed, maxTabAnimationSpeed);
  return duration * (1 / clamped);
}

/// Plays [spring] over the first [seconds] of an animation, easing out the
/// remaining residual so the curve still ends exactly at 1.
class SpringCurve extends Curve {
  SpringCurve(SpringDescription spring, {required this.seconds})
    : _simulation = SpringSimulation(spring, 0, 1, 0);

  final double seconds;
  final SpringSimulation _simulation;

  late final double _residual = 1 - _simulation.x(seconds);

  @override
  double transformInternal(double t) =>
      _simulation.x(t * seconds) + _residual * t;
}
