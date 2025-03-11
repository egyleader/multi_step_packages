import 'package:flutter/material.dart';

/// Theme data for step indicators
class StepIndicatorThemeData {
  const StepIndicatorThemeData({
    this.activeColor,
    this.inactiveColor,
    this.completedColor,
    this.errorColor,
    this.size = 8.0,
    this.spacing = 4.0,
    this.strokeWidth = 2.0,
    this.labelStyle,
  });

  /// Color for the active step
  final Color? activeColor;

  /// Color for inactive steps
  final Color? inactiveColor;

  /// Color for completed steps
  final Color? completedColor;

  /// Color for steps with errors
  final Color? errorColor;

  /// Size of the indicator
  final double size;

  /// Spacing between indicators
  final double spacing;

  /// Width of indicator strokes/borders
  final double strokeWidth;

  /// Text style for indicator labels
  final TextStyle? labelStyle;

  /// Creates a copy of this theme with the given fields replaced with new values
  StepIndicatorThemeData copyWith({
    Color? activeColor,
    Color? inactiveColor,
    Color? completedColor,
    Color? errorColor,
    double? size,
    double? spacing,
    double? strokeWidth,
    TextStyle? labelStyle,
  }) {
    return StepIndicatorThemeData(
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      completedColor: completedColor ?? this.completedColor,
      errorColor: errorColor ?? this.errorColor,
      size: size ?? this.size,
      spacing: spacing ?? this.spacing,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      labelStyle: labelStyle ?? this.labelStyle,
    );
  }

  /// Merges two StepIndicatorThemeData objects
  StepIndicatorThemeData merge(StepIndicatorThemeData? other) {
    if (other == null) return this;
    return copyWith(
      activeColor: other.activeColor,
      inactiveColor: other.inactiveColor,
      completedColor: other.completedColor,
      errorColor: other.errorColor,
      size: other.size,
      spacing: other.spacing,
      strokeWidth: other.strokeWidth,
      labelStyle: other.labelStyle,
    );
  }

  /// Resolves the theme colors against the given color scheme
  StepIndicatorThemeData resolve(ColorScheme colorScheme) {
    return copyWith(
      activeColor: activeColor ?? colorScheme.primary,
      inactiveColor: inactiveColor ?? colorScheme.onSurface.withAlpha(97),
      completedColor: completedColor ?? colorScheme.primary,
      errorColor: errorColor ?? colorScheme.error,
      labelStyle:
          labelStyle ?? TextStyle(color: colorScheme.onSurface, fontSize: 12),
    );
  }
}
