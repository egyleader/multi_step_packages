import 'dart:async';
import 'package:test/test.dart';
import 'package:multi_step_flow/multi_step_flow.dart';

/// A simplified testing approach for the FlowController
void main() {
  group('FlowController', () {
    late FlowController controller;
    late List<FlowStep> steps;

    setUp(() {
      steps = [
        TestStep(id: '1'),
        TestStep(id: '2', isSkippable: true),
        TestStep(id: '3'),
      ];
      controller = FlowController(steps: steps);
    });

    tearDown(() async {
      await controller.dispose();
    });

    test('initial state is correct', () {
      expect(controller.currentState.steps, steps);
      expect(controller.currentState.currentStepIndex, 0);
      expect(controller.currentState.status, FlowStatus.initial);
      expect(controller.currentState.validatedSteps, isEmpty);
      expect(controller.currentState.skippedSteps, isEmpty);
    });

    test('flowcontroller exposes correct convenience properties', () {
      // Check that helper getters work correctly
      expect(controller.currentStep, steps.first);
      expect(controller.hasNext, true);
      expect(controller.hasPrevious, false);
      expect(controller.isComplete, false);
      expect(controller.stepCount, 3);
      expect(controller.currentStepIndex, 0);
      expect(controller.isCurrentStepValidated, false);
      expect(controller.isCurrentStepSkipped, false);
    });

    test('complete() changes status to completed', () async {
      // Create a completer to wait for status change
      final completer = Completer<void>();
      
      // Listen for completed status
      final subscription = controller.stateStream.listen((state) {
        if (state.status == FlowStatus.completed && !completer.isCompleted) {
          completer.complete();
        }
      });
      
      // Trigger completion
      controller.complete();
      
      // Wait for completion with timeout
      await completer.future.timeout(
        const Duration(seconds: 1),
        onTimeout: () {
          // If we time out, we'll fail the test below
        },
      );
      
      await subscription.cancel();
      
      // Now verify the status
      expect(controller.currentState.status, FlowStatus.completed);
    });

    test('reset() restores initial state', () {
      // Because reset() is a synchronous operation we can test it directly
      controller.reset();
      
      // Verify reset state
      expect(controller.currentStepIndex, 0);
      expect(controller.currentState.validatedSteps, isEmpty);
      expect(controller.currentState.skippedSteps, isEmpty);
    });

    test('controller streams emit state changes', () async {
      // Setup stream listener
      final statesReceived = <FlowState>[];
      final completed = Completer<void>();
      
      final subscription = controller.stateStream.listen((state) {
        statesReceived.add(state);
        if (state.status == FlowStatus.completed && !completed.isCompleted) {
          completed.complete();
        }
      });

      // Trigger a state change
      controller.complete();
      
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
  });

  group('FlowStep', () {
    test('provides data access via getValue', () {
      final data = {'key': 'value', 'number': 42};
      final step = TestStep(id: 'test', data: data);

      expect(step.getValue<String>('key'), 'value');
      expect(step.getValue<int>('number'), 42);
      expect(step.getValue<bool>('nonexistent'), null);
      expect(step.getValue<bool>('nonexistent', true), true);
    });

    test('defaults to valid in validate method', () async {
      final step = TestStep(id: 'test');
      expect(await step.validate(), false); // Default is false in TestStep
      
      final validStep = TestStep(id: 'valid', shouldValidate: true);
      expect(await validStep.validate(), true);
    });

    test('lifecycle hooks can be overridden', () async {
      final events = <String>[];
      
      final step = TestStep(
        id: 'test',
        onEnterFn: () => events.add('enter'),
        onExitFn: () => events.add('exit'),
        onSkipFn: () => events.add('skip'),
      );
      
      await step.onEnter();
      await step.onExit();
      await step.onSkip();
      
      expect(events, ['enter', 'exit', 'skip']);
    });
    
    test('copyWith preserves all properties when none specified', () {
      final original = TestStep(
        id: 'test',
        title: 'Test Step',
        description: 'Description',
        isSkippable: true,
        timeLimit: Duration(seconds: 30),
        data: {'key': 'value'},
      );
      
      final copy = original.copyWith();
      
      expect(copy.id, original.id);
      expect(copy.title, original.title);
      expect(copy.description, original.description);
      expect(copy.isSkippable, original.isSkippable);
      expect(copy.timeLimit, original.timeLimit);
      expect(copy.data, original.data);
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
    Map<String, dynamic>? data,
    this.shouldValidate = false,
    this.onEnterFn,
    this.onExitFn,
    this.onSkipFn,
  }) : super(
          id: id,
          title: title ?? 'Test Step',
          description: description,
          isSkippable: isSkippable,
          timeLimit: timeLimit,
          data: data,
        );

  final bool shouldValidate;
  final Function? onEnterFn;
  final Function? onExitFn; 
  final Function? onSkipFn;

  @override
  Future<bool> validate() async => shouldValidate;

  @override
  Future<void> onEnter() async {
    if (onEnterFn != null) onEnterFn!();
  }

  @override
  Future<void> onExit() async {
    if (onExitFn != null) onExitFn!();
  }

  @override
  Future<void> onSkip() async {
    if (onSkipFn != null) onSkipFn!();
  }

  @override
  FlowStep copyWith({
    String? id,
    String? title,
    String? description,
    bool? isSkippable,
    Duration? timeLimit,
    Map<String, dynamic>? data,
  }) {
    return TestStep(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isSkippable: isSkippable ?? this.isSkippable,
      timeLimit: timeLimit ?? this.timeLimit,
      data: data ?? this.data,
      shouldValidate: shouldValidate,
      onEnterFn: onEnterFn,
      onExitFn: onExitFn,
      onSkipFn: onSkipFn,
    );
  }
}
