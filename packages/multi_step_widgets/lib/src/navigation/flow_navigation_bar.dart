import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_step_flow/multi_step_flow.dart';
import '../theme/flow_theme.dart';
import 'navigation_button.dart';

/// A navigation bar for multi-step flows with generic type support
class FlowNavigationBar<TStepData> extends StatelessWidget {
  const FlowNavigationBar({
    super.key,
    this.bloc,
    this.nextLabel = const Text('Next'),
    this.previousLabel = const Text('Back'),
    this.skipLabel = const Text('Skip'),
    this.completeLabel = const Text('Complete'),
    this.showSkip = true,
    this.showNextButton = true,
    this.showPreviousButton = true,
    this.nextStyle = NavigationButtonStyle.filled,
    this.previousStyle = NavigationButtonStyle.text,
    this.skipStyle = NavigationButtonStyle.text,
    this.completeStyle = NavigationButtonStyle.filled,
    this.customLayout,
    this.padding,
    this.height,
    this.backgroundColor,
    this.border,
    this.nextButtonBuilder,
    this.previousButtonBuilder,
    this.skipButtonBuilder,
    this.completeButtonBuilder,
    this.shouldShowSkip,
  });

  /// FlowBloc instance
  /// If not provided, it will be obtained from the nearest BlocProvider
  final FlowBloc<TStepData>? bloc;

  /// Label for the next button
  final Widget nextLabel;

  /// Label for the previous button
  final Widget previousLabel;

  /// Label for the skip button
  final Widget skipLabel;

  /// Label for the complete button
  final Widget completeLabel;

  /// Whether to show the skip button (default: true)
  final bool showSkip;

  /// Whether to show the next/complete button (default: true)
  final bool showNextButton;

  /// Whether to show the previous button (default: true)
  final bool showPreviousButton;

  /// Style for the next button
  final NavigationButtonStyle nextStyle;

  /// Style for the previous button
  final NavigationButtonStyle previousStyle;

  /// Style for the skip button
  final NavigationButtonStyle skipStyle;

  /// Style for the complete button
  final NavigationButtonStyle completeStyle;

  /// Optional custom layout builder for complete control over the navigation bar layout
  /// When provided, this will override the default layout
  ///
  /// ```dart
  /// customLayout: (context, state, buttons) {
  ///   return Row(
  ///     children: [
  ///       buttons.previous!,
  ///       Spacer(),
  ///       buttons.next!,
  ///     ],
  ///   );
  /// }
  /// ```
  final Widget Function(
    BuildContext context,
    FlowState<TStepData> state,
    NavigationButtons buttons,
  )?
  customLayout;

  /// Optional custom padding for the navigation bar
  final EdgeInsetsGeometry? padding;

  /// Optional custom height for the navigation bar
  final double? height;

  /// Optional custom background color for the navigation bar
  final Color? backgroundColor;

  /// Optional custom border for the navigation bar
  final Border? border;

  /// Optional builder for the next button
  /// Allows complete customization of the next button
  final Widget Function(
    BuildContext context,
    VoidCallback? onPressed,
    bool enabled,
  )?
  nextButtonBuilder;

  /// Optional builder for the previous button
  /// Allows complete customization of the previous button
  final Widget Function(BuildContext context, VoidCallback? onPressed)?
  previousButtonBuilder;

  /// Optional builder for the skip button
  /// Allows complete customization of the skip button
  final Widget Function(BuildContext context, VoidCallback? onPressed)?
  skipButtonBuilder;

  /// Optional builder for the complete button
  /// Allows complete customization of the complete button
  final Widget Function(
    BuildContext context,
    VoidCallback? onPressed,
    bool enabled,
  )?
  completeButtonBuilder;

  /// Optional custom logic to determine whether to show the skip button
  /// When provided, this will override the default logic and the showSkip parameter
  final bool Function(FlowState<TStepData> state)? shouldShowSkip;

  @override
  Widget build(BuildContext context) {
    final theme = FlowTheme.of(context);
    final flowBloc = bloc ?? BlocProvider.of<FlowBloc<TStepData>>(context);

    return BlocBuilder<FlowBloc<TStepData>, FlowState<TStepData>>(
      bloc: flowBloc,
      builder: (context, state) {
        final isLastStep = !state.hasNext;
        final currentStep = state.currentStep;
        final canSkip = shouldShowSkip?.call(state) ?? currentStep.isSkippable;
        final canAdvance =
            state.validatedSteps.contains(currentStep.id) ||
            state.skippedSteps.contains(currentStep.id);

        // Create standard buttons based on configuration
        final nextBtn =
            showNextButton
                ? nextButtonBuilder?.call(
                      context,
                      isLastStep
                          ? () => flowBloc.completeFlow()
                          : () => flowBloc.nextStep(),
                      canAdvance,
                    ) ??
                    NavigationButton(
                      onPressed:
                          isLastStep
                              ? () => flowBloc.completeFlow()
                              : () => flowBloc.nextStep(),
                      style: isLastStep ? completeStyle : nextStyle,
                      enabled: canAdvance,
                      child: isLastStep ? completeLabel : nextLabel,
                    )
                : null;

        final prevBtn =
            (showPreviousButton && state.hasPrevious)
                ? previousButtonBuilder?.call(
                      context,
                      () => flowBloc.previousStep(),
                    ) ??
                    NavigationButton(
                      onPressed: () => flowBloc.previousStep(),
                      style: previousStyle,
                      child: previousLabel,
                    )
                : null;

        final skipBtn =
            (showSkip && canSkip && !isLastStep)
                ? skipButtonBuilder?.call(context, () => flowBloc.skipStep()) ??
                    NavigationButton(
                      onPressed: () => flowBloc.skipStep(),
                      style: skipStyle,
                      child: skipLabel,
                    )
                : null;

        // Create button collection for custom layout
        final buttons = NavigationButtons(
          next: nextBtn,
          previous: prevBtn,
          skip: skipBtn,
          complete: isLastStep ? nextBtn : null,
        );

        // Use custom layout if provided
        if (customLayout != null) {
          return Container(
            height: height ?? theme.navigationBarHeight,
            padding: padding ?? theme.navigationBarPadding,
            decoration: BoxDecoration(
              color:
                  backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
              border:
                  border ??
                  Border(
                    top: BorderSide(color: Theme.of(context).dividerColor),
                  ),
            ),
            child: customLayout!(context, state, buttons),
          );
        }

        // Default layout
        return Container(
          height: height ?? theme.navigationBarHeight,
          padding: padding ?? theme.navigationBarPadding,
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
            border:
                border ??
                Border(top: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (prevBtn != null) prevBtn,
                  if (prevBtn != null && skipBtn != null)
                    const SizedBox(width: 8),
                  if (skipBtn != null) skipBtn,
                ],
              ),
              if (nextBtn != null) nextBtn,
            ],
          ),
        );
      },
    );
  }
}

/// Container class for navigation buttons used in custom layouts
class NavigationButtons {
  /// The next button (or null if not shown)
  final Widget? next;

  /// The previous button (or null if not shown)
  final Widget? previous;

  /// The skip button (or null if not shown)
  final Widget? skip;

  /// The complete button (null unless on last step)
  final Widget? complete;

  const NavigationButtons({this.next, this.previous, this.skip, this.complete});
}
