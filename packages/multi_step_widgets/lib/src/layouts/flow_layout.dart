import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_step_flow/multi_step_flow.dart';

import '../flow_builder.dart';
import '../indicators/base_indicator.dart';
import '../indicators/dots_indicator.dart';
import '../navigation/flow_navigation_bar.dart';
import '../theme/flow_theme.dart';
import '../theme/indicator_theme.dart';

/// Scroll direction for flow content
enum FlowScrollDirection {
  /// Horizontal scrolling
  horizontal,
  
  /// Vertical scrolling
  vertical,
  
  /// No scrolling
  none
}

/// Position of the step indicator
enum IndicatorPosition {
  /// Indicator at the top of the layout
  top,
  
  /// Indicator at the bottom of the layout
  bottom,
  
  /// No indicator shown
  none
}

/// A standard layout for multi-step flows
class FlowLayout<TStepData> extends StatelessWidget {
  const FlowLayout({
    super.key,
    required this.bloc,
    required this.stepBuilder,
    this.theme,
    this.indicatorBuilder,
    this.navigationBarBuilder,
    this.showIndicator = true,
    this.showNavigationBar = true,
    this.physics = const AlwaysScrollableScrollPhysics(),
    this.contentPadding = const EdgeInsets.all(16.0),
    this.indicatorPadding = const EdgeInsets.all(16.0),
    this.transitionBuilder,
    this.scrollDirection = FlowScrollDirection.horizontal,
    this.customTransitionDuration,
    this.customTransitionCurve,
    this.indicatorPosition = IndicatorPosition.top,
  });

  /// FlowBloc for managing the flow state
  final FlowBloc<TStepData> bloc;

  /// Builder for step content
  final Widget Function(BuildContext, FlowStep<TStepData>) stepBuilder;

  /// Theme for the flow
  final FlowTheme? theme;

  /// Builder for custom step indicator
  final StepIndicator<TStepData> Function(FlowState<TStepData> state)? indicatorBuilder;

  /// Builder for custom navigation bar
  final Widget Function(FlowState<TStepData> state)? navigationBarBuilder;

  /// Whether to show the step indicator
  final bool showIndicator;

  /// Whether to show the navigation bar
  final bool showNavigationBar;

  /// Scroll physics for the step content
  final ScrollPhysics physics;

  /// Padding around the step content
  final EdgeInsets contentPadding;

  /// Padding around the indicator
  final EdgeInsets indicatorPadding;

  /// Custom transition builder
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;

  /// Direction of flow scrolling
  final FlowScrollDirection scrollDirection;

  /// Position of the indicator (top or bottom)
  final IndicatorPosition indicatorPosition;

  /// Custom transition duration
  final Duration? customTransitionDuration;

  /// Custom transition curve
  final Curve? customTransitionCurve;

  @override
  Widget build(BuildContext context) {
    return FlowBlocProvider<TStepData>(
      bloc: bloc,
      child: BlocBuilder<FlowBloc<TStepData>, FlowState<TStepData>>(
        bloc: bloc,
        builder: (context, state) {
          final children = <Widget>[];

          // Add top indicator if needed
          if (showIndicator && indicatorPosition == IndicatorPosition.top) {
            children.add(
              Padding(
                padding: indicatorPadding,
                child: indicatorBuilder?.call(state) ??
                      DotsIndicator<TStepData>(bloc: bloc),
              ),
            );
          }

          // Main content
          children.add(
            Expanded(
              child: FlowBuilder<TStepData>(
                bloc: bloc,
                stepBuilder: stepBuilder,
                transitionDuration: customTransitionDuration ?? 
                    const Duration(milliseconds: 300),
                transitionCurve: customTransitionCurve ?? Curves.easeInOut,
                animateTransitions: scrollDirection == FlowScrollDirection.none,
                transitionBuilder: transitionBuilder,
              ),
            ),
          );

          // Add bottom indicator if needed
          if (showIndicator && indicatorPosition == IndicatorPosition.bottom) {
            children.add(
              Padding(
                padding: indicatorPadding,
                child: indicatorBuilder?.call(state) ??
                      DotsIndicator<TStepData>(bloc: bloc),
              ),
            );
          }

          // Navigation bar
          if (showNavigationBar) {
            children.add(
              navigationBarBuilder?.call(state) ??
                  FlowNavigationBar<TStepData>(bloc: bloc)
            );
          }

          return Column(children: children);
        },
      ),
    );
  }
}
