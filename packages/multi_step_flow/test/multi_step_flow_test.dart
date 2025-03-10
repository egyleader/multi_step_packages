limport 'package:test/test.dart';
import 'package:multi_step_flow/multi_step_flow.dart';

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

    tearDown(() {
      controller.dispose();
    });

    test('initial state is correct', () {
      expect(controller.currentState.steps, steps);
      expect(controller.currentState.currentStepIndex, 0);
      expect(controller.currentState.status, FlowStatus.initial);
      expect(controller.currentState.validatedSteps, []);
      expect(controller.currentState.skippedSteps, []);
    });

    test('next() moves to next step', () async {
      controller.next();
      expect(controller.currentState.currentStepIndex, 1);
      expect(controller.currentState.status, FlowStatus.inProgress);
    });

    test('previous() moves to previous step', () async {
      controller.next();
      controller.previous();
      expect(controller.currentState.currentStepIndex, 0);
    });

    test('skip() works only on skippable steps', () async {
      // First step is not skippable
      controller.skip();
      expect(controller.currentState.skippedSteps, []);
      expect(controller.currentState.currentStepIndex, 0);

      // Second step is skippable
      controller.next();
      controller.skip();
      expect(controller.currentState.skippedSteps.contains('2'), true);
      expect(controller.currentState.currentStepIndex, 2);
    });

    test('complete() changes status to completed', () async {
      controller.complete();
      expect(controller.currentState.status, FlowStatus.completed);
    });

    test('validates steps correctly', () async {
      final validatingStep = TestStep(
        id: 'validating',
        shouldValidate: true,
      );
      
      controller = FlowController(
        steps: [validatingStep],
        configuration: const FlowConfiguration(
          validateOnStepChange: true,
        ),
      );

      expect(controller.currentState.validatedSteps, []);

      controller.validate(true);
      expect(
        controller.currentState.validatedSteps.contains(validatingStep.id),
        true,
      );
    });

    test('respects configuration settings', () async {
      controller = FlowController(
        steps: steps,
        configuration: const FlowConfiguration(
          validateOnStepChange: true,
          autoAdvanceOnValidation: true,
        ),
      );

      controller.validate(true);
      expect(controller.currentState.currentStepIndex, 1);
    });

    test('goToStep() changes current step', () async {
      controller.goToStep(2);
      expect(controller.currentState.currentStepIndex, 2);
    });

    test('reset() restores initial state', () async {
      controller.next();
      controller.validate(true);
      controller.skip();

      controller.reset();

      expect(controller.currentState.currentStepIndex, 0);
      expect(controller.currentState.validatedSteps, []);
      expect(controller.currentState.skippedSteps, []);
      expect(controller.currentState.status, FlowStatus.inProgress);
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
    this.shouldValidate = false,
  }) : super(
          id: id,
          title: title,
          description: description,
          isSkippable: isSkippable,
          timeLimit: timeLimit,
        );

  final bool shouldValidate;

  @override
  Future<bool> validate() async => shouldValidate;

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
      shouldValidate: shouldValidate,
    );
  }
}
