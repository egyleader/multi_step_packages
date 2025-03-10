import 'package:flutter/material.dart';
import 'package:multi_step_flow/multi_step_flow.dart';
import '../theme/indicator_theme.dart';

/// Abstract class for step indicators
abstract class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.state,
    this.onStepTapped,
    this.theme,
  });

  /// Current flow state
  final FlowState state;

  /// Callback when a step is tapped
  final void Function(int)? onStepTapped;

  /// Theme data for the indicator
  final StepIndicatorThemeData? theme;

  /// Whether the flow is complete
  bool get isComplete => state.status == FlowStatus.completed;

  /// Total number of steps
  int get stepCount => state.steps.length;

  /// Current step index
  int get currentStepIndex => state.currentStepIndex;

  /// Get the color for a step at the given index
  Color getStepColor(BuildContext context, int index) {
    final colors = theme?.resolve(Theme.of(context).colorScheme);
    if (colors == null) return Theme.of(context).primaryColor;

    if (index == currentStepIndex) {
      return colors.activeColor ?? Theme.of(context).primaryColor;
    }

    if (state.validatedSteps.contains(state.steps[index].id)) {
      return colors.completedColor ?? Theme.of(context).primaryColor;
    }

    if (state.skippedSteps.contains(state.steps[index].id)) {
      return colors.inactiveColor ?? Theme.of(context).disabledColor;
    }

    return colors.inactiveColor ?? Theme.of(context).disabledColor;
  }

  /// Get the label for a step at the given index
  String? getStepLabel(int index) {
    final step = state.steps[index];
    return step.title;
  }

  /// Get custom metadata for a step at the given index
  T? getStepMetadata<T>(int index, String key, [T? defaultValue]) {
    if (index < 0 || index >= state.steps.length) return defaultValue;
    return state.steps[index].getValue<T>(key, defaultValue);
  }

  /// Whether a step at the given index can be selected
  bool canSelectStep(int index) {
    if (index == currentStepIndex) return false;
    if (index < currentStepIndex) return true;
    
    // Can only move forward to next step if current step is validated or skipped
    if (index == currentStepIndex + 1) {
      return state.validatedSteps.contains(state.currentStep?.id) ||
             state.skippedSteps.contains(state.currentStep?.id);
    }

    return false;
  }

  /// Handle step tap
  void handleStepTap(int index) {
    if (canSelectStep(index)) {
      onStepTapped?.call(index);
    }
  }
}
