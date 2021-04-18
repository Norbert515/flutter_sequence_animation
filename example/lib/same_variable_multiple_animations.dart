import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sequence_animation/flutter_sequence_animation.dart';

class SameVariableAnimationPage extends StatefulWidget {
  @override
  _SameVariableAnimationPageState createState() =>
      new _SameVariableAnimationPageState();
}

class _SameVariableAnimationPageState extends State<SameVariableAnimationPage>
    with SingleTickerProviderStateMixin {
  static const colorTag = SequenceAnimationTag<Color?>("color");
  static const widthTag = SequenceAnimationTag<double>("width");
  static const heightTag = SequenceAnimationTag<double>("height");

  late AnimationController controller;
  late SequenceAnimation sequenceAnimation;

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(
        vsync: this, duration: const Duration(seconds: 5));

    sequenceAnimation = new SequenceAnimationBuilder()
        .addAnimatable(
            animatable: new ColorTween(begin: Colors.red, end: Colors.yellow),
            from: const Duration(seconds: 0),
            to: const Duration(seconds: 4),
            tag: colorTag)
        .addAnimatable(
            animatable: new Tween<double>(begin: 50.0, end: 300.0),
            from: const Duration(seconds: 0),
            to: const Duration(milliseconds: 3000),
            tag: widthTag,
            curve: Curves.easeIn)
        .addAnimatable(
            animatable: new Tween<double>(begin: 300.0, end: 100.0),
            from: const Duration(milliseconds: 3000),
            to: const Duration(milliseconds: 3700),
            tag: widthTag,
            curve: Curves.decelerate)
        .addAnimatable(
            animatable: new Tween<double>(begin: 50.0, end: 300.0),
            from: const Duration(seconds: 0),
            to: const Duration(milliseconds: 3000),
            tag: heightTag,
            curve: Curves.ease)
        .addAnimatable(
            animatable: new Tween<double>(begin: 300.0, end: 450.0),
            from: const Duration(milliseconds: 3000),
            to: const Duration(milliseconds: 3800),
            tag: heightTag,
            curve: Curves.decelerate)
        .animate(controller);
  }

  Future<Null> _playAnimation() async {
    try {
      await controller.forward().orCancel;
      await controller.reverse().orCancel;
    } on TickerCanceled {
      // the animation got canceled, probably because we were disposed
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Sequence"),
      ),
      body: new GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _playAnimation();
        },
        child: new AnimatedBuilder(
          builder: (context, child) {
            return new Center(
              child: new Container(
                color: sequenceAnimation.get(colorTag).value,
                height: sequenceAnimation.get(heightTag).value,
                width: sequenceAnimation.get(widthTag).value,
              ),
            );
          },
          animation: controller,
        ),
      ),
    );
  }
}
