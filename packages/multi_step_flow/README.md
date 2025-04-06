# Multi-Step Flow

A Flutter package for creating type-safe multi-step flows and wizards with modern architecture.

## Benefits & Use Cases

This package provides a powerful solution for implementing various types of multi-step flows in your Flutter applications:

- **Multi-Step Registration Forms**: Create complex registration processes that break lengthy forms into manageable steps with built-in validation
- **User Onboarding Experiences**: Design engaging onboarding tutorials with auto-advancing slides and progress tracking
- **Interactive Stories and Narratives**: Build interactive storytelling apps with branching paths and user choices
- **E-commerce Checkout Flows**: Implement streamlined checkout processes with predictable state management
- **Questionnaires and Surveys**: Create dynamic questionnaires with skip logic and conditional steps
- **Tutorial Wizards**: Guide users through complex features with step-by-step instructions
- **Multi-Page Document Flows**: Handle document submission workflows with file uploads and validation

## Features

- 🎯 **Type-safe** - Generic implementation with strong typing for compile-time safety
- 🔄 **BLoC-based state management** - Clean architecture with predictable state transitions
- 💾 **Persistent state** - Optional state persistence with hydrated_bloc to survive app restarts
- 🔌 **Extensible** - Create custom step types and extensions for your specific needs
- 🧩 **Modular** - Specialized components for different use cases that work together seamlessly
- 🎨 **Customizable** - Full control over UI and behavior with flexible theming options

## Installation

```yaml
dependencies:
  multi_step_flow: ^1.0.0
```

## Basic Usage

### 1. Define your steps

```dart
// Define your step data type
class RegistrationData {
  final String? name;
  final String? email;
  final bool acceptTerms;
  
  RegistrationData({this.name, this.email, this.acceptTerms = false});
}

// Create step definitions
final steps = [
  FlowStep<RegistrationData>(
    id: 'nameStep',
    title: 'Your Name',
    description: 'Please enter your name',
    data: RegistrationData(),
  ),
  FlowStep<RegistrationData>(
    id: 'emailStep',
    title: 'Email Address',
    description: 'Enter your email address',
    data: RegistrationData(),
  ),
  FlowStep<RegistrationData>(
    id: 'termsStep',
    title: 'Terms & Conditions',
    description: 'Please accept our terms and conditions',
    data: RegistrationData(),
  )
];
```

### 2. Create a FlowBloc

```dart
// Create a bloc
final bloc = FlowBloc<RegistrationData>(steps);

// Or use a hydrated bloc for persistence
final bloc = HydratedFlowBloc<RegistrationData>(
  steps,
  persistState: true,
);
```

### 3. Use the FlowBloc in your UI

```dart
class RegistrationFlow extends StatelessWidget {
  final FlowBloc<RegistrationData> bloc;

  const RegistrationFlow({Key? key, required this.bloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlowBlocProvider<RegistrationData>(
      bloc: bloc,
      child: BlocBuilder<FlowBloc<RegistrationData>, FlowState<RegistrationData>>(
        bloc: bloc,
        builder: (context, state) {
          // Build your UI based on the current step
          return Scaffold(
            appBar: AppBar(title: Text(state.currentStep.title ?? 'Registration')),
            body: _buildStepContent(context, state.currentStep),
            bottomNavigationBar: FlowNavigationBar<RegistrationData>(bloc: bloc),
          );
        },
      ),
    );
  }
  
  Widget _buildStepContent(BuildContext context, FlowStep<RegistrationData> step) {
    // Build the content for each step based on the step ID
    switch (step.id) {
      case 'nameStep':
        return NameStepContent(step: step, bloc: bloc);
      case 'emailStep':
        return EmailStepContent(step: step, bloc: bloc);
      case 'termsStep':
        return TermsStepContent(step: step, bloc: bloc);
      default:
        return const SizedBox();
    }
  }
}
```

## Specialized Components

### Form Flow

The package provides specialized components for form-based flows:

```dart
// Create a form step
final formStep = FlowStep<FormStepData>(
  id: 'contactForm',
  title: 'Contact Information',
  data: FormStepData(),
);

// Use the FormStepBuilder widget
FormStepBuilder<UserData>(
  bloc: bloc,
  step: step,
  formDataExtractor: (data) => data?.contactForm ?? FormStepData(),
  formDataUpdater: (data, formData) {
    return UserData(contactForm: formData);
  },
  builder: (context, formData, onChanged, formKey) {
    return Column(
      children: [
        FlowFormField(
          fieldName: 'name',
          formData: formData,
          onChanged: onChanged,
          decoration: InputDecoration(labelText: 'Full Name'),
          validator: (value) => value.isEmpty ? 'Name is required' : null,
        ),
        FlowFormField(
          fieldName: 'email',
          formData: formData,
          onChanged: onChanged,
          decoration: InputDecoration(labelText: 'Email'),
          validator: (value) => !value.contains('@') ? 'Invalid email' : null,
        ),
      ],
    );
  },
);
```

### Information Flow

For content-focused flows with auto-advance and read tracking:

```dart
// Create an information step
final infoStep = FlowStep<InformationStepData>(
  id: 'introductionStep',
  title: 'Welcome',
  data: InformationStepData(autoAdvance: true, autoAdvanceAfterSeconds: 10),
);

// Use the InformationStepBuilder widget
InformationStepBuilder<TutorialData>(
  bloc: bloc,
  step: step,
  infoDataExtractor: (data) => data?.introduction ?? InformationStepData(),
  infoDataUpdater: (data, infoData) {
    return TutorialData(introduction: infoData);
  },
  contentBuilder: (context, infoData, onUpdate) {
    return InformationStepLayout(
      title: 'Welcome to the App',
      description: 'Learn how to use our amazing features',
      child: Column(
        children: [
          Image.asset('assets/welcome.png'),
          Text('This tutorial will guide you through the main features.'),
          // Auto-advances after the configured time
        ],
      ),
    );
  },
);
```

## Custom Step Types

You can create custom step types using the extension system:

```dart
// Define a custom step extension
class VideoStepExtension extends StepExtension<LessonData> {
  @override
  String get id => 'video_extension';
  
  @override
  void onStepEnter(FlowStep<LessonData> step) {
    // Start video playback
    print('Starting video playback for step: ${step.id}');
  }
  
  @override
  void onStepExit(FlowStep<LessonData> step) {
    // Pause video playback
    print('Pausing video playback for step: ${step.id}');
  }
}

// Register the extension
final registry = StepExtensionRegistry<LessonData>();
registry.registerExtension(VideoStepExtension());

// Create a step with the extension
final videoStep = FlowStep<LessonData>(
  id: 'lesson1',
  title: 'Introduction to Flutter',
  data: LessonData(videoUrl: 'https://example.com/video.mp4'),
).withExtension('video_extension');
```

## Complete Documentation

For full documentation and examples, visit [github.com/yourorg/multi_step_flow](https://github.com/yourorg/multi_step_flow).
