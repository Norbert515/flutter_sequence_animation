
import 'package:flutter/material.dart';
import 'package:flutter_sequence_animation/animation_sequence.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('Sequence animation smoke test', (WidgetTester tester) async {
    
    
    AnimationController controller = new AnimationController(vsync: tester);

    expect(controller.duration, isNull);

    String seqKey = "color";
    SequenceAnimation sequenceAnimation = new SequenceAnimationBuilder()
        .addAnimatable(
        tag: seqKey,
        anim: new ColorTween(begin: Colors.red, end: Colors.yellow),
        from: const Duration(seconds: 0),
        to: const Duration(seconds: 1))
        .animate(controller);



    expect(controller.duration, isNotNull);


    ValueKey key = new ValueKey("color");
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(buildAnimatableContainer(
      animation: controller,
      key: key,
      seq: sequenceAnimation,
      seqKey: seqKey
    ));

    
    expect(find.byKey(key), findsOneWidget);
    BoxDecoration decoration = tester.widget<Container>(find.byKey(key)).decoration;
    expect(decoration.color, Colors.red);


    controller.forward(from: 0.5);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pump();

    decoration = tester.widget<Container>(find.byKey(key)).decoration;
    expect(decoration.color, Colors.yellow);

  });
}


Widget buildAnimatableContainer({Animation animation, Key key, SequenceAnimation seq, Object seqKey}) {
  return new AnimatedBuilder(animation: animation, builder: (context, child) {
    print(seq[seqKey].value);
    return new Container(
      key: key,
      width: 200.0,
      height: 200.0,
      color: seq[seqKey].value,
    );
  });
}