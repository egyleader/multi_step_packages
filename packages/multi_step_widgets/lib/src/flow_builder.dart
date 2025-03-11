import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:multi_step_flow/multi_step_flow.dart';

import 'indicators/base_indicator.dart';
import 'theme/flow_theme.dart';

/// Signature for building step content
typedef StepBuilder = Widget Function(BuildContext context, FlowStep step);

/// Defines the position of the step indicator
enum IndicatorPosition {
  /// Place the indicator above the content
  top,
  
  /// Place the indicator below the content
  bottom,
  
  /// Don't show the indicator
  none,
}

/// Defines the scroll direction for the flow
enum FlowScrollDirection {
  /// Horizontal scrolling between steps
  horizontal,
  
  /// Vertical scrolling between steps
  vertical,
}

/// A widget that builds a multi-step flow interface
class FlowBuilder extends StatefulWidget {
  const FlowBuilder({
    super.key,
    required this.controller,
    required this.stepBuilder,
    this.indicator,
    this.theme,
    this.indicatorPosition = IndicatorPosition.top,
    this.physics = const AlwaysScrollableScrollPhysics(),
    this.contentPadding = const EdgeInsets.all(16.0),
    this.indicatorPadding = const EdgeInsets.all(16.0),
    this.transitionBuilder,
    this.pageController,
    this.scrollDirection = FlowScrollDirection.horizontal,
    this.onPageChanged,
    this.viewportFraction = 1.0,
    this.customTransitionDuration,
    this.customTransitionCurve,
    this.maintainState = false,
    this.pageSnapping = true,
    this.reverse = false,
    this.customLayout,
    this.dragStartBehavior = DragStartBehavior.start,
    this.clipBehavior = Clip.hardEdge,
    this.shouldHandlePage = true,
    this.keepPage = true,
    this.restorationId,
  });

  /// Controller for managing the flow state
  final FlowController controller;

  /// Builder for step content
  final StepBuilder stepBuilder;

  /// Theme for the flow
  final FlowTheme? theme;

  /// Step indicator widget
  final StepIndicator? indicator;

  /// Position of the step indicator
  final IndicatorPosition indicatorPosition;

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
  
  /// Callback when the page changes
  final ValueChanged<int>? onPageChanged;
  
  /// The fraction of the viewport that each page should occupy
  final double viewportFraction;
  
  /// Custom transition duration
  final Duration? customTransitionDuration;
  
  /// Custom transition curve
  final Curve? customTransitionCurve;
  
  /// Whether to maintain state for all steps, even when not visible
  final bool maintainState;
  
  /// Whether the page view should snap to page boundaries
  final bool pageSnapping;
  
  /// Whether to reverse the scroll direction
  final bool reverse;
  
  /// Custom layout builder - gives full control over the layout
  final Widget Function(BuildContext context, Widget indicator, Widget pager)? customLayout;
  
  /// Controls how drag start behavior is handled
  final DragStartBehavior dragStartBehavior;
  
  /// How content should be clipped
  final Clip clipBehavior;
  
  /// Whether the FlowBuilder should handle page changes itself
  final bool shouldHandlePage;

  /// Whether to save and restore page state
  final bool keepPage;

  /// Restoration ID for saving and restoring state
  final String? restorationId;

  @override
  State<FlowBuilder> createState() => _FlowBuilderState();
}

class _FlowBuilderState extends State<FlowBuilder> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = widget.pageController ?? PageController(
      initialPage: widget.controller.currentState.currentStepIndex,
      viewportFraction: widget.viewportFraction,
      keepPage: widget.keepPage,
    );

    widget.controller.stateStream.listen(_handleStateChange);
  }

  void _handleStateChange(FlowState state) {
    // Only animate if we should handle page change and the controller isn't provided externally
    if (widget.shouldHandlePage && widget.pageController == null) {
      if (state.currentStepIndex != _pageController.page?.round()) {
        _pageController.animateToPage(
          state.currentStepIndex,
          duration: widget.customTransitionDuration ?? 
                    widget.theme?.transitionDuration ?? 
                    const Duration(milliseconds: 300),
          curve: widget.customTransitionCurve ?? Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    // Only dispose if we created the controller ourselves
    if (widget.pageController == null) {
      _pageController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FlowScope(
      controller: widget.controller,
      theme: widget.theme,
      child: StreamBuilder<FlowState>(
        stream: widget.controller.stateStream,
        initialData: widget.controller.currentState,
        builder: (context, snapshot) {
          final state = snapshot.data!;
          
          // Build indicator if needed
          Widget? indicatorWidget;
          if (widget.indicatorPosition != IndicatorPosition.none && 
              widget.indicator != null &&
              state.steps.isNotEmpty) {
            indicatorWidget = Padding(
              padding: widget.indicatorPadding,
              child: widget.indicator!,
            );
          }
          
          // Build page view
          final pagerWidget = Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: widget.physics,
              scrollDirection: widget.scrollDirection == FlowScrollDirection.horizontal
                  ? Axis.horizontal
                  : Axis.vertical,
              itemCount: state.steps.length,
              onPageChanged: (index) {
                widget.onPageChanged?.call(index);
                if (widget.shouldHandlePage && index != state.currentStepIndex) {
                  widget.controller.goToStep(index);
                }
              },
              padEnds: true,
              pageSnapping: widget.pageSnapping,
              dragStartBehavior: widget.dragStartBehavior,
              clipBehavior: widget.clipBehavior,
              allowImplicitScrolling: widget.maintainState, 
              restorationId: widget.restorationId,
              reverse: widget.reverse,
              itemBuilder: (context, index) {
                final step = state.steps[index];
                final child = Padding(
                  padding: widget.contentPadding,
                  child: widget.stepBuilder(context, step),
                );
                
                if (widget.transitionBuilder != null) {
                  return PageTransitionSwitcher(
                    duration: widget.customTransitionDuration,
                    child: child,
                    transitionBuilder: (context, child, animation) {
                      return widget.transitionBuilder!(context, child, animation);
                    },
                  );
                }

                return child;
              },
            ),
          );
          
          // If custom layout provided, use it
          if (widget.customLayout != null) {
            return widget.customLayout!(
              context, 
              indicatorWidget ?? const SizedBox.shrink(), 
              pagerWidget
            );
          }
          
          // Otherwise use default layout based on indicator position
          if (widget.indicatorPosition == IndicatorPosition.bottom) {
            return Column(
              children: [
                pagerWidget,
                if (indicatorWidget != null) indicatorWidget,
              ],
            );
          } else {
            return Column(
              children: [
                if (indicatorWidget != null) indicatorWidget,
                pagerWidget,
              ],
            );
          }
        },
      ),
    );
  }
}

/// Inherited widget to provide flow controller and theme
class _FlowScope extends InheritedWidget {
  const _FlowScope({
    required super.child,
    required this.controller,
    required this.theme,
  });

  final FlowController controller;
  final FlowTheme? theme;

  static _FlowScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_FlowScope>();
  }

  @override
  bool updateShouldNotify(_FlowScope oldWidget) {
    return controller != oldWidget.controller || theme != oldWidget.theme;
  }
}

/// A widget that handles page transitions
class PageTransitionSwitcher extends StatelessWidget {
  const PageTransitionSwitcher({
    super.key,
    required this.child,
    required this.transitionBuilder,
    this.duration,
  });

  /// The child to display
  final Widget child;

  /// Builder for the transition animation
  final Widget Function(BuildContext context, Widget child, Animation<double> animation) transitionBuilder;
  
  /// Duration for the transition
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration ?? FlowTheme.of(context).transitionDuration,
      child: KeyedSubtree(
        key: ValueKey<Widget>(child),
        child: child,
      ),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return transitionBuilder(context, child, animation);
      },
    );
  }
}
