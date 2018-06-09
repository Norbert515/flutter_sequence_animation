import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class _AnimationInformation {
  final Animatable animatable;
  final Duration from;
  final Duration to;
  final Curve curve;
  final Object tag;

  _AnimationInformation({this.animatable, this.from, this.to, this.curve, this.tag,});
}

class SequenceAnimationBuilder {

  List<_AnimationInformation> _animations = [];

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
  ///     var sequenceAnimation = new SequenceAnimationBuilder()
  ///      .addAnimatable(
  ///        anim: new ColorTween(begin: Colors.red, end: Colors.yellow),
  ///        from:  const Duration(seconds: 0),
  ///        to: const Duration(seconds: 2),
  ///        tag: "color").animate(controller);
  /// ```
  ///
  SequenceAnimationBuilder addAnimatable(
      {@required Animatable anim,
        @required Duration from,
        @required Duration to,
        Curve curve = Curves.linear,
        @required Object tag}) {
    assert(to >= from);
    _animations.add(new _AnimationInformation(animatable: anim, from: from, to: to, curve: curve, tag: tag));
    return this;
  }


  /// The controllers duration is going to be overwritten by this class, you should not specify it on your own
  SequenceAnimation animate(AnimationController controller) {
    int longestTimeMicro = 0;
    _animations.forEach((info) {
      var micro = info.to.inMicroseconds;
      if (micro > longestTimeMicro) {
        longestTimeMicro = micro;
      }
    });
    // Sets the duration of the controller
    controller.duration = new Duration(microseconds: longestTimeMicro);

    var anims = <Object, Animatable>{};
    var begins = <Object, double>{};
    var ends = <Object, double>{};

    _animations.forEach((info) {
      assert(info.to.inMicroseconds <= longestTimeMicro);

      var begin = info.from.inMicroseconds / longestTimeMicro;
      var end = info.to.inMicroseconds / longestTimeMicro;
      Interval intervalCurve = new Interval(begin, end, curve: info.curve);
      if (anims[info.tag] == null) {
        anims[info.tag] = IntervalAnimatable.chainCurve(info.animatable, intervalCurve);
        begins[info.tag] = begin;
        ends[info.tag] = end;
      } else {
        assert(ends[info.tag] <= begin, "When animating the same property you need to: \n"
            "a) Have them not overlap \n"
            "b) Add them in an ordered fashion");
        anims[info.tag] = new IntervalAnimatable(
            anim: anims[info.tag],
            defaultAnim: IntervalAnimatable.chainCurve(info.animatable, intervalCurve),
          begin: begins[info.tag],
          end: ends[info.tag],
        );
        ends[info.tag] = end;

      }
    });

    var result = <Object, Animation>{};

    anims.forEach((tag, animInfo) {
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
    assert(_animations.containsKey(key), "There was no animatable with the key: $key");
    return _animations[key];
  }

}
/// Evaluates [anim] if the animation is in the time-frame of [begin] (inclusive) and [end] (inclusive),
/// if not it evaluates the [defaultAnim]
class IntervalAnimatable<T> extends Animatable<T> {

  final Animatable anim;
  final Animatable defaultAnim;
  /// The relative begin to of [anim]
  /// If your [AnimationController] is running from 0->1, this needs to be a value between those two
  final double begin;
  /// The relative end to of [anim]
  /// If your [AnimationController] is running from 0->1, this needs to be a value between those two
  final double end;

  IntervalAnimatable({@required this.anim, @required this.defaultAnim, @required this.begin, @required this.end});

  @override
  T evaluate(Animation<double> animation) {
    double t = animation.value;
    if(t >= begin && t <= end) {
      return anim.evaluate(animation);
    } else {
      return defaultAnim.evaluate(animation);
    }
  }


  /// Chains an [Animatable] with a [CurveTween] and the given [Interval].
  /// Basically, the animation is being constrained to the given interval
  static Animatable chainCurve(Animatable parent, Interval interval) {
    return parent.chain(new CurveTween(curve: interval));
  }
}