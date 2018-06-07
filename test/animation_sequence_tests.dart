
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
    await tester.pumpWidget(buildAnimatableContainer(
      animation: controller,
      key: key,
      seq: sequenceAnimation,
      seqKey: seqKey
    ));

    
    expect(find.byKey(key), findsOneWidget);
    BoxDecoration decoration = tester.widget<Container>(find.byKey(key)).decoration;
    expect(decoration.color, Colors.red);


    controller.forward();
    await tester.pumpAndSettle();


    decoration = tester.widget<Container>(find.byKey(key)).decoration;
    expect(decoration.color, Colors.yellow);

  });
}


Widget buildAnimatableContainer({Animation animation, Key key, SequenceAnimation seq, Object seqKey}) {
  return new AnimatedBuilder(animation: animation, builder: (context, child) {
    return new Container(
      key: key,
      width: 200.0,
      height: 200.0,
      color: seq[seqKey].value,
    );
  });
}