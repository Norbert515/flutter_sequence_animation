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


  /// The controller duration is going to be overwritten by this class, you don't need to specify it on your own

  SequenceAnimation animate(AnimationController controller) {
    int longestTimeMicro = 0;
    _animations.forEach((info) {
      var micro = info.to.inMicroseconds;
      if (micro > longestTimeMicro) {
        longestTimeMicro = micro;
      }
    });
    //TODO assertions

    // Sets the duration
    controller.duration = new Duration(microseconds: longestTimeMicro);

    var anims = <String, Animatable>{};
    var begins = <String, double>{};
    var ends = <String, double>{};

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

    var result = <String, Animation>{};

    anims.forEach((tag, animInfo) {
      result[tag] = animInfo.animate(controller);
    });

    return new SequenceAnimation(result);
  }

}

class SequenceAnimation {

  final Map<Object, Animation> _animations;

  SequenceAnimation(this._animations);

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


  static Animatable chainCurve(Animatable parent, Interval interval) {
    return parent.chain(new CurveTween(curve: interval));
  }
}