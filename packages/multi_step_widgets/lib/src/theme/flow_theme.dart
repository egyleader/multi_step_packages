import 'dart:ui';
import 'package:flutter/material.dart';
import 'indicator_theme.dart';

/// Theme data for multi-step flows
class FlowTheme extends ThemeExtension<FlowTheme> {
  const FlowTheme({
    this.stepIndicatorTheme = const StepIndicatorThemeData(),
    this.navigationBarHeight = 56.0,
    this.navigationBarPadding = const EdgeInsets.all(16.0),
    this.transitionDuration = const Duration(milliseconds: 300),
    this.buttonTheme,
  });

  /// Theme for step indicators
  final StepIndicatorThemeData stepIndicatorTheme;

  /// Height of the navigation bar
  final double navigationBarHeight;

  /// Padding around the navigation bar
  final EdgeInsets navigationBarPadding;

  /// Duration for step transitions
  final Duration transitionDuration;

  /// Theme for navigation buttons
  final ButtonStyle? buttonTheme;

  @override
  FlowTheme copyWith({
    StepIndicatorThemeData? stepIndicatorTheme,
    double? navigationBarHeight,
    EdgeInsets? navigationBarPadding,
    Duration? transitionDuration,
    ButtonStyle? buttonTheme,
  }) {
    return FlowTheme(
      stepIndicatorTheme: stepIndicatorTheme ?? this.stepIndicatorTheme,
      navigationBarHeight: navigationBarHeight ?? this.navigationBarHeight,
      navigationBarPadding: navigationBarPadding ?? this.navigationBarPadding,
      transitionDuration: transitionDuration ?? this.transitionDuration,
      buttonTheme: buttonTheme ?? this.buttonTheme,
    );
  }

  @override
  ThemeExtension<FlowTheme> lerp(
    covariant ThemeExtension<FlowTheme>? other,
    double t,
  ) {
    if (other is! FlowTheme) return this;
    return FlowTheme(
      stepIndicatorTheme: other.stepIndicatorTheme,
      navigationBarHeight: lerpDouble(navigationBarHeight, other.navigationBarHeight, t) ?? navigationBarHeight,
      navigationBarPadding: EdgeInsets.lerp(navigationBarPadding, other.navigationBarPadding, t)!,
      transitionDuration: transitionDuration,
      buttonTheme: t < 0.5 ? buttonTheme : other.buttonTheme,
    );
  }

  /// Gets the FlowTheme from the current BuildContext
  static FlowTheme of(BuildContext context) {
    final theme = Theme.of(context).extension<FlowTheme>();
    return theme ?? const FlowTheme();
  }
}
