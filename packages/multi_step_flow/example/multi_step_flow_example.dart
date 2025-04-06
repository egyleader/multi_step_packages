import 'package:multi_step_flow/multi_step_flow.dart';

void main() {
  // Create custom steps
  final steps = [
    FlowStep<RegistrationData>(
      id: 'personal_info',
      title: 'Personal Information',
      description: 'Enter your personal details',
      // Make the first step skippable so navigation is enabled
      isSkippable: true,
      data: RegistrationData(
        type: StepType.personal,
        fields: {'name': '', 'email': ''},
        isValid: true, // Pre-validate for navigation
      ),
    ),
    FlowStep<RegistrationData>(
      id: 'account_details',
      title: 'Account Details',
      description: 'Set up your account credentials',
      data: RegistrationData(
        type: StepType.account,
        fields: {'username': '', 'password': ''},
      ),
    ),
    FlowStep<RegistrationData>(
      id: 'confirmation',
      title: 'Confirmation',
      description: 'Review and confirm your information',
      isSkippable: true,
      data: RegistrationData(
        type: StepType.confirmation,
        fields: {
          'showTermsCheckbox': true,
          'requiredFields': ['name', 'email'],
          'termsAccepted': false,
        },
      ),
    ),
  ];

  // Initialize flow bloc with steps and configuration
  final bloc = FlowBloc<RegistrationData>(
    steps: steps,
    configuration: const FlowConfiguration(
      allowBackNavigation: true,
      autoAdvanceOnValidation: true,
    ),
  );
  
  // Ensure the first step is validated so navigation works
  bloc.validateStep(true);

  // Listen to flow state changes
  bloc.stream.listen((state) {
    print('Current step: ${state.currentStep.id}');
    print('Status: ${state.status}');
  });

  // Example usage of the bloc API
  performFlow(bloc);
}

Future<void> performFlow(FlowBloc<RegistrationData> bloc) async {
  try {
    // Move to next step
    bloc.nextStep();
    print('Moved to next step');

    // Validate the current step
    bloc.validateStep(true);
    print('Validated current step');

    // Skip a step if it's skippable
    if (bloc.state.currentStep.isSkippable) {
      bloc.skipStep();
      print('Skipped optional step');
    }

    // Complete the flow
    bloc.completeFlow();
    print('Flow completed');
  } catch (e) {
    print('Flow error: $e');
  } finally {
    // Cleanup
    bloc.close();
    print('Bloc closed');
  }
}

/// Simple enum to identify step type
enum StepType { personal, account, confirmation }

/// Example step data implementation without using freezed
class RegistrationData {
  final StepType type;
  final Map<String, dynamic> fields;
  final bool isValid;
  
  const RegistrationData({
    required this.type,
    required this.fields,
    this.isValid = false,
  });

  // Get a field value
  T? getValue<T>(String key) {
    if (fields.containsKey(key)) {
      final value = fields[key];
      if (value is T) return value;
    }
    return null;
  }
  
  // Create a copy with updated fields
  RegistrationData copyWith({
    StepType? type,
    Map<String, dynamic>? fields,
    bool? isValid,
  }) {
    return RegistrationData(
      type: type ?? this.type,
      fields: fields != null ? Map.from(fields) : Map.from(this.fields),
      isValid: isValid ?? this.isValid,
    );
  }
}

/// Helper for form validation
class EmailInput {
  const EmailInput.pure() : value = '';
  const EmailInput.dirty(this.value);

  final String value;

  String? validator(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!value.contains('@')) return 'Invalid email format';
    return null;
  }
}

/// Helper for password validation
class PasswordInput {
  const PasswordInput.pure() : value = '';
  const PasswordInput.dirty(this.value);

  final String value;

  String? validator(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }
}
