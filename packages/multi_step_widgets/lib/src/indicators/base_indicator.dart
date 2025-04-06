import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_step_flow/multi_step_flow.dart';
import '../theme/indicator_theme.dart';

/// Abstract class for step indicators with generic type support
abstract class StepIndicator<TStepData> extends StatelessWidget {
  const StepIndicator({
    super.key,
    this.bloc,
    this.onStepTapped,
    this.theme,
  });

  /// Optional FlowBloc instance
  /// If not provided, it will be obtained from the nearest BlocProvider
  final FlowBloc<TStepData>? bloc;

  /// Callback when a step is tapped
  final void Function(int)? onStepTapped;

  /// Theme data for the indicator
  final StepIndicatorThemeData? theme;

  @override
  Widget build(BuildContext context) {
    final flowBloc = bloc ?? BlocProvider.of<FlowBloc<TStepData>>(context);
    
    return BlocBuilder<FlowBloc<TStepData>, FlowState<TStepData>>(
      bloc: flowBloc,
      builder: (context, state) {
        return buildIndicator(context, state);
      },
    );
  }

  /// Abstract method to build the indicator UI
  Widget buildIndicator(BuildContext context, FlowState<TStepData> state);

  /// Whether the flow is complete
  bool isComplete(FlowState<TStepData> state) => 
      state.status == FlowStatus.completed;

  /// Total number of steps
  int getStepCount(FlowState<TStepData> state) => state.steps.length;

  /// Current step index
  int getCurrentStepIndex(FlowState<TStepData> state) => state.currentStepIndex;

  /// Get the color for a step at the given index
  Color getStepColor(BuildContext context, FlowState<TStepData> state, int index) {
    final colors = theme?.resolve(Theme.of(context).colorScheme);
    if (colors == null) return Theme.of(context).primaryColor;

    if (index == state.currentStepIndex) {
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
  String? getStepLabel(FlowState<TStepData> state, int index) {
    final step = state.steps[index];
    return step.title;
  }

  /// Whether a step at the given index can be selected
  bool canSelectStep(FlowState<TStepData> state, int index) {
    if (index == state.currentStepIndex) return false;
    if (index < state.currentStepIndex) return true;

    // Can only move forward to next step if current step is validated or skipped
    if (index == state.currentStepIndex + 1) {
      return state.validatedSteps.contains(state.currentStep.id) ||
          state.skippedSteps.contains(state.currentStep.id);
    }

    return false;
  }

  /// Handle step tap
  void handleStepTap(BuildContext context, FlowState<TStepData> state, int index) {
    if (canSelectStep(state, index)) {
      if (onStepTapped != null) {
        onStepTapped?.call(index);
      } else {
        // Use bloc to navigate directly if no custom handler provided
        final flowBloc = bloc ?? BlocProvider.of<FlowBloc<TStepData>>(context);
        flowBloc.goToStep(index);
      }
    }
  }
}
