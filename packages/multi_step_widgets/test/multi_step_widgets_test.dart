import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_step_flow/multi_step_flow.dart';
import 'package:multi_step_widgets/multi_step_widgets.dart';

void main() {
  group('DotsIndicator', () {
    testWidgets('renders correct number of dots', (tester) async {
      final steps = [
        FlowStep<TestData>(id: '1', data: TestData()),
        FlowStep<TestData>(id: '2', data: TestData()),
        FlowStep<TestData>(id: '3', data: TestData()),
      ];

      final bloc = FlowBloc<TestData>(steps: steps);

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: DotsIndicator<TestData>(bloc: bloc))),
      );

      expect(find.byType(AnimatedContainer), findsNWidgets(3));
      
      // Clean up
      bloc.close();
    });

    testWidgets('active dot has different color', (tester) async {
      final steps = [
        FlowStep<TestData>(id: '1', data: TestData()),
        FlowStep<TestData>(id: '2', data: TestData()),
      ];

      final bloc = FlowBloc<TestData>(steps: steps);
      // Move to the second step
      bloc.nextStep();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DotsIndicator<TestData>(
              bloc: bloc,
              theme: const StepIndicatorThemeData(
                activeColor: Colors.blue,
                inactiveColor: Colors.grey,
              ),
            ),
          ),
        ),
      );

      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final firstDot = containers.first;
      final activeDot = containers.last;

      final firstDecoration = firstDot.decoration as BoxDecoration;
      final activeDecoration = activeDot.decoration as BoxDecoration;

      expect(firstDecoration.color, Colors.grey);
      expect(activeDecoration.color, Colors.blue);
      
      // Clean up
      bloc.close();
    });
  });

  group('FlowLayout', () {
    testWidgets('renders step content and navigation bar', (tester) async {
      final steps = [
        FlowStep<TestData>(id: '1', data: TestData()),
      ];
      final bloc = FlowBloc<TestData>(steps: steps);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlowLayout<TestData>(
              bloc: bloc,
              stepBuilder: (context, step) => const Text('Step Content'),
            ),
          ),
        ),
      );

      expect(find.text('Step Content'), findsOneWidget);
      expect(find.byType(FlowNavigationBar<TestData>), findsOneWidget);
      
      // Clean up
      bloc.close();
    });

    testWidgets('supports custom indicator', (tester) async {
      final steps = [
        FlowStep<TestData>(id: '1', data: TestData()),
      ];
      final bloc = FlowBloc<TestData>(steps: steps);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlowLayout<TestData>(
              bloc: bloc,
              stepBuilder: (context, step) => const Text('Step Content'),
              indicatorBuilder: (_) => TextStepIndicator<TestData>(bloc: bloc),
            ),
          ),
        ),
      );

      expect(find.text('Step 1 of 1'), findsOneWidget);
      
      // Clean up
      bloc.close();
    });

    testWidgets('respects showNavigationBar option', (tester) async {
      final steps = [
        FlowStep<TestData>(id: '1', data: TestData()),
      ];
      final bloc = FlowBloc<TestData>(steps: steps);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlowLayout<TestData>(
              bloc: bloc,
              stepBuilder: (context, step) => const Text('Step Content'),
              showNavigationBar: false,
            ),
          ),
        ),
      );

      expect(find.byType(FlowNavigationBar<TestData>), findsNothing);
      
      // Clean up
      bloc.close();
    });
  });
}

/// Custom text-based step indicator for testing
class TextStepIndicator<T> extends StepIndicator<T> {
  const TextStepIndicator({
    Key? key,
    required this.bloc,
  }) : super(key: key, bloc: bloc);
  
  final FlowBloc<T> bloc;

  @override
  Widget buildIndicator(BuildContext context, FlowState<T> state) {
    return Text('Step ${state.currentStepIndex + 1} of ${bloc.steps.length}');
  }
}

/// Test data class for testing
class TestData {
  final String value;
  
  TestData({this.value = 'test'});
}
