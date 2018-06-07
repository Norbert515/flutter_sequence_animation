
import 'package:flutter/material.dart';
import 'package:flutter_sequence_animation/animation_sequence.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/scheduler.dart';

/// A [TickerProvider] that creates a standalone ticker.
///
/// Useful in tests that create an [AnimationController] outside of the widget
/// tree.
class TestVSync implements TickerProvider {
  /// Creates a ticker provider that creates standalone tickers.
  const TestVSync();

  @override
  Ticker createTicker(TickerCallback onTick) => new Ticker(onTick);
}

void main() {
  testWidgets('Sequence animation smoke test', (WidgetTester tester) async {
    
    
    AnimationController controller = new AnimationController(vsync: const TestVSync());

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
    await tester.pumpWidget(new AnimatedBuilder(animation: controller, builder: (context, child) {
      return new Container(
        key: key,
        width: 200.0,
        height: 200.0,
        color: sequenceAnimation[seqKey].value,
      );
    }));

    
    expect(find.byKey(key), findsOneWidget);
    BoxDecoration decoration = tester.widget<Container>(find.byKey(key)).decoration;
    expect(decoration.color, Colors.red);


    controller.forward();
    await tester.pumpAndSettle();


    decoration = tester.widget<Container>(find.byKey(key)).decoration;
    expect(decoration.color, Colors.yellow);

  });


  testWidgets('Sequence animation with 4 colors', (WidgetTester tester) async {


    AnimationController controller = new AnimationController(vsync: const TestVSync());

    expect(controller.duration, isNull);

    String seqKey = "color";
    SequenceAnimation sequenceAnimation = new SequenceAnimationBuilder()
        .addAnimatable(
        tag: seqKey,
        anim: new ColorTween(begin: Colors.red, end: Colors.blue),
        from: const Duration(seconds: 0),
        to: const Duration(seconds: 1))
        .addAnimatable(
        tag: seqKey,
        anim: new ColorTween(begin: Colors.blue, end: Colors.green),
        from: const Duration(seconds: 1),
        to: const Duration(seconds: 2))
        .addAnimatable(
        tag: seqKey,
        anim: new ColorTween(begin: Colors.green, end: Colors.deepPurple),
        from: const Duration(seconds: 2),
        to: const Duration(seconds: 3))
        .addAnimatable(
        tag: seqKey,
        anim: new ColorTween(begin: Colors.deepPurple, end: Colors.brown),
        from: const Duration(seconds: 3),
        to: const Duration(seconds: 4))
        .animate(controller);



    expect(controller.duration, equals(const Duration(seconds: 4)));


    ValueKey key = new ValueKey("color");

    // Build our app and trigger a frame.
    await tester.pumpWidget(new AnimatedBuilder(animation: controller, builder: (context, child) {
      return new Container(
        key: key,
        width: 200.0,
        height: 200.0,
        color: sequenceAnimation[seqKey].value,
      );
    }));


    expect(find.byKey(key), findsOneWidget);
    BoxDecoration decoration = tester.widget<Container>(find.byKey(key)).decoration;
    expect(decoration.color, Colors.red);


    controller.forward();
    await tester.pumpAndSettle();


    decoration = tester.widget<Container>(find.byKey(key)).decoration;
    expect(decoration.color, Colors.brown);

  });



  testWidgets('Sequence with no animations', (WidgetTester tester) async {


    AnimationController controller = new AnimationController(vsync: const TestVSync());

    expect(controller.duration, isNull);

    SequenceAnimation sequenceAnimation = new SequenceAnimationBuilder().animate(controller);


    expect(controller.duration, equals(const Duration(seconds: 0)));

    expect(sequenceAnimation["doesntExit"], throwsAssertionError);

  });


  testWidgets('Sequence animation with 4 colors', (WidgetTester tester) async {


    AnimationController controller = new AnimationController(vsync: const TestVSync());

    expect(controller.duration, isNull);

    String colorKey = "color";
    String widthKey = "width";
    SequenceAnimation sequenceAnimation = new SequenceAnimationBuilder()
        .addAnimatable(
        tag: colorKey,
        anim: new ColorTween(begin: Colors.red, end: Colors.blue),
        from: const Duration(seconds: 0),
        to: const Duration(seconds: 1))
        .addAnimatable(
        tag: widthKey,
        anim: new Tween<double>(begin: 50.0, end: 500.0),
        from: const Duration(seconds: 1),
        to: const Duration(seconds: 5))
        .addAnimatable(
        tag: colorKey,
        anim: new ColorTween(begin: Colors.blue, end: Colors.green),
        from: const Duration(seconds: 1),
        to: const Duration(seconds: 2))
        .addAnimatable(
        tag: colorKey,
        anim: new ColorTween(begin: Colors.green, end: Colors.deepPurple),
        from: const Duration(seconds: 2),
        to: const Duration(seconds: 3))
        .addAnimatable(
        tag: colorKey,
        anim: new ColorTween(begin: Colors.deepPurple, end: Colors.brown),
        from: const Duration(seconds: 3),
        to: const Duration(seconds: 4))
        .animate(controller);



    expect(controller.duration, equals(const Duration(seconds: 5)));


    ValueKey key = new ValueKey("color");

    // Build our app and trigger a frame.
    await tester.pumpWidget(new AnimatedBuilder(animation: controller, builder: (context, child) {
      return new Container(
        key: key,
        width: sequenceAnimation[widthKey].value,
        height: 200.0,
        color: sequenceAnimation[colorKey].value,
      );
    }));


    expect(find.byKey(key), findsOneWidget);
    BoxDecoration decoration = tester.widget<Container>(find.byKey(key)).decoration;
    expect(decoration.color, Colors.red);

    BoxConstraints constraints = tester.widget<Container>(find.byKey(key)).constraints;
    expect(constraints.minWidth, 50.0);
    expect(constraints.maxWidth, 50.0);


    controller.forward();
    await tester.pumpAndSettle();


    decoration = tester.widget<Container>(find.byKey(key)).decoration;
    expect(decoration.color, Colors.brown);
    constraints = tester.widget<Container>(find.byKey(key)).constraints;
    expect(constraints.minWidth, 500.0);
    expect(constraints.maxWidth, 500.0);

  });


  testWidgets('invalide sequence', (WidgetTester tester) async {


    AnimationController controller = new AnimationController(vsync: const TestVSync());

    expect(new SequenceAnimationBuilder()
        .addAnimatable(
        tag: "s",
        anim: new ColorTween(begin: Colors.red, end: Colors.yellow),
        from: const Duration(seconds: 0),
        to: const Duration(seconds: 2))
        .addAnimatable(
        tag: "s",
        anim: new ColorTween(begin: Colors.red, end: Colors.yellow),
        from: const Duration(seconds: 1),
        to: const Duration(seconds: 2))
        .animate(controller), isAssertionError);


    expect(new SequenceAnimationBuilder()
        .addAnimatable(
        tag: "s",
        anim: new ColorTween(begin: Colors.red, end: Colors.yellow),
        from: const Duration(seconds: 0),
        to: const Duration(milliseconds: 2000))
        .addAnimatable(
        tag: "s",
        anim: new ColorTween(begin: Colors.red, end: Colors.yellow),
        from: const Duration(milliseconds: 1999),
        to: const Duration(milliseconds: 2001))
        .animate(controller), isAssertionError);
  });


  testWidgets('Same tag but different types', (WidgetTester tester) async {
    AnimationController controller = new AnimationController(vsync: const TestVSync());
    expect(new SequenceAnimationBuilder()
        .addAnimatable(
        tag: "s",
        anim: new ColorTween(begin: Colors.red, end: Colors.yellow),
        from: const Duration(seconds: 0),
        to: const Duration(seconds: 2))
        .addAnimatable(
        tag: "s",
        anim: new Tween<double>(begin: 0.0, end: 100.0),
        from: const Duration(seconds: 3),
        to: const Duration(seconds: 4))
        .animate(controller), isAssertionError);
  });
}


