import 'package:meta/meta.dart';

/// Configuration options for a multi-step flow
@immutable
class FlowConfiguration {
  const FlowConfiguration({
    this.allowBackNavigation = true,
    this.autoAdvanceOnValidation = false,
    this.validateOnStepChange = true,
    this.showStepIndicator = true,
    this.preserveState = true,
    this.defaultStepDuration,
    this.onFlowComplete,
  });

  /// Whether to allow backward navigation between steps
  final bool allowBackNavigation;

  /// Whether to automatically advance to next step after successful validation
  final bool autoAdvanceOnValidation;

  /// Whether to validate the current step when changing steps
  final bool validateOnStepChange;

  /// Whether to show the step indicator
  final bool showStepIndicator;

  /// Whether to preserve step state when navigating
  final bool preserveState;

  /// Default duration for timed steps
  final Duration? defaultStepDuration;

  /// Callback when flow is completed
  final Future<void> Function()? onFlowComplete;

  /// Creates a copy of this configuration with the given fields replaced with new values
  FlowConfiguration copyWith({
    bool? allowBackNavigation,
    bool? autoAdvanceOnValidation,
    bool? validateOnStepChange,
    bool? showStepIndicator,
    bool? preserveState,
    Duration? defaultStepDuration,
    Future<void> Function()? onFlowComplete,
  }) {
    return FlowConfiguration(
      allowBackNavigation: allowBackNavigation ?? this.allowBackNavigation,
      autoAdvanceOnValidation:
          autoAdvanceOnValidation ?? this.autoAdvanceOnValidation,
      validateOnStepChange: validateOnStepChange ?? this.validateOnStepChange,
      showStepIndicator: showStepIndicator ?? this.showStepIndicator,
      preserveState: preserveState ?? this.preserveState,
      defaultStepDuration: defaultStepDuration ?? this.defaultStepDuration,
      onFlowComplete: onFlowComplete ?? this.onFlowComplete,
    );
  }
}
