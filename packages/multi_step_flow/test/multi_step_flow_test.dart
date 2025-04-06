import 'dart:async';
import 'package:test/test.dart';
import 'package:multi_step_flow/multi_step_flow.dart';

/// Tests for the new FlowBloc implementation
void main() {
  group('FlowBloc', () {
    late FlowBloc<TestData> bloc;
    late List<FlowStep<TestData>> steps;

    setUp(() {
      steps = [
        FlowStep<TestData>(
          id: '1', 
          data: const TestData(value: 'test1'),
        ),
        FlowStep<TestData>(
          id: '2', 
          isSkippable: true, 
          data: const TestData(value: 'test2'),
        ),
        FlowStep<TestData>(
          id: '3', 
          data: const TestData(value: 'test3'),
        ),
      ];
      bloc = FlowBloc<TestData>(steps: steps);
    });

    tearDown(() async {
      await bloc.close();
    });

    test('initial state is correct', () {
      expect(bloc.state.steps, steps);
      expect(bloc.state.currentStepIndex, 0);
      expect(bloc.state.status, FlowStatus.initial);
      expect(bloc.state.validatedSteps, isEmpty);
      expect(bloc.state.skippedSteps, isEmpty);
    });

    test('bloc exposes correct state properties', () {
      // Check that state properties are accessible
      expect(bloc.state.currentStep, steps.first);
      expect(bloc.state.hasNext, true);
      expect(bloc.state.hasPrevious, false);
      expect(bloc.state.isComplete, false);
      expect(bloc.steps.length, 3);
      expect(bloc.state.currentStepIndex, 0);
      expect(bloc.state.validatedSteps.contains(steps.first.id), false);
      expect(bloc.state.skippedSteps.contains(steps.first.id), false);
    });

    test('completeFlow() changes status to completed', () async {
      // Create a completer to wait for status change
      final completer = Completer<void>();

      // Listen for completed status
      final subscription = bloc.stream.listen((state) {
        if (state.status == FlowStatus.completed && !completer.isCompleted) {
          completer.complete();
        }
      });

      // Trigger completion
      bloc.completeFlow();

      // Wait for completion with timeout
      await completer.future.timeout(
        const Duration(seconds: 1),
        onTimeout: () {
          // If we time out, we'll fail the test below
        },
      );

      await subscription.cancel();

      // Now verify the status
      expect(bloc.state.status, FlowStatus.completed);
    });

    test('resetFlow() restores initial state', () async {
      // First move to next step and validate it
      bloc.nextStep();
      bloc.validateStep(true);
      
      // Then reset
      bloc.resetFlow();

      // Wait a bit for the state to update
      await Future.delayed(Duration.zero);

      // Verify reset state
      expect(bloc.state.currentStepIndex, 0);
      expect(bloc.state.validatedSteps, isEmpty);
      expect(bloc.state.skippedSteps, isEmpty);
    });

    test('bloc stream emits state changes', () async {
      // Setup stream listener
      final statesReceived = <FlowState<TestData>>[];
      final completed = Completer<void>();

      final subscription = bloc.stream.listen((state) {
        statesReceived.add(state);
        if (state.status == FlowStatus.completed && !completed.isCompleted) {
          completed.complete();
        }
      });

      // Trigger a state change
      bloc.completeFlow();

      // Wait for state change with timeout
      await completed.future.timeout(
        const Duration(seconds: 1),
        onTimeout: () {
          // This will fail the test if it times out
        },
      );

      // Should have received state updates
      expect(statesReceived.isNotEmpty, true);
      expect(statesReceived.last.status, FlowStatus.completed);

      // Clean up
      await subscription.cancel();
    });
    
    test('navigation methods change current step index', () async {
      // Initially at index 0
      expect(bloc.state.currentStepIndex, 0);
      
      // Move to step 1
      bloc.nextStep();
      expect(bloc.state.currentStepIndex, 1);
      
      // Move back to step 0
      bloc.previousStep();
      expect(bloc.state.currentStepIndex, 0);
      
      // Skip to step 1 (which is skippable)
      bloc.goToStep(1); // Using index 1 for the second step
      bloc.skipStep();
      
      // Should now be at step 2 (index 2)
      expect(bloc.state.currentStepIndex, 2);
      expect(bloc.state.skippedSteps.contains('2'), true);
    });
  });

  group('FlowStep', () {
    test('provides data access', () {
      final step = FlowStep<TestData>(
        id: 'test',
        data: const TestData(value: 'test-value', number: 42),
      );

      expect(step.data.value, 'test-value');
      expect(step.data.number, 42);
      expect(step.data.flag, false); // Default value
    });

    test('step data can be updated', () {
      final original = FlowStep<TestData>(
        id: 'test',
        data: const TestData(value: 'original'),
      );
      
      final updated = original.copyWith(
        data: const TestData(value: 'updated'),
      );
      
      expect(updated.id, original.id); // Same id
      expect(updated.data.value, 'updated'); // Updated value
    });

    test('step properties can be updated with copyWith', () {
      final original = FlowStep<TestData>(
        id: 'test',
        title: 'Original Title',
        description: 'Original Description',
        isSkippable: false,
        data: const TestData(value: 'original'),
      );
      
      final updated = original.copyWith(
        title: 'New Title',
        description: 'New Description',
        isSkippable: true,
      );
      
      expect(updated.id, original.id); // ID remains the same
      expect(updated.title, 'New Title');
      expect(updated.description, 'New Description');
      expect(updated.isSkippable, true);
      expect(updated.data.value, 'original'); // Data unchanged
    });
  });
}

/// Test data class for use in tests
class TestData {
  final String value;
  final int? number;
  final bool flag;
  
  const TestData({
    required this.value,
    this.number,
    this.flag = false,
  });
  
  TestData copyWith({
    String? value,
    int? number,
    bool? flag,
  }) {
    return TestData(
      value: value ?? this.value,
      number: number ?? this.number,
      flag: flag ?? this.flag,
    );
  }
}
