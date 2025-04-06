import 'package:flutter/material.dart';
import 'package:multi_step_flow/multi_step_flow.dart';

import '../theme/indicator_theme.dart';
import 'base_indicator.dart';

/// A dot-based step indicator with generic type support
class DotsIndicator<TStepData> extends StepIndicator<TStepData> {
  const DotsIndicator({
    super.key,
    super.bloc,
    super.onStepTapped,
    super.theme,
    this.axis = Axis.horizontal,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.min,
  });

  /// The axis along which the dots are placed
  final Axis axis;

  /// Alignment of dots along the main axis
  final MainAxisAlignment mainAxisAlignment;

  /// The size of the main axis
  final MainAxisSize mainAxisSize;

  @override
  Widget buildIndicator(BuildContext context, FlowState<TStepData> state) {
    final resolvedTheme =
        theme?.resolve(Theme.of(context).colorScheme) ??
        const StepIndicatorThemeData().resolve(Theme.of(context).colorScheme);

    final stepCount = getStepCount(state);
    final dots = List.generate(
      stepCount,
      (index) => _buildDot(context, state, index, resolvedTheme),
    );

    return axis == Axis.horizontal
        ? Row(
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          children: _addSpacing(dots, resolvedTheme),
        )
        : Column(
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          children: _addSpacing(dots, resolvedTheme),
        );
  }

  Widget _buildDot(
    BuildContext context,
    FlowState<TStepData> state,
    int index,
    StepIndicatorThemeData theme,
  ) {
    final isActive = index == getCurrentStepIndex(state);
    final color = getStepColor(context, state, index);

    return GestureDetector(
      onTap: () => handleStepTap(context, state, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isActive ? theme.size * 2 : theme.size,
        height: theme.size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(theme.size / 2),
          border: Border.all(color: color, width: theme.strokeWidth),
        ),
      ),
    );
  }

  List<Widget> _addSpacing(
    List<Widget> children,
    StepIndicatorThemeData theme,
  ) {
    if (children.isEmpty) return children;

    final spacedChildren = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(
          SizedBox(
            width: axis == Axis.horizontal ? theme.spacing : 0,
            height: axis == Axis.vertical ? theme.spacing : 0,
          ),
        );
      }
    }

    return spacedChildren;
  }
}
