import 'package:multi_step_flow/multi_step_flow.dart';

void main() {
  // Create custom steps
  final steps = [
    RegistrationStep(
      id: 'personal_info',
      title: 'Personal Information',
      description: 'Enter your personal details',
    ),
    RegistrationStep(
      id: 'account_details',
      title: 'Account Details',
      description: 'Set up your account credentials',
    ),
    RegistrationStep(
      id: 'confirmation',
      title: 'Confirmation',
      description: 'Review and confirm your information',
      isSkippable: true,
    ),
  ];

  // Initialize flow controller with steps and configuration
  final controller = FlowController(
    steps: steps,
    configuration: const FlowConfiguration(
      autoAdvanceOnValidation: true,
      validateOnStepChange: true,
    ),
  );

  // Listen to flow state changes
  controller.stateStream.listen((state) {
    print('Current step: ${state.currentStep?.id}');
    print('Status: ${state.status}');
  });

  // Example usage
  controller.next(); // Move to next step
  controller.previous(); // Move to previous step
  controller.skip(); // Skip current step
  controller.validate(true); // Mark current step as valid
  controller.complete(); // Complete the flow

  // Cleanup
  controller.dispose();
}

/// Example custom step implementation
class RegistrationStep extends FlowStep {
  RegistrationStep({
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

  final _emailInput = const EmailInput.pure();
  final _passwordInput = const PasswordInput.pure();

  @override
  Future<bool> validate() async {
    final emailValid = _emailInput.validator(_emailInput.value) == null;
    final passwordValid = _passwordInput.validator(_passwordInput.value) == null;
    return emailValid && passwordValid;
  }

  @override
  Future<void> onEnter() async {
    print('Entering step $id');
  }

  @override
  Future<void> onExit() async {
    print('Exiting step $id');
  }

  @override
  Future<void> onSkip() async {
    print('Skipping step $id');
  }

  @override
  FlowStep copyWith({
    String? id,
    String? title,
    String? description,
    bool? isSkippable,
    Duration? timeLimit,
  }) {
    return RegistrationStep(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isSkippable: isSkippable ?? this.isSkippable,
      timeLimit: timeLimit ?? this.timeLimit,
    );
  }
}
