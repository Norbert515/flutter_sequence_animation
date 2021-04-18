import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sequence_animation/flutter_sequence_animation.dart';

class StaggeredAnimationReplication extends StatefulWidget {
  @override
  _StaggeredAnimationReplicationState createState() => new _StaggeredAnimationReplicationState();
}

class _StaggeredAnimationReplicationState extends State<StaggeredAnimationReplication> with SingleTickerProviderStateMixin{

  static const opacityKey = SequenceAnimationTag<double>("opacity");
  static const widthKey = SequenceAnimationTag<double>("width");
  static const heightKey = SequenceAnimationTag<double>("height");
  static const paddingKey = SequenceAnimationTag<EdgeInsets>("padding");
  static const borderRadiusKey = SequenceAnimationTag<BorderRadius>("borderRadius");
  static const colorKey = SequenceAnimationTag<Color?>("color");

  late AnimationController controller;
  late SequenceAnimation sequenceAnimation;

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(vsync: this);

    sequenceAnimation = new SequenceAnimationBuilder()
     .addAnimatable(
        animatable: new Tween<double>(begin: 0.0, end: 1.0),
        from: Duration.zero,
        to: const Duration(milliseconds: 200),
        curve: Curves.ease,
        tag: opacityKey
    ).addAnimatable(
        animatable: new Tween<double>(begin: 50.0, end: 150.0),
        from: const Duration(milliseconds: 250),
        to: const Duration(milliseconds: 500),
        curve: Curves.ease,
        tag: widthKey
    ).addAnimatable(
        animatable: new Tween<double>(begin: 50.0, end: 150.0),
        from: const Duration(milliseconds: 500),
        to: const Duration(milliseconds: 750),
        curve: Curves.ease,
        tag: heightKey
    ).addAnimatable(
        animatable: new EdgeInsetsTween(begin: const EdgeInsets.only(bottom: 16.0), end: const EdgeInsets.only(bottom: 75.0),),
        from: const Duration(milliseconds: 500),
        to: const Duration(milliseconds: 750),
        curve: Curves.ease,
        tag: paddingKey
    ).addAnimatable(
        animatable: new BorderRadiusTween(begin: new BorderRadius.circular(4.0), end: new BorderRadius.circular(75.0),),
        from: const Duration(milliseconds: 750),
        to: const Duration(milliseconds: 1000),
        curve: Curves.ease,
        tag: borderRadiusKey
    ).addAnimatable(
        animatable: new ColorTween(begin: Colors.indigo[100], end: Colors.orange[400],),
        from: const Duration(milliseconds: 1000),
        to: const Duration(milliseconds: 1500),
        curve: Curves.ease,
        tag: colorKey
    ).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget _buildAnimation(BuildContext context, Widget? child) {
    return new Container(
      padding: sequenceAnimation.get(paddingKey).value,
      alignment: Alignment.bottomCenter,
      child: new Opacity(
        opacity: sequenceAnimation.get(opacityKey).value,
        child: new Container(
          width: sequenceAnimation.get(widthKey).value,
          height: sequenceAnimation.get(heightKey).value,
          decoration: new BoxDecoration(
            color: sequenceAnimation.get(colorKey).value,
            border: new Border.all(
              color: Colors.indigo[300]!,
              width: 3.0,
            ),
            borderRadius: sequenceAnimation.get(borderRadiusKey).value,
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
