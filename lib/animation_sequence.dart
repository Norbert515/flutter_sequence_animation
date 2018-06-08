import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class _AnimationInformation {
 // final _AnimInfo animInfo;
  final Animatable animatable;
  final Duration from;
  final Duration to;
  final Curve curve;
  final Object tag;

  _AnimationInformation({this.animatable, this.from, this.to, this.curve, this.tag,});
}

class SequenceAnimationBuilder {

  List<_AnimationInformation> _animations = [];

  /// Adds an [Animatable] to the sequence, in the most cases this would be a [Tween]
  /// The from and to [Duration] specify points in time the animation takes place.
  /// You can also specify a [Curve] the animation should interpolate along.
  ///
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
    _animations.add(new _AnimationInformation(animatable: anim,from: from, to: to, curve: curve, tag: tag));
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

    // Sets the duration
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
            first: anims[info.tag],
            second: IntervalAnimatable.chainCurve(info.animatable, intervalCurve),
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

  SequenceAnimation._internal(this._animations);

  Animation operator [](Object key) {
    assert(_animations.containsKey(key), "There was no animatable with the key: $key");
    return _animations[key];
  }

}

class IntervalAnimatable<T> extends Animatable<T> {

  final Animatable first;
  final Animatable second;
  /// The relative begin to of the first animation
  /// If your animationcontroller is running from 0->1
  final double begin;
  final double end;

  IntervalAnimatable({@required this.first, @required this.second, @required this.begin, @required this.end});

  @override
  T evaluate(Animation<double> animation) {
    double t = animation.value;
    if(t >= begin && t <= end) {
      return first.evaluate(animation);
    } else {
      return second.evaluate(animation);
    }
  }


  /// Chains an animatable with a CurveTween and the given interval.
  /// Basically, the animation gets contrained to the given interval
  static Animatable chainCurve(Animatable parent, Interval interval) {
    return parent.chain(new CurveTween(curve: interval));
  }
}