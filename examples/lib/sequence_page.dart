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
    controller = new AnimationController(vsync: this, duration: const Duration(seconds: 5));

    sequenceAnimation = new SequenceAnimationBuilder()
      .addAnimatable(
        anim: new ColorTween(begin: Colors.red, end: Colors.yellow),
     //   anim: new Tween<double>(begin: 0.0, end: 200.0),
        from:  const Duration(seconds: 0),
        to: const Duration(seconds: 2),
        tag: "color")
      .addAnimatable(
        anim: new ColorTween(begin: Colors.yellow, end: Colors.blueAccent),
      //  anim: new Tween<double>(begin: 200.0, end: 40.0),
        from:  const Duration(seconds: 2),
        to: const Duration(seconds: 4),
        tag: "color",
        curve: Curves.elasticIn)
        .addAnimatable(
        anim: new ColorTween(begin: Colors.blueAccent, end: Colors.pink),
        //  anim: new Tween<double>(begin: 200.0, end: 40.0),
        from:  const Duration(seconds: 5),
        to: const Duration(seconds: 6),
        tag: "color",
        curve: Curves.fastOutSlowIn).animate(controller);


  }



  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Sequene"),
      ),
      body: new AnimatedBuilder(
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
      floatingActionButton: new FloatingActionButton(onPressed: (){
        if(forward) {
          controller.forward().then((_) {
            setState(() {
              forward = false;
            });
          });
        } else if(!forward){
          controller.reverse().then((_) {
            setState(() {
              forward = true;
            });
          });
        }
      }, child: new Icon(forward == null? Icons.not_interested: forward? Icons.arrow_forward: Icons.arrow_back),),
    );
  }

}
