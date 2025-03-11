import 'package:equatable/equatable.dart';
import 'flow_step.dart';

/// Represents the current status of a flow or step
enum FlowStatus {
  /// Initial state
  initial,

  /// Currently in progress
  inProgress,

  /// Validation in progress
  validating,

  /// Validation failed
  invalid,

  /// Successfully validated
  valid,

  /// Step or flow was skipped
  skipped,

  /// Step or flow completed successfully
  completed,

  /// An error occurred
  error,
}

/// Represents the current state of a multi-step flow
class FlowState extends Equatable {
  const FlowState({
    required this.steps,
    this.currentStepIndex = 0,
    this.status = FlowStatus.initial,
    this.error,
    this.validatedSteps = const {},
    this.skippedSteps = const {},
  });

  /// List of all steps in the flow
  final List<FlowStep> steps;

  /// Index of the current step
  final int currentStepIndex;

  /// Current status of the flow
  final FlowStatus status;

  /// Error message if status is [FlowStatus.error]
  final String? error;

  /// Set of step IDs that have been validated
  final Set<String> validatedSteps;

  /// Set of step IDs that have been skipped
  final Set<String> skippedSteps;

  /// The current step
  FlowStep? get currentStep =>
      currentStepIndex >= 0 && currentStepIndex < steps.length
          ? steps[currentStepIndex]
          : null;

  /// Whether there is a next step available
  bool get hasNext => currentStepIndex < steps.length - 1;

  /// Whether there is a previous step available
  bool get hasPrevious => currentStepIndex > 0;

  /// Whether the flow is complete
  bool get isComplete => status == FlowStatus.completed;

  /// Whether the current step is validated
  bool get isCurrentStepValidated =>
      currentStep != null && validatedSteps.contains(currentStep!.id);

  /// Whether the current step is skipped
  bool get isCurrentStepSkipped =>
      currentStep != null && skippedSteps.contains(currentStep!.id);

  /// Creates a copy of this state with the given fields replaced with new values
  FlowState copyWith({
    List<FlowStep>? steps,
    int? currentStepIndex,
    FlowStatus? status,
    String? error,
    Set<String>? validatedSteps,
    Set<String>? skippedSteps,
  }) {
    return FlowState(
      steps: steps ?? this.steps,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      status: status ?? this.status,
      error: error ?? this.error,
      validatedSteps: validatedSteps ?? this.validatedSteps,
      skippedSteps: skippedSteps ?? this.skippedSteps,
    );
  }

  @override
  List<Object?> get props => [
    steps,
    currentStepIndex,
    status,
    error,
    validatedSteps,
    skippedSteps,
  ];
}
