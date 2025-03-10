import 'package:flutter/material.dart';
import 'package:multi_step_flow/multi_step_flow.dart';
import '../theme/flow_theme.dart';
import 'navigation_button.dart';

/// A navigation bar for multi-step flows
class FlowNavigationBar extends StatelessWidget {
  const FlowNavigationBar({
    super.key,
    required this.controller,
    this.nextLabel = const Text('Next'),
    this.previousLabel = const Text('Back'),
    this.skipLabel = const Text('Skip'),
    this.completeLabel = const Text('Complete'),
    this.showSkip = true,
    this.nextStyle = NavigationButtonStyle.filled,
    this.previousStyle = NavigationButtonStyle.text,
    this.skipStyle = NavigationButtonStyle.text,
    this.completeStyle = NavigationButtonStyle.filled,
  });

  /// Controller for managing the flow state
  final FlowController controller;

  /// Label for the next button
  final Widget nextLabel;

  /// Label for the previous button
  final Widget previousLabel;

  /// Label for the skip button
  final Widget skipLabel;

  /// Label for the complete button
  final Widget completeLabel;

  /// Whether to show the skip button
  final bool showSkip;

  /// Style for the next button
  final NavigationButtonStyle nextStyle;

  /// Style for the previous button
  final NavigationButtonStyle previousStyle;

  /// Style for the skip button
  final NavigationButtonStyle skipStyle;

  /// Style for the complete button
  final NavigationButtonStyle completeStyle;

  @override
  Widget build(BuildContext context) {
    final theme = FlowTheme.of(context);
    
    return StreamBuilder<FlowState>(
      stream: controller.stateStream,
      initialData: controller.currentState,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        final isLastStep = !state.hasNext;
        final currentStep = state.currentStep;
        final canSkip = currentStep?.isSkippable ?? false;
        final canAdvance = state.isCurrentStepValidated || 
                          state.isCurrentStepSkipped ||
                          currentStep == null;

        return Container(
          height: theme.navigationBarHeight,
          padding: theme.navigationBarPadding,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (state.hasPrevious) ...[
                NavigationButton(
                  onPressed: controller.previous,
                  style: previousStyle,
                  child: previousLabel,
                ),
                const SizedBox(width: 8),
              ],
              if (showSkip && canSkip && !isLastStep) ...[
                NavigationButton(
                  onPressed: controller.skip,
                  style: skipStyle,
                  child: skipLabel,
                ),
                const SizedBox(width: 8),
              ],
              const Spacer(),
              NavigationButton(
                onPressed: isLastStep ? controller.complete : controller.next,
                style: isLastStep ? completeStyle : nextStyle,
                enabled: canAdvance,
                child: isLastStep ? completeLabel : nextLabel,
              ),
            ],
          ),
        );
      },
    );
  }
}
