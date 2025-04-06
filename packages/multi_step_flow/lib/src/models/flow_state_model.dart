import 'flow_status.dart';
import 'flow_step.dart';

/// Represents the current state of a multi-step flow
class FlowState<TStepData> {
  /// List of all steps in the flow
  final List<FlowStep<TStepData>> steps;

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

  /// Creates a new [FlowState] with the given properties
  const FlowState({
    required this.steps,
    this.currentStepIndex = 0,
    this.status = FlowStatus.initial,
    this.error,
    this.validatedSteps = const {},
    this.skippedSteps = const {},
  });

  /// The current step - this is non-nullable and will throw an error if the
  /// flow has no steps
  FlowStep<TStepData> get currentStep {
    if (steps.isEmpty) {
      throw StateError('Flow has no steps');
    }

    if (currentStepIndex < 0 || currentStepIndex >= steps.length) {
      return steps.first; // Fallback to first step
    }

    return steps[currentStepIndex];
  }

  /// Whether there is a next step available
  bool get hasNext => currentStepIndex < steps.length - 1;

  /// Whether there is a previous step available
  bool get hasPrevious => currentStepIndex > 0;

  /// Whether the flow is complete
  bool get isComplete => status == FlowStatus.completed;

  /// Whether the current step is validated
  bool get isCurrentStepValidated => validatedSteps.contains(currentStep.id);

  /// Whether the current step is skipped
  bool get isCurrentStepSkipped => skippedSteps.contains(currentStep.id);

  /// Creates a copy of the flow state with updated properties
  FlowState<TStepData> copyWith({
    List<FlowStep<TStepData>>? steps,
    int? currentStepIndex,
    FlowStatus? status,
    String? error,
    Set<String>? validatedSteps,
    Set<String>? skippedSteps,
  }) {
    return FlowState<TStepData>(
      steps: steps ?? this.steps,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      status: status ?? this.status,
      error: error ?? this.error,
      validatedSteps: validatedSteps ?? this.validatedSteps,
      skippedSteps: skippedSteps ?? this.skippedSteps,
    );
  }

  /// Converts the state to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'currentStepIndex': currentStepIndex,
      'status': status.toString(),
      'error': error,
      'validatedSteps': validatedSteps.toList(),
      'skippedSteps': skippedSteps.toList(),
    };
  }

  /// Creates a FlowState from a JSON map
  static FlowState<TStepData> fromJson<TStepData>(
    Map<String, dynamic> json,
    List<FlowStep<TStepData>> steps,
  ) {
    return FlowState<TStepData>(
      steps: steps,
      currentStepIndex: json['currentStepIndex'] as int? ?? 0,
      status: _parseStatus(json['status'] as String?),
      error: json['error'] as String?,
      validatedSteps: _parseStringList(json['validatedSteps']),
      skippedSteps: _parseStringList(json['skippedSteps']),
    );
  }

  /// Parse a FlowStatus from a string
  static FlowStatus _parseStatus(String? statusStr) {
    if (statusStr == null) return FlowStatus.initial;

    switch (statusStr) {
      case 'FlowStatus.initial':
        return FlowStatus.initial;
      case 'FlowStatus.inProgress':
        return FlowStatus.inProgress;
      case 'FlowStatus.valid':
        return FlowStatus.valid;
      case 'FlowStatus.invalid':
        return FlowStatus.invalid;
      case 'FlowStatus.error':
        return FlowStatus.error;
      case 'FlowStatus.completed':
        return FlowStatus.completed;
      default:
        return FlowStatus.initial;
    }
  }

  /// Parse a list of strings
  static Set<String> _parseStringList(dynamic value) {
    if (value == null) return {};

    if (value is List) {
      return value.whereType<String>().toSet();
    }

    return {};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FlowState<TStepData> &&
        other.currentStepIndex == currentStepIndex &&
        other.status == status &&
        other.error == error &&
        _setsEqual(other.validatedSteps, validatedSteps) &&
        _setsEqual(other.skippedSteps, skippedSteps);
  }

  @override
  int get hashCode {
    return Object.hash(
      currentStepIndex,
      status,
      error,
      Object.hashAll(validatedSteps),
      Object.hashAll(skippedSteps),
    );
  }

  bool _setsEqual(Set a, Set b) {
    if (a.length != b.length) return false;
    for (final element in a) {
      if (!b.contains(element)) return false;
    }
    return true;
  }
}
