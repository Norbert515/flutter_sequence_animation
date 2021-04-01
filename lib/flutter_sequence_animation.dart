import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class _AnimationInformation {
  _AnimationInformation({
    required this.animatable,
    required this.from,
    required this.to,
    required this.curve,
    required this.tag,
  });

  final Animatable animatable;
  final Duration from;
  final Duration to;
  final Curve curve;
  final Object tag;
}

class SequenceAnimationBuilder {
  List<_AnimationInformation> _animations = [];


  // Returns the duration of the current animation chain
  Duration getCurrentDuration() {
    return Duration(microseconds: _currentLengthInMicroSeconds());
  }


  /// Convenient wrapper to add an animatable after the last one with a specific tag finished is finished
  ///
  /// The tags must be comparable! Strings, enums work, when using objects, be sure to override the == method
  ///
  /// [delay] is the delay to when this animation should start after the last one finishes.
  /// For example:
  ///
  ///```dart
  ///     SequenceAnimation sequenceAnimation = new SequenceAnimationBuilder()
  ///         .addAnimatable(
  ///           animatable: new ColorTween(begin: Colors.red, end: Colors.yellow),
  ///           from: const Duration(seconds: 0),
  ///           to: const Duration(seconds: 2),
  ///           tag: "color",
  ///         ).addAnimatableAfterLastOneWithTag(
  ///            animatable: new ColorTween(begin: Colors.red, end: Colors.yellow),
  ///            delay: const Duration(seconds: 1),
  ///            duration: const Duration(seconds: 1),
  ///            tag: "animation",
  ///            lastTag: "color",
  ///         ).animate(controller);
  ///
  /// ```
  ///
  /// The animation with tag "animation" will start at second 3 and run until second 4.
  ///
  SequenceAnimationBuilder addAnimatableAfterLastOneWithTag({
    required Object lastTag,
    required Animatable animatable,
    Duration delay: Duration.zero,
    required Duration duration,
    Curve curve: Curves.linear,
    required Object tag,
  }) {
    assert(_animations.isNotEmpty, "Can not add animatable after last one if there is no animatable yet");
    var start = _animations.cast<_AnimationInformation?>().lastWhere((it) => it?.tag == lastTag, orElse: () => null)?.to;
    assert(start != null, "Animation with tag $lastTag can not be found before $tag");
    start!;
    return addAnimatable(animatable: animatable, from: start + delay, to: start + delay + duration, tag: tag, curve: curve);
  }

  /// Convenient wrapper to add an animatable after the last one is finished
  ///
  /// [delay] is the delay to when this animation should start after the last one finishes.
  /// For example:
  ///
  ///```dart
  ///     SequenceAnimation sequenceAnimation = new SequenceAnimationBuilder()
  ///         .addAnimatable(
  ///           animatable: new ColorTween(begin: Colors.red, end: Colors.yellow),
  ///           from: const Duration(seconds: 0),
  ///           to: const Duration(seconds: 2),
  ///           tag: "color",
  ///         ).addAnimatableAfterLastOne(
  ///            animatable: new ColorTween(begin: Colors.red, end: Colors.yellow),
  ///            delay: const Duration(seconds: 1),
  ///            duration: const Duration(seconds: 1),
  ///            tag: "animation",
  ///         ).animate(controller);
  ///
  /// ```
  ///
  /// The animation with tag "animation" will start at second 3 and run until second 4.
  ///
  SequenceAnimationBuilder addAnimatableAfterLastOne({
    required Animatable animatable,
    Duration delay: Duration.zero,
    required Duration duration,
    Curve curve: Curves.linear,
    required Object tag,
  }) {
    assert(_animations.isNotEmpty, "Can not add animatable after last one if there is no animatable yet");
    var start = _animations.last.to;
    return addAnimatable(animatable: animatable, from: start + delay, to: start + delay + duration, tag: tag, curve: curve);
  }

  /// Convenient wrapper around to specify an animatable using a duration instead of end point
  ///
  /// Instead of specifying from and to, you specify start and duration
  SequenceAnimationBuilder addAnimatableUsingDuration({
    required Animatable animatable,
    required Duration start,
    required Duration duration,
    Curve curve: Curves.linear,
    required Object tag,
    }) {
    return addAnimatable(animatable: animatable, from: start, to: start + duration, tag: tag, curve: curve);
  }

  /// Adds an [Animatable] to the sequence, in the most cases this would be a [Tween].
  /// The from and to [Duration] specify points in time where the animation takes place.
  /// You can also specify a [Curve] for the [Animatable].
  ///
  /// [Animatable]s which animate on the same tag are not allowed to overlap and they also need to be add in the same order they are played.
  /// These restrictions only apply to [Animatable]s operating on the same tag.
  ///
  ///
  /// ## Sample code
  ///
  /// ```dart
  ///     SequenceAnimation sequenceAnimation = new SequenceAnimationBuilder()
  ///         .addAnimatable(
  ///           animatable: new ColorTween(begin: Colors.red, end: Colors.yellow),
  ///           from: const Duration(seconds: 0),
  ///           to: const Duration(seconds: 2),
  ///           tag: "color",
  ///         )
  ///         .animate(controller);
  /// ```
  ///
  SequenceAnimationBuilder addAnimatable({
    required Animatable animatable,
    required Duration from,
    required Duration to,
    Curve curve: Curves.linear,
    required Object tag,
  }) {
    assert(to >= from);
    _animations.add(new _AnimationInformation(
        animatable: animatable, from: from, to: to, curve: curve, tag: tag));
    return this;
  }

  int _currentLengthInMicroSeconds() {
    int longestTimeMicro = 0;
    _animations.forEach((info) {
      int micro = info.to.inMicroseconds;
      if (micro > longestTimeMicro) {
        longestTimeMicro = micro;
      }
    });
    return longestTimeMicro;
  }

  /// The controllers duration is going to be overwritten by this class, you should not specify it on your own
  SequenceAnimation animate(AnimationController controller) {
    int longestTimeMicro = _currentLengthInMicroSeconds();
    // Sets the duration of the controller
    controller.duration = new Duration(microseconds: longestTimeMicro);

    Map<Object, Animatable> animatables = {};
    Map<Object, double> begins = {};
    Map<Object, double> ends = {};

    _animations.forEach((info) {
      assert(info.to.inMicroseconds <= longestTimeMicro);

      double begin = info.from.inMicroseconds / longestTimeMicro;
      double end = info.to.inMicroseconds / longestTimeMicro;
      Interval intervalCurve = new Interval(begin, end, curve: info.curve);
      if (animatables[info.tag] == null) {
        animatables[info.tag] =
            IntervalAnimatable.chainCurve(info.animatable, intervalCurve);
        begins[info.tag] = begin;
        ends[info.tag] = end;
      } else {
        assert(
            ends[info.tag]! <= begin,
            "When animating the same property you need to: \n"
            "a) Have them not overlap \n"
            "b) Add them in an ordered fashion\n"
            "Animation with tag ${info.tag} ends at ${ends[info.tag]} but also begins at $begin"
        );
        animatables[info.tag] = new IntervalAnimatable(
          animatable: animatables[info.tag]!,
          defaultAnimatable:
              IntervalAnimatable.chainCurve(info.animatable, intervalCurve),
          begin: begins[info.tag]!,
          end: ends[info.tag]!,
        );
        ends[info.tag] = end;
      }
    });

    Map<Object, Animation> result = {};

    animatables.forEach((tag, animInfo) {
      result[tag] = animInfo.animate(controller);
    });

    return new SequenceAnimation._internal(result);
  }
}

class SequenceAnimation {
  final Map<Object, Animation> _animations;

  /// Use the [SequenceAnimationBuilder] to construct this class.
  SequenceAnimation._internal(this._animations);

  /// Returns the animation with a given tag, this animation is tied to the controller.
  Animation operator [](Object key) {
    assert(_animations.containsKey(key),
        "There was no animatable with the key: $key");
    return _animations[key]!;
  }
}

/// Evaluates [animatable] if the animation is in the time-frame of [begin] (inclusive) and [end] (inclusive),
/// if not it evaluates the [defaultAnimatable]
class IntervalAnimatable<T> extends Animatable<T> {
  IntervalAnimatable({
    required this.animatable,
    required this.defaultAnimatable,
    required this.begin,
    required this.end,
  });

  final Animatable animatable;
  final Animatable defaultAnimatable;

  /// The relative begin to of [animatable]
  /// If your [AnimationController] is running from 0->1, this needs to be a value between those two
  final double begin;

  /// The relative end to of [animatable]
  /// If your [AnimationController] is running from 0->1, this needs to be a value between those two
  final double end;

  /// Chains an [Animatable] with a [CurveTween] and the given [Interval].
  /// Basically, the animation is being constrained to the given interval
  static Animatable chainCurve(Animatable parent, Interval interval) {
    return parent.chain(new CurveTween(curve: interval));
  }

  @override
  T transform(double t) {
    if (t >= begin && t <= end) {
      return animatable.transform(t);
    } else {
      return defaultAnimatable.transform(t);
    }
  }
}
