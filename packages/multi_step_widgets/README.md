# Multi-Step Widgets

UI components for building multi-step flows, forms, and wizards in Flutter.

## Benefits & Use Cases

The multi_step_widgets package provides ready-to-use UI components that work seamlessly with the multi_step_flow architecture to create:

- **Engaging Onboarding Experiences**: Create beautiful onboarding flows with animated transitions and interactive elements
- **Multi-Page Forms**: Break complex forms into logical steps with validation and state persistence
- **Interactive Wizards**: Guide users through complex setup processes with visual indicators of progress
- **Story-Based Content**: Build interactive stories or educational content with automatic progression
- **Product Tours**: Showcase features with step-by-step guidance
- **Multi-Stage Checkouts**: Create intuitive e-commerce checkout experiences
- **Decision Trees**: Implement conditional flows based on user responses

## Features

- 🎯 **Type-safe** - Fully generic implementation with strong typing for compile-time safety
- 🔄 **BLoC integration** - Clean architecture with predictable state management
- 🎨 **Customizable** - Extensive theming and styling options for your brand identity
- 📱 **Responsive** - Works on all platforms and screen sizes with adaptive layouts
- 🧩 **Specialized components** - Form, information, and custom flows for various use cases

## Installation

```yaml
dependencies:
  multi_step_widgets: ^0.3.0
  multi_step_flow: ^0.3.0  # Required dependency
```

## Core Components

### FlowBuilder

The core component for rendering multi-step flows:

```dart
FlowBuilder<UserData>(
  bloc: flowBloc,
  stepBuilder: (context, step) {
    // Build your step UI based on step.id
    return YourStepWidget(step: step);
  },
  // Optional customizations
  loadingBuilder: (context, state) => CircularProgressIndicator(),
  errorBuilder: (context, error) => Text('Error: $error'),
  completedBuilder: (context, state) => Text('Flow completed!'),
  transitionBuilder: (child, animation) {
    return FadeTransition(opacity: animation, child: child);
  },
  animateTransitions: true,
  transitionDuration: Duration(milliseconds: 300),
  onFlowCompleted: () => print('Flow completed!'),
)
```

### FlowLayout

A complete layout for multi-step flows:

```dart
FlowLayout<UserData>(
  bloc: flowBloc,
  stepBuilder: (context, step) => YourStepWidget(step: step),
  // Optional customizations
  indicatorBuilder: (state) => DotsIndicator<UserData>(bloc: flowBloc),
  showIndicator: true,
  showNavigationBar: true,
  navigationBarBuilder: (state) => FlowNavigationBar<UserData>(
    bloc: flowBloc, 
    nextLabel: Text('CONTINUE'),
    previousLabel: Text('BACK'),
  ),
  scrollDirection: FlowScrollDirection.horizontal,
  indicatorPosition: IndicatorPosition.top,
)
```

### Navigation Components

```dart
FlowNavigationBar<UserData>(
  bloc: flowBloc,
  showNextButton: true,
  showPreviousButton: true,
  showSkipButton: true,
  nextLabel: Text('NEXT'),
  previousLabel: Text('BACK'),
  skipLabel: Text('SKIP'),
  completeLabel: Text('FINISH'),
  // Button styles
  nextStyle: NavigationButtonStyle.filled,
  previousStyle: NavigationButtonStyle.outlined,
  skipStyle: NavigationButtonStyle.text,
)
```

## Step Indicators

### DotsIndicator

```dart
DotsIndicator<UserData>(
  bloc: flowBloc,
  axis: Axis.horizontal,
  mainAxisAlignment: MainAxisAlignment.center,
  theme: StepIndicatorThemeData(
    activeColor: Colors.blue,
    inactiveColor: Colors.grey,
    completedColor: Colors.green,
    errorColor: Colors.red,
    size: 8.0,
    spacing: 4.0,
    strokeWidth: 1.0,
  ),
  onStepTapped: (index) {
    // Navigate to step
    flowBloc.add(FlowEvent.stepSelected(index: index));
  },
)
```

## Form Components

### FormStepBuilder

Specialized component for form steps:

```dart
FormStepBuilder<UserData>(
  bloc: flowBloc,
  step: state.currentStep,
  formDataExtractor: (data) => data?.personalInfo ?? FormStepData(),
  formDataUpdater: (data, formData) {
    return data?.copyWith(personalInfo: formData) ?? 
           UserData(personalInfo: formData);
  },
  validators: {
    'name': (value) => (value == null || value.isEmpty) 
                    ? 'Name is required' : null,
    'email': (value) => !value.toString().contains('@') 
                    ? 'Invalid email' : null,
  },
  autovalidateMode: AutovalidateMode.onUserInteraction,
  builder: (context, formData, onChanged, formKey) {
    return FormStepLayout(
      title: 'Personal Information',
      description: 'Please enter your details',
      child: Column(
        children: [
          FlowFormField(
            fieldName: 'name',
            formData: formData,
            onChanged: onChanged,
            decoration: InputDecoration(labelText: 'Full Name'),
          ),
          SizedBox(height: 16),
          FlowFormField(
            fieldName: 'email',
            formData: formData,
            onChanged: onChanged,
            decoration: InputDecoration(labelText: 'Email Address'),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  },
)
```

## Information Components

### InformationStepBuilder

For content-focused steps with read tracking:

```dart
InformationStepBuilder<TutorialData>(
  bloc: flowBloc,
  step: state.currentStep,
  infoDataExtractor: (data) => data?.introduction ?? InformationStepData(),
  infoDataUpdater: (data, infoData) {
    return data?.copyWith(introduction: infoData) ?? 
           TutorialData(introduction: infoData);
  },
  enableAutoReadTracking: true,
  showProgressIndicator: true,
  contentBuilder: (context, infoData, onUpdate) {
    return InformationStepLayout(
      title: 'Getting Started',
      description: 'Learn how to use our app',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('assets/tutorial1.png'),
          SizedBox(height: 16),
          Text(
            'Welcome to our application! This tutorial will help you...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          // Content automatically tracks read progress
        ],
      ),
    );
  },
)
```

## Theming and Customization

### FlowTheme

```dart
FlowTheme(
  theme: FlowThemeData(
    indicatorTheme: StepIndicatorThemeData(
      activeColor: Colors.blue,
      inactiveColor: Colors.grey.shade300,
      completedColor: Colors.green,
      errorColor: Colors.red,
      size: 10.0,
      spacing: 4.0,
    ),
    navigationTheme: NavigationThemeData(
      primaryColor: Colors.blue,
      secondaryColor: Colors.grey,
      textStyle: TextStyle(fontWeight: FontWeight.bold),
      buttonPadding: EdgeInsets.symmetric(
        horizontal: 16.0, 
        vertical: 8.0
      ),
      buttonShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
  ),
  child: YourFlowWidget(),
)
```

## Extending with Custom Components

You can create custom indicators, navigation bars, or specialized step components:

```dart
// Custom step indicator
class NumberedIndicator<T> extends StepIndicator<T> {
  const NumberedIndicator({
    super.key,
    super.bloc,
    super.onStepTapped,
    super.theme,
  });

  @override
  Widget buildIndicator(BuildContext context, FlowState<T> state) {
    // Implementation for numbered steps
    return Row(children: [
      for (int i = 0; i < state.steps.length; i++)
        _buildNumberedStep(context, state, i),
    ]);
  }
  
  Widget _buildNumberedStep(BuildContext context, FlowState<T> state, int index) {
    final isActive = index == state.currentStepIndex;
    final isCompleted = state.validatedSteps.contains(state.steps[index].id);
    
    return GestureDetector(
      onTap: () => handleStepTap(context, state, index),
      child: Container(
        // Your custom UI implementation
      ),
    );
  }
}
``
