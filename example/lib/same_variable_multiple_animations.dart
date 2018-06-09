import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sequence_animation/flutter_sequence_animation.dart';

class SameVariableAnimationPage extends StatefulWidget {
  @override
  _SameVariableAnimationPageState createState() => new _SameVariableAnimationPageState();
}

class _SameVariableAnimationPageState extends State<SameVariableAnimationPage> with SingleTickerProviderStateMixin{


  AnimationController controller;
  SequenceAnimation sequenceAnimation;

  bool forward;

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(vsync: this, duration: const Duration(seconds: 5));

    sequenceAnimation = new SequenceAnimationBuilder()
      .addAnimatable(
            anim: new ColorTween(begin: Colors.red, end: Colors.yellow),
            from:  const Duration(seconds: 0),
            to: const Duration(seconds: 4),
            tag: "color"
        ).addAnimatable(
            anim: new Tween<double>(begin: 50.0, end: 300.0),
            from:  const Duration(seconds: 0),
            to: const Duration(milliseconds: 3000),
            tag: "width",
            curve: Curves.easeIn
        ).addAnimatable(
            anim: new Tween<double>(begin: 300.0, end: 100.0),
            from:  const Duration(milliseconds: 3000),
            to: const Duration(milliseconds: 3700),
            tag: "width",
            curve: Curves.decelerate
        ).addAnimatable(
            anim: new Tween<double>(begin: 50.0, end: 300.0),
            from:  const Duration(seconds: 0),
            to: const Duration(milliseconds: 3000),
            tag: "height",
            curve: Curves.ease
        ).addAnimatable(
            anim: new Tween<double>(begin: 300.0, end: 450.0),
            from:  const Duration(milliseconds: 3000),
            to: const Duration(milliseconds: 3800),
            tag: "height",
            curve: Curves.decelerate
         ).animate(controller);


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
                color: sequenceAnimation["color"].value,
                height: sequenceAnimation["height"].value,
                width: sequenceAnimation["width"].value,
              ),
            );
          },
          animation: controller,
        ),
      ),
    );
  }

}
