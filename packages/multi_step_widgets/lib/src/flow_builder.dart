import 'package:flutter/material.dart';
import 'package:multi_step_flow/multi_step_flow.dart';

import 'indicators/base_indicator.dart';
import 'theme/flow_theme.dart';

/// Signature for building step content
typedef StepBuilder = Widget Function(BuildContext context, FlowStep step);

/// A widget that builds a multi-step flow interface
class FlowBuilder extends StatefulWidget {
  const FlowBuilder({
    super.key,
    required this.controller,
    required this.stepBuilder,
    required this.indicator,
    this.theme,
    this.showIndicator = true,
    this.physics = const AlwaysScrollableScrollPhysics(),
    this.padding = const EdgeInsets.all(16.0),
    this.transitionBuilder,
  });

  /// Controller for managing the flow state
  final FlowController controller;

  /// Builder for step content
  final StepBuilder stepBuilder;

  /// Theme for the flow
  final FlowTheme? theme;

  /// Step indicator widget
  final StepIndicator indicator;

  /// Whether to show the step indicator
  final bool showIndicator;

  /// Scroll physics for the step content
  final ScrollPhysics physics;

  /// Padding around the step content
  final EdgeInsets padding;

  /// Custom transition builder
  final Widget Function(BuildContext, Widget, Animation<double>)? transitionBuilder;

  @override
  State<FlowBuilder> createState() => _FlowBuilderState();
}

class _FlowBuilderState extends State<FlowBuilder> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.controller.currentState.currentStepIndex,
    );

    widget.controller.stateStream.listen(_handleStateChange);
  }

  void _handleStateChange(FlowState state) {
    if (state.currentStepIndex != _pageController.page?.round()) {
      _pageController.animateToPage(
        state.currentStepIndex,
        duration: widget.theme?.transitionDuration ?? const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
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
          return Column(
            children: [
              if (widget.showIndicator && state.steps.isNotEmpty)
                Padding(
                  padding: widget.padding,
                  child: widget.indicator,
                ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: widget.physics,
                  itemCount: state.steps.length,
                  onPageChanged: (index) {
                    if (index != state.currentStepIndex) {
                      widget.controller.goToStep(index);
                    }
                  },
                  itemBuilder: (context, index) {
                    final step = state.steps[index];
                    final child = widget.stepBuilder(context, step);
                    
                    if (widget.transitionBuilder != null) {
                      return PageTransitionSwitcher(
                        child: child,
                        transitionBuilder: (context, child, animation) {
                          return widget.transitionBuilder!(context, child, animation);
                        },
                      );
                    }

                    return child;
                  },
                ),
              ),
            ],
          );
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
  });

  /// The child to display
  final Widget child;

  /// Builder for the transition animation
  final Widget Function(BuildContext context, Widget child, Animation<double> animation) transitionBuilder;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: FlowTheme.of(context).transitionDuration,
      child: child,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return transitionBuilder(context, child, animation);
      },
    );
  }
}
