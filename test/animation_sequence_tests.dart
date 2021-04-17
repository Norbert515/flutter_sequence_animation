
import 'package:flutter/material.dart';
import 'package:flutter_sequence_animation/flutter_sequence_animation.dart';
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

    const seqKey = const SequenceAnimationTag<Color>("color");
    SequenceAnimation sequenceAnimation = new SequenceAnimationBuilder()
        .addAnimatable(
        tag: seqKey,
        animatable: new ColorTween(begin: Colors.red, end: Colors.yellow),
        from: const Duration(seconds: 0),
        to: const Duration(seconds: 1))
        .animate(controller);



    expect(controller.duration, isNotNull);


    final key = new ValueKey("color");
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(new AnimatedBuilder(animation: controller, builder: (context, child) {
      return new Container(
        key: key,
        width: 200.0,
        height: 200.0,
        color: sequenceAnimation.get(seqKey).value,
      );
    }));

    
    expect(find.byKey(key), findsOneWidget);
    Color color = tester.widget<Container>(find.byKey(key)).color!;
    expect(color, Colors.red);


    controller.forward();
    await tester.pumpAndSettle();


    color = tester.widget<Container>(find.byKey(key)).color!;
    expect(color, Colors.yellow);

  });
//https://docs.flutter.io/flutter/package-test_test/throwsA.html

  testWidgets('Sequence animation with 4 colors', (WidgetTester tester) async {


    AnimationController controller = new AnimationController(vsync: const TestVSync());

    expect(controller.duration, isNull);

    const seqKey = const SequenceAnimationTag<Color>("color");
    SequenceAnimation sequenceAnimation = new SequenceAnimationBuilder()
        .addAnimatable(
        tag: seqKey,
        //animatable: Tween<double>(),
        animatable: new ColorTween(begin: Colors.red, end: Colors.blue),
        from: const Duration(seconds: 0),
        to: const Duration(seconds: 1))
        .addAnimatable(
        tag: seqKey,
        animatable: new ColorTween(begin: Colors.blue, end: Colors.green),
        from: const Duration(seconds: 1),
        to: const Duration(seconds: 2))
        .addAnimatable(
        tag: seqKey,
        animatable: new ColorTween(begin: Colors.green, end: Colors.deepPurple),
        from: const Duration(seconds: 2),
        to: const Duration(seconds: 3))
        .addAnimatable(
        tag: seqKey,
        animatable: new ColorTween(begin: Colors.deepPurple, end: Colors.brown),
        from: const Duration(seconds: 3),
        to: const Duration(seconds: 4))
        .animate(controller);



    expect(controller.duration, equals(const Duration(seconds: 4)));


    final key = new ValueKey("color");

    // Build our app and trigger a frame.
    await tester.pumpWidget(new AnimatedBuilder(animation: controller, builder: (context, child) {
      return new Container(
        key: key,
        width: 200.0,
        height: 200.0,
        color: sequenceAnimation.get(seqKey).value,
      );
    }));


    expect(find.byKey(key), findsOneWidget);
    Color color = tester.widget<Container>(find.byKey(key)).color!;
    expect(color, Colors.red);


    controller.forward();
    await tester.pumpAndSettle();


    color = tester.widget<Container>(find.byKey(key)).color!;
    expect(color, Colors.brown);

  });

  testWidgets('Sequence animation with 4 colors add after API', (WidgetTester tester) async {


    AnimationController controller = new AnimationController(vsync: const TestVSync());

    expect(controller.duration, isNull);

    const seqKey = const SequenceAnimationTag<Color>("color");
    SequenceAnimation sequenceAnimation = new SequenceAnimationBuilder()
        .addAnimatable(
        tag: seqKey,
        animatable: new ColorTween(begin: Colors.red, end: Colors.blue),
        from: const Duration(seconds: 0),
        to: const Duration(seconds: 1))
        .addAnimatableAfterLastOne(
        tag: seqKey,
        animatable: new ColorTween(begin: Colors.blue, end: Colors.green),
        duration: const Duration(seconds: 1))
        .addAnimatableAfterLastOne(
        tag: seqKey,
        animatable: new ColorTween(begin: Colors.green, end: Colors.deepPurple),
        duration: const Duration(seconds: 1))
        .addAnimatableAfterLastOne(
        tag: seqKey,
        animatable: new ColorTween(begin: Colors.deepPurple, end: Colors.brown),
        duration: const Duration(seconds: 1))
        .animate(controller);



    expect(controller.duration, equals(const Duration(seconds: 4)));


    final key = new ValueKey("color");

    // Build our app and trigger a frame.
    await tester.pumpWidget(new AnimatedBuilder(animation: controller, builder: (context, child) {
      return new Container(
        key: key,
        width: 200.0,
        height: 200.0,
        color: sequenceAnimation.get(seqKey).value,
      );
    }));


    expect(find.byKey(key), findsOneWidget);
    Color color = tester.widget<Container>(find.byKey(key)).color!;
    expect(color, Colors.red);


    controller.forward();
    await tester.pumpAndSettle();


    color = tester.widget<Container>(find.byKey(key)).color!;
    expect(color, Colors.brown);

  });


  testWidgets('Sequence with no animations', (WidgetTester tester) async {


    AnimationController controller = new AnimationController(vsync: const TestVSync());

    expect(controller.duration, isNull);

    SequenceAnimation sequenceAnimation = new SequenceAnimationBuilder().animate(controller);


    expect(controller.duration, equals(const Duration(seconds: 0)));

    try {
      sequenceAnimation.get(SequenceAnimationTag<bool>("doesntExit"));
    } catch(e) {
      expect(e,isAssertionError);
    }

    //These doesn't seem to work
 //   expect(tester.takeException(), isAssertionError);

  //  expect(sequenceAnimation["doesntExit"], throwsAssertionError);

  });


  testWidgets('Sequence animation with 4 colors', (WidgetTester tester) async {


    AnimationController controller = new AnimationController(vsync: const TestVSync());

    expect(controller.duration, isNull);

    const colorKey = const SequenceAnimationTag<Color>("color");
    const widthKey = const SequenceAnimationTag<double>("width");

    SequenceAnimation sequenceAnimation = new SequenceAnimationBuilder()
        .addAnimatable(
        tag: colorKey,
        animatable: new ColorTween(begin: Colors.red, end: Colors.blue),
        from: const Duration(seconds: 0),
        to: const Duration(seconds: 1))
        .addAnimatable(
        tag: widthKey,
        animatable: new Tween(begin: 50.0, end: 500.0),
        from: const Duration(seconds: 1),
        to: const Duration(seconds: 5))
        .addAnimatable(
        tag: colorKey,
        animatable: new ColorTween(begin: Colors.blue, end: Colors.green),
        from: const Duration(seconds: 1),
        to: const Duration(seconds: 2))
        .addAnimatable(
        tag: colorKey,
        animatable: new ColorTween(begin: Colors.green, end: Colors.deepPurple),
        from: const Duration(seconds: 2),
        to: const Duration(seconds: 3))
        .addAnimatable(
        tag: colorKey,
        animatable: new ColorTween(begin: Colors.deepPurple, end: Colors.brown),
        from: const Duration(seconds: 3),
        to: const Duration(seconds: 4))
        .animate(controller);



    expect(controller.duration, equals(const Duration(seconds: 5)));


    final key = new ValueKey("color");

    // Build our app and trigger a frame.
    await tester.pumpWidget(new AnimatedBuilder(animation: controller, builder: (context, child) {
      return new Container(
        key: key,
        width: sequenceAnimation.get(widthKey).value,
        height: 200.0,
        color: sequenceAnimation.get(colorKey).value,
      );
    }));


    expect(find.byKey(key), findsOneWidget);
    Color color = tester.widget<Container>(find.byKey(key)).color!;
    expect(color, Colors.red);

    BoxConstraints constraints = tester.widget<Container>(find.byKey(key)).constraints!;
    expect(constraints.minWidth, 50.0);
    expect(constraints.maxWidth, 50.0);


    controller.forward();
    await tester.pumpAndSettle();


    color = tester.widget<Container>(find.byKey(key)).color!;
    expect(color, Colors.brown);
    constraints = tester.widget<Container>(find.byKey(key)).constraints!;
    expect(constraints.minWidth, 500.0);
    expect(constraints.maxWidth, 500.0);

  });


  testWidgets('invalide sequence', (WidgetTester tester) async {


    AnimationController controller = new AnimationController(vsync: const TestVSync());

    const tag = const SequenceAnimationTag<Color>("s");

    try {
      new SequenceAnimationBuilder()
          .addAnimatable(
          tag: tag,
          animatable: new ColorTween(begin: Colors.red, end: Colors.yellow),
          from: const Duration(seconds: 0),
          to: const Duration(seconds: 2))
          .addAnimatable(
          tag: tag,
          animatable: new ColorTween(begin: Colors.red, end: Colors.yellow),
          from: const Duration(seconds: 1),
          to: const Duration(seconds: 2))
          .animate(controller);
    } catch (e) {
      expect(e, isAssertionError);
    }


    try {
      new SequenceAnimationBuilder()
          .addAnimatable(
          tag: tag,
          animatable: new ColorTween(begin: Colors.red, end: Colors.yellow),
          from: const Duration(seconds: 0),
          to: const Duration(milliseconds: 2000))
          .addAnimatable(
          tag: tag,
          animatable: new ColorTween(begin: Colors.red, end: Colors.yellow),
          from: const Duration(milliseconds: 1999),
          to: const Duration(milliseconds: 2001))
          .animate(controller);
    } catch (e) {
      expect(e, isAssertionError);
    }
  });


  testWidgets('Uses object key', (WidgetTester tester) async {

    AnimationController controller = new AnimationController(vsync: const TestVSync());

    const seqKey = const SequenceAnimationTag<Color>(false);

    SequenceAnimation sequenceAnimation = new SequenceAnimationBuilder()
        .addAnimatable(
        tag: seqKey,
        animatable: new ColorTween(begin: Colors.red, end: Colors.yellow),
        from: const Duration(seconds: 0),
        to: const Duration(seconds: 1))
        .animate(controller);



    expect(controller.duration, isNotNull);


    final key = new ValueKey("color");

    // Build our app and trigger a frame.
    await tester.pumpWidget(new AnimatedBuilder(animation: controller, builder: (context, child) {
      return new Container(
        key: key,
        width: 200.0,
        height: 200.0,
        color: sequenceAnimation.get(seqKey).value,
      );
    }));


    expect(find.byKey(key), findsOneWidget);
    Color color = tester.widget<Container>(find.byKey(key)).color!;
    expect(color, Colors.red);


    controller.forward();
    await tester.pumpAndSettle();


    color = tester.widget<Container>(find.byKey(key)).color!;
    expect(color, Colors.yellow);


  });
}


