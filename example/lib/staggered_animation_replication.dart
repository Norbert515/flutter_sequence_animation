import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sequence_animation/flutter_animation_sequence.dart';

class StaggeredAnimationReplication extends StatefulWidget {
  @override
  _StaggeredAnimationReplicationState createState() => new _StaggeredAnimationReplicationState();
}

class _StaggeredAnimationReplicationState extends State<StaggeredAnimationReplication> with SingleTickerProviderStateMixin{

  AnimationController controller;
  SequenceAnimation sequenceAnimation;

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(vsync: this);

    sequenceAnimation = new SequenceAnimationBuilder()
     .addAnimatable(
        anim: new Tween<double>(begin: 0.0, end: 1.0),
        from: Duration.zero,
        to: const Duration(milliseconds: 200),
        curve: Curves.ease,
        tag: "opacity"
    ).addAnimatable(
        anim: new Tween<double>(begin: 50.0, end: 150.0),
        from: const Duration(milliseconds: 250),
        to: const Duration(milliseconds: 500),
        curve: Curves.ease,
        tag: "width"
    ).addAnimatable(
        anim: new Tween<double>(begin: 50.0, end: 150.0),
        from: const Duration(milliseconds: 500),
        to: const Duration(milliseconds: 750),
        curve: Curves.ease,
        tag: "height"
    ).addAnimatable(
        anim: new EdgeInsetsTween(begin: const EdgeInsets.only(bottom: 16.0), end: const EdgeInsets.only(bottom: 75.0),),
        from: const Duration(milliseconds: 500),
        to: const Duration(milliseconds: 750),
        curve: Curves.ease,
        tag: "padding"
    ).addAnimatable(
        anim: new BorderRadiusTween(begin: new BorderRadius.circular(4.0), end: new BorderRadius.circular(75.0),),
        from: const Duration(milliseconds: 750),
        to: const Duration(milliseconds: 1000),
        curve: Curves.ease,
        tag: "borderRadius"
    ).addAnimatable(
        anim: new ColorTween(begin: Colors.indigo[100], end: Colors.orange[400],),
        from: const Duration(milliseconds: 1000),
        to: const Duration(milliseconds: 1500),
        curve: Curves.ease,
        tag: "color"
    ).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget _buildAnimation(BuildContext context, Widget child) {
    return new Container(
      padding: sequenceAnimation["padding"].value,
      alignment: Alignment.bottomCenter,
      child: new Opacity(
        opacity: sequenceAnimation["opacity"].value,
        child: new Container(
          width: sequenceAnimation["width"].value,
          height: sequenceAnimation["height"].value,
          decoration: new BoxDecoration(
            color: sequenceAnimation["color"].value,
            border: new Border.all(
              color: Colors.indigo[300],
              width: 3.0,
            ),
            borderRadius: sequenceAnimation["borderRadius"].value,
          ),
        ),
      ),
    );
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
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Staggered Animation"),
      ),
      body: new GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _playAnimation();
        },
        child: new Center(
          child: new Container(
            width: 300.0,
            height: 300.0,
            decoration: new BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              border: new Border.all(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            child: new AnimatedBuilder(
                animation: controller,
                builder: _buildAnimation
            ),
          ),
        ),
      ),
    );
  }
}
