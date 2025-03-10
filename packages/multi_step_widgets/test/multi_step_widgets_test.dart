import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_step_flow/multi_step_flow.dart';
import 'package:multi_step_widgets/multi_step_widgets.dart';

void main() {
  group('DotsIndicator', () {
    testWidgets('renders correct number of dots', (tester) async {
      final steps = [
        TestStep(id: '1'),
        TestStep(id: '2'),
        TestStep(id: '3'),
      ];

      final state = FlowState(steps: steps);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DotsIndicator(state: state),
          ),
        ),
      );

      expect(find.byType(AnimatedContainer), findsNWidgets(3));
    });

    testWidgets('active dot has different color', (tester) async {
      final steps = [
        TestStep(id: '1'),
        TestStep(id: '2'),
      ];

      final state = FlowState(
        steps: steps,
        currentStepIndex: 1,
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DotsIndicator(
              state: state,
              theme: const StepIndicatorThemeData(
                activeColor: Colors.blue,
                inactiveColor: Colors.grey,
              ),
            ),
          ),
        ),
      );

      final containers = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));
      final firstDot = containers.first;
      final activeDot = containers.last;

      final firstDecoration = firstDot.decoration as BoxDecoration;
      final activeDecoration = activeDot.decoration as BoxDecoration;

      expect(firstDecoration.color, Colors.grey);
      expect(activeDecoration.color, Colors.blue);
    });
  });

  group('FlowLayout', () {
    testWidgets('renders step content and navigation bar', (tester) async {
      final steps = [TestStep(id: '1')];
      final controller = FlowController(steps: steps);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlowLayout(
              controller: controller,
              stepBuilder: (context, step) => const Text('Step Content'),
            ),
          ),
        ),
      );

      expect(find.text('Step Content'), findsOneWidget);
      expect(find.byType(FlowNavigationBar), findsOneWidget);
    });

    testWidgets('navigation bar shows correct buttons', (tester) async {
      final steps = [
        TestStep(id: '1'),
        TestStep(id: '2', isSkippable: true),
      ];
      
      final controller = FlowController(steps: steps);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlowLayout(
              controller: controller,
              stepBuilder: (context, step) => const Text('Step Content'),
            ),
          ),
        ),
      );

      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Skip'), findsNothing); // First step is not skippable

      // Go to second step
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget); // Second step is skippable
      expect(find.text('Complete'), findsOneWidget); // Last step
    });
  });
}

class TestStep extends FlowStep {
  TestStep({
    required String id,
    String? title,
    String? description,
    bool isSkippable = false,
    Duration? timeLimit,
  }) : super(
          id: id,
          title: title,
          description: description,
          isSkippable: isSkippable,
          timeLimit: timeLimit,
        );

  @override
  FlowStep copyWith({
    String? id,
    String? title,
    String? description,
    bool? isSkippable,
    Duration? timeLimit,
  }) {
    return TestStep(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isSkippable: isSkippable ?? this.isSkippable,
      timeLimit: timeLimit ?? this.timeLimit,
    );
  }
}
