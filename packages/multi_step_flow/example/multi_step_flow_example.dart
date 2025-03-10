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
      // Example of using step data
      data: {
        'showTermsCheckbox': true,
        'requiredFields': ['name', 'email']
      }
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

  // Listen to flow errors
  controller.errorStream.listen((error) {
    print('Error: $error');
  });

  // Example usage of the async API
  performFlow(controller);
}

Future<void> performFlow(FlowController controller) async {
  try {
    // Move to next step with async API
    await controller.next();
    print('Moved to next step');
    
    // Validate the current step
    await controller.validate(true);
    print('Validated current step');
    
    // Skip a step if it's skippable
    if (controller.currentStep!.isSkippable) {
      await controller.skip();
      print('Skipped optional step');
    }
    
    // Complete the flow
    await controller.complete();
    print('Flow completed');
  } catch (e) {
    print('Flow error: $e');
  } finally {
    // Cleanup
    await controller.dispose();
    print('Controller disposed');
  }
}

/// Example custom step implementation
class RegistrationStep extends FlowStep {
  RegistrationStep({
    required String id,
    String? title,
    String? description,
    bool isSkippable = false,
    Duration? timeLimit,
    Map<String, dynamic>? data,
  }) : super(
          id: id,
          title: title,
          description: description,
          isSkippable: isSkippable,
          timeLimit: timeLimit,
          data: data,
        );

  final _emailInput = const EmailInput.pure();
  final _passwordInput = const PasswordInput.pure();

  @override
  Future<bool> validate() async {
    // Example of accessing step data to determine validation rules
    final requiredFields = getValue<List<dynamic>>('requiredFields') ?? [];
    
    final emailValid = _emailInput.validator(_emailInput.value) == null;
    final passwordValid = _passwordInput.validator(_passwordInput.value) == null;
    
    // If no required fields specified, use default validation
    if (requiredFields.isEmpty) {
      return emailValid && passwordValid;
    }
    
    // Otherwise, validate only required fields
    bool isValid = true;
    if (requiredFields.contains('email')) {
      isValid = isValid && emailValid;
    }
    if (requiredFields.contains('password')) {
      isValid = isValid && passwordValid;
    }
    
    return isValid;
  }

  @override
  Future<void> onEnter() async {
    print('Entering step $id');
    // Example of analytics tracking
    if (data != null && data!.containsKey('trackingEvent')) {
      print('Tracking event: ${data!['trackingEvent']}');
    }
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
    Map<String, dynamic>? data,
  }) {
    return RegistrationStep(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isSkippable: isSkippable ?? this.isSkippable,
      timeLimit: timeLimit ?? this.timeLimit,
      data: data ?? this.data,
    );
  }
}
