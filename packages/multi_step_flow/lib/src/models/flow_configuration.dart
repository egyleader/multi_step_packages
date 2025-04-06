/// Configuration options for a multi-step flow
class FlowConfiguration {
  /// Whether to allow navigation back to previous steps
  final bool allowBackNavigation;

  /// Whether to validate steps on transition
  final bool validateOnTransition;

  /// Whether to automatically advance to the next step when the current step is validated
  final bool autoAdvanceOnValidation;

  /// Whether to skip validation for optional steps
  final bool skipValidationForOptionalSteps;

  /// Whether to allow skipping the entire flow
  final bool allowSkipAll;

  /// Default duration for steps (used for timed steps)
  final Duration defaultStepDuration;

  /// Whether to persist state between app restarts
  final bool persistState;

  /// Storage key to use for persisting state
  final String? storageKey;

  /// Default step transition duration
  final Duration transitionDuration;

  /// Creates a new flow configuration with the given options
  const FlowConfiguration({
    this.allowBackNavigation = true,
    this.validateOnTransition = false,
    this.autoAdvanceOnValidation = false,
    this.skipValidationForOptionalSteps = true,
    this.allowSkipAll = false,
    this.defaultStepDuration = const Duration(minutes: 5),
    this.persistState = false,
    this.storageKey,
    this.transitionDuration = const Duration(milliseconds: 300),
  });

  /// Creates a copy of this configuration with the given fields replaced
  FlowConfiguration copyWith({
    bool? allowBackNavigation,
    bool? validateOnTransition,
    bool? autoAdvanceOnValidation,
    bool? skipValidationForOptionalSteps,
    bool? allowSkipAll,
    Duration? defaultStepDuration,
    bool? persistState,
    String? storageKey,
    Duration? transitionDuration,
  }) {
    return FlowConfiguration(
      allowBackNavigation: allowBackNavigation ?? this.allowBackNavigation,
      validateOnTransition: validateOnTransition ?? this.validateOnTransition,
      autoAdvanceOnValidation:
          autoAdvanceOnValidation ?? this.autoAdvanceOnValidation,
      skipValidationForOptionalSteps:
          skipValidationForOptionalSteps ?? this.skipValidationForOptionalSteps,
      allowSkipAll: allowSkipAll ?? this.allowSkipAll,
      defaultStepDuration: defaultStepDuration ?? this.defaultStepDuration,
      persistState: persistState ?? this.persistState,
      storageKey: storageKey ?? this.storageKey,
      transitionDuration: transitionDuration ?? this.transitionDuration,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'allowBackNavigation': allowBackNavigation,
      'validateOnTransition': validateOnTransition,
      'autoAdvanceOnValidation': autoAdvanceOnValidation,
      'skipValidationForOptionalSteps': skipValidationForOptionalSteps,
      'allowSkipAll': allowSkipAll,
      'defaultStepDuration': defaultStepDuration.inMilliseconds,
      'persistState': persistState,
      'storageKey': storageKey,
      'transitionDuration': transitionDuration.inMilliseconds,
    };
  }

  /// Create from JSON map
  factory FlowConfiguration.fromJson(Map<String, dynamic> json) {
    return FlowConfiguration(
      allowBackNavigation: json['allowBackNavigation'] as bool? ?? true,
      validateOnTransition: json['validateOnTransition'] as bool? ?? false,
      autoAdvanceOnValidation:
          json['autoAdvanceOnValidation'] as bool? ?? false,
      skipValidationForOptionalSteps:
          json['skipValidationForOptionalSteps'] as bool? ?? true,
      allowSkipAll: json['allowSkipAll'] as bool? ?? false,
      defaultStepDuration:
          json['defaultStepDuration'] != null
              ? Duration(milliseconds: json['defaultStepDuration'] as int)
              : const Duration(minutes: 5),
      persistState: json['persistState'] as bool? ?? false,
      storageKey: json['storageKey'] as String?,
      transitionDuration:
          json['transitionDuration'] != null
              ? Duration(milliseconds: json['transitionDuration'] as int)
              : const Duration(milliseconds: 300),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FlowConfiguration &&
        other.allowBackNavigation == allowBackNavigation &&
        other.validateOnTransition == validateOnTransition &&
        other.autoAdvanceOnValidation == autoAdvanceOnValidation &&
        other.skipValidationForOptionalSteps ==
            skipValidationForOptionalSteps &&
        other.allowSkipAll == allowSkipAll &&
        other.defaultStepDuration == defaultStepDuration &&
        other.persistState == persistState &&
        other.storageKey == storageKey &&
        other.transitionDuration == transitionDuration;
  }

  @override
  int get hashCode {
    return Object.hash(
      allowBackNavigation,
      validateOnTransition,
      autoAdvanceOnValidation,
      skipValidationForOptionalSteps,
      allowSkipAll,
      defaultStepDuration,
      persistState,
      storageKey,
      transitionDuration,
    );
  }
}
