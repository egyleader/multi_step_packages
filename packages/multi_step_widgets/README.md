# multi_step_widgets

Flutter UI widgets for building multi-step flows with customizable indicators, navigation controls, and layouts.

> **✨ All-in-One Solution**: This package includes everything you need - both UI components and core flow management functionality. You don't need to install `multi_step_flow` separately.

## Features

- **FlowBuilder**: Core widget for building multi-step interfaces
- **Step Indicators**: Visual indicators for flow progress
  - Dots Indicator
  - Custom indicator support
- **Navigation Controls**: Pre-built navigation buttons and bars
- **Layouts**: Ready-to-use layouts for common flow patterns
- **Theming**: Comprehensive theming support for consistent UI
- **All-in-one Package**: Re-exports all necessary types from multi_step_flow

## Getting Started

Add multi_step_widgets to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  multi_step_widgets: ^0.2.0
  # No need to depend on multi_step_flow separately
```

Then run:

```bash
flutter pub get
```

> **Note:** This package now re-exports all necessary types from `multi_step_flow`, so you don't need to depend on both packages anymore.

## Usage

### Basic Flow Layout

```dart
import 'package:flutter/material.dart';
import 'package:multi_step_widgets/multi_step_widgets.dart';

class MyFlowScreen extends StatefulWidget {
  @override
  State<MyFlowScreen> createState() => _MyFlowScreenState();
}

class _MyFlowScreenState extends State<MyFlowScreen> {
  late FlowController controller;

  @override
  void initState() {
    super.initState();
    controller = FlowController(
      steps: [
        // Define your steps here
        YourCustomStep(id: 'step1', title: 'Step 1'),
        YourCustomStep(id: 'step2', title: 'Step 2'),
        YourCustomStep(id: 'step3', title: 'Step 3'),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Multi-step Flow')),
      body: FlowLayout(
        controller: controller,
        stepBuilder: (context, step) {
          // Build your step UI here
          return Center(
            child: Text(step.title ?? 'Step'),
          );
        },
      ),
    );
  }
}
```

### Custom Flow Builder

For more customization, use the FlowBuilder directly:

```dart
FlowBuilder(
  controller: controller,
  stepBuilder: (context, step) {
    // Return your custom step UI
    return YourStepWidget(step: step);
  },
  indicator: DotsIndicator(),
  theme: FlowTheme(
    stepIndicatorTheme: StepIndicatorThemeData(
      activeColor: Colors.blue,
      inactiveColor: Colors.grey,
      completedColor: Colors.green,
    ),
    transitionDuration: Duration(milliseconds: 300),
  ),
  showIndicator: true,
  physics: NeverScrollableScrollPhysics(), // Control scroll behavior
  transitionBuilder: (context, child, animation) {
    // Custom transition effects
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  },
);
```

### Navigation Controls

```dart
FlowNavigationBar(
  controller: controller,
  nextLabel: 'Continue',
  previousLabel: 'Back',
  skipLabel: 'Skip',
  showSkipButton: true,
  onCompleted: () {
    // Called when the last step is completed
    Navigator.of(context).pushReplacementNamed('/success');
  },
);
```

### Step Indicators

```dart
DotsIndicator(
  controller: controller,
  // Custom styling
  activeColor: Colors.blue,
  inactiveColor: Colors.grey,
  completedColor: Colors.green,
  size: 12,
  spacing: 8,
)
```

### Theming

Apply theming at the app level:

```dart
MaterialApp(
  title: 'Flow Demo',
  theme: ThemeData(
    // Your normal theme configuration
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    useMaterial3: true,
    // Add flow theme as an extension
    extensions: const [
      FlowTheme(
        stepIndicatorTheme: StepIndicatorThemeData(
          activeColor: Colors.blue,
          inactiveColor: Colors.grey,
          completedColor: Colors.green,
          size: 12,
          spacing: 8,
        ),
        transitionDuration: Duration(milliseconds: 300),
      ),
    ],
  ),
  home: YourFlowScreen(),
);
```

## Examples

Check the `/example` folder for complete examples including:

- Registration flow with validation
- Questionnaire flow
- Onboarding flow

## Additional Information

This package includes all the necessary types and functionality from `multi_step_flow` package. You do not need to depend on `multi_step_flow` separately as all its components (FlowController, FlowStep, etc.) are re-exported through this package.

This package provides both:
1. Flow state management (through the included multi_step_flow functionality)
2. Ready-to-use Flutter UI components for building multi-step interfaces

For a simpler setup:
- If you're building a Flutter app, use this package only
- If you're building a pure Dart application (no Flutter), use the `multi_step_flow` package directly
