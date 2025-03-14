import 'package:flutter/material.dart';
import '../theme/flow_theme.dart';

/// Button styles for navigation buttons
enum NavigationButtonStyle { filled, outlined, text }

/// A button widget for flow navigation
class NavigationButton extends StatelessWidget {
  const NavigationButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style = NavigationButtonStyle.filled,
    this.enabled = true,
  });

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Child widget
  final Widget child;

  /// Button style
  final NavigationButtonStyle style;

  /// Whether the button is enabled
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = FlowTheme.of(context);
    final buttonStyle =
        theme.buttonTheme?.copyWith(
          backgroundColor:
              style == NavigationButtonStyle.filled
                  ? WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.disabled)) {
                      return Theme.of(context).disabledColor;
                    }
                    return Theme.of(context).primaryColor;
                  })
                  : WidgetStateProperty.all(Colors.transparent),
          foregroundColor:
              style == NavigationButtonStyle.filled
                  ? WidgetStateProperty.all(Colors.white)
                  : WidgetStateProperty.all(Theme.of(context).primaryColor),
          side:
              style == NavigationButtonStyle.outlined
                  ? WidgetStateProperty.all(
                    BorderSide(color: Theme.of(context).primaryColor),
                  )
                  : null,
        ) ??
        ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );

    switch (style) {
      case NavigationButtonStyle.filled:
        return ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: buttonStyle,
          child: child,
        );
      case NavigationButtonStyle.outlined:
        return OutlinedButton(
          onPressed: enabled ? onPressed : null,
          style: buttonStyle,
          child: child,
        );
      case NavigationButtonStyle.text:
        return TextButton(
          onPressed: enabled ? onPressed : null,
          style: buttonStyle,
          child: child,
        );
    }
  }
}
