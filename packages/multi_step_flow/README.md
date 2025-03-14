# multi_step_flow

A platform-agnostic Dart package for managing multi-step flows with powerful state management, validation, and customization options.

> **🚨 Flutter Users**: If you're building a Flutter application, use the [`multi_step_widgets`](https://pub.dev/packages/multi_step_widgets) package instead. It includes all the functionality from this package plus Flutter UI components.

## Features

- **Flexible Step Management**: Define complex multi-step flows with custom step types
- **Powerful State Management**: Built on bloc 9.0.0 for reliable state transitions
- **Validation Support**: Built-in validation hooks for implementing custom validation rules
- **Lifecycle Events**: Step-specific lifecycle events (onEnter, onExit, onSkip)
- **Configuration Options**: Customize navigation behavior, validation timing, and more
- **Asynchronous API**: Fully asynchronous API for smooth integration with UI

## Getting Started

Add multi_step_flow to your `pubspec.yaml`:

```yaml
dependencies:
  multi_step_flow: ^0.2.0
```

Then run:

```bash
dart pub get
```

> **Note:** For Flutter users, consider using `multi_step_widgets` package instead, which re-exports all the necessary types from this package.

## Usage

### Basic Flow Setup

```dart
import 'package:multi_step_flow/multi_step_flow.dart';

void main() {
  // 1. Create your steps
  final steps = [
    YourCustomStep(id: 'step1', title: 'Step 1'),
    YourCustomStep(id: 'step2', title: 'Step 2'),
    YourCustomStep(id: 'step3', title: 'Step 3', isSkippable: true),
  ];

  // 2. Initialize the flow controller
  final controller = FlowController(
    steps: steps,
    configuration: const FlowConfiguration(
      validateOnStepChange: true,
    ),
  );

  // 3. Listen to state changes
  controller.stateStream.listen((state) {
    print('Current step: ${state.currentStep?.id}');
    print('Flow status: ${state.status}');
  });

  // 4. Navigate through steps
  controller.next(); // Move to next step
  controller.previous(); // Move to previous step
  controller.skip(); // Skip the current step (if skippable)
  controller.goToStep(2); // Jump to a specific step
}
```

### Creating Custom Steps

Create custom step types by extending the `FlowStep` abstract class:

```dart
class YourCustomStep extends FlowStep {
  YourCustomStep({
    required String id,
    String? title,
    String? description,
    bool isSkippable = false,
    Duration? timeLimit,
    Map<String, dynamic>? data,
  }) : super(
          id: id,
          title: title,
          description: description,
          isSkippable: isSkippable,
          timeLimit: timeLimit,
          data: data,
        );

  @override
  Future<bool> validate() async {
    // Implement your validation logic here
    return _isValid;
  }

  @override
  Future<void> onEnter() async {
    // Called when step becomes active
    print('Entering step $id');
  }

  @override
  Future<void> onExit() async {
    // Called when leaving step
    print('Exiting step $id');
  }

  @override
  Future<void> onSkip() async {
    // Called when step is skipped
    print('Skipping step $id');
  }

  @override
  FlowStep copyWith({
    String? id,
    String? title,
    String? description,
    bool? isSkippable,
    Duration? timeLimit,
    Map<String, dynamic>? data,
  }) {
    return YourCustomStep(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isSkippable: isSkippable ?? this.isSkippable,
      timeLimit: timeLimit ?? this.timeLimit,
      data: data ?? this.data,
    );
  }
}
```

### Configuring Flow Behavior

```dart
final controller = FlowController(
  steps: steps,
  configuration: const FlowConfiguration(
    // Navigation behavior
    allowBackNavigation: true,
    
    // Validation behavior
    autoAdvanceOnValidation: true,
    validateOnStepChange: true,
    
    // UI configuration (for integrating with widgets)
    showStepIndicator: true,
    
    // State management
    preserveState: true,
    
    // Timing (for timed steps)
    defaultStepDuration: Duration(seconds: 30),
    
    // Callbacks
    onFlowComplete: () async {
      print('Flow completed!');
    },
  ),
);
```

## Advanced Usage

Check the `/example` folder for more detailed examples including:

- Registration flow with validation
- Step lifecycle event handling
- Flow state management
- Error handling

## Additional Information

This package provides the core state management and flow control functionality. It can be used in any Dart project that needs multi-step flow management, with or without a UI.

### Package Selection Guide

1. **Flutter Applications**:
   - Use the `multi_step_widgets` package instead of this one
   - The widgets package already includes all functionality from this package
   - You don't need to depend on both packages

2. **Pure Dart Applications**:
   - Use this package directly
   - Perfect for backend services, CLI tools, or any non-Flutter Dart project
   - Provides all the flow management functionality without UI dependencies

### Note on Package Dependencies

If you're already using `multi_step_widgets`, you don't need to add this package to your dependencies as all its functionality is re-exported through the widgets package.
