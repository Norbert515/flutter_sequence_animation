import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sequence_animation/animation_sequence.dart';

class SequencePage extends StatefulWidget {
  @override
  _SequencePageState createState() => new _SequencePageState();
}

class _SequencePageState extends State<SequencePage> with SingleTickerProviderStateMixin{


  AnimationController controller;
  SequenceAnimation sequenceAnimation;

  bool forward;

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(vsync: this);

    sequenceAnimation = new SequenceAnimationBuilder()
      .addAnimatable(
          anim: new ColorTween(begin: Colors.red, end: Colors.yellow),
          from:  const Duration(seconds: 0),
          to: const Duration(seconds: 2),
          tag: "color"
        ).addAnimatable(
          anim: new ColorTween(begin: Colors.yellow, end: Colors.blueAccent),
          from:  const Duration(seconds: 2),
          to: const Duration(seconds: 4),
          tag: "color",
          curve: Curves.easeOut
        ).addAnimatable(
          anim: new ColorTween(begin: Colors.blueAccent, end: Colors.pink),
          //  anim: new Tween<double>(begin: 200.0, end: 40.0),
          from:  const Duration(seconds: 5),
          to: const Duration(seconds: 6),
          tag: "color",
          curve: Curves.fastOutSlowIn
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
        title: new Text("Sequene"),
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
                height: 200.0,
                width: 200.0,
              ),
            );
          },
          animation: controller,
        ),
      ),
    );
  }

}
