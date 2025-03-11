import 'package:flutter/material.dart';
import 'package:multi_step_flow/multi_step_flow.dart';

import '../flow_builder.dart';
import '../indicators/base_indicator.dart';
import '../indicators/dots_indicator.dart';
import '../navigation/flow_navigation_bar.dart';
import '../theme/flow_theme.dart';
import '../theme/indicator_theme.dart';

/// A standard layout for multi-step flows
class FlowLayout extends StatelessWidget {
  const FlowLayout({
    super.key,
    required this.controller,
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
    this.pageController,
    this.scrollDirection = FlowScrollDirection.horizontal,
    this.customTransitionDuration,
    this.customTransitionCurve,
  });

  /// Controller for managing the flow state
  final FlowController controller;

  /// Builder for step content
  final StepBuilder stepBuilder;

  /// Theme for the flow
  final FlowTheme? theme;

  /// Builder for custom step indicator
  final StepIndicator Function(FlowState state)? indicatorBuilder;

  /// Builder for custom navigation bar
  final Widget Function(FlowState state)? navigationBarBuilder;

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
  final Widget Function(BuildContext, Widget, Animation<double>)? transitionBuilder;
  
  /// Optional custom page controller
  final PageController? pageController;
  
  /// Direction of flow scrolling
  final FlowScrollDirection scrollDirection;
  
  /// Custom transition duration
  final Duration? customTransitionDuration;
  
  /// Custom transition curve
  final Curve? customTransitionCurve;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FlowState>(
      stream: controller.stateStream,
      initialData: controller.currentState,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        
        return Column(
          children: [
            Expanded(
              child: FlowBuilder(
                controller: controller,
                stepBuilder: stepBuilder,
                theme: theme,
                indicator: indicatorBuilder?.call(state) ?? 
                         DotsIndicator(
                           state: state,
                           theme: theme?.stepIndicatorTheme ?? 
                                 const StepIndicatorThemeData(),
                         ),
                indicatorPosition: showIndicator ? IndicatorPosition.top : IndicatorPosition.none,
                physics: physics,
                contentPadding: contentPadding,
                indicatorPadding: indicatorPadding,
                transitionBuilder: transitionBuilder,
                pageController: pageController,
                scrollDirection: scrollDirection,
                customTransitionDuration: customTransitionDuration,
                customTransitionCurve: customTransitionCurve,
              ),
            ),
            if (showNavigationBar)
              navigationBarBuilder?.call(state) ??
              FlowNavigationBar(
                controller: controller,
              ),
          ],
        );
      },
    );
  }
}
