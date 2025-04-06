import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_step_flow/multi_step_flow.dart';
import 'package:multi_step_widgets/multi_step_widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-Step Flow Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const OnboardingFlow(),
    );
  }
}

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  late FlowBloc<OnboardingData> _bloc;

  @override
  void initState() {
    super.initState();
    // Create steps for our flow
    final steps = [
      FlowStep<OnboardingData>(
        id: 'welcome',
        title: 'Welcome',
        data: OnboardingData(),
      ),
      FlowStep<OnboardingData>(
        id: 'profile',
        title: 'Profile Setup',
        data: OnboardingData(),
      ),
      FlowStep<OnboardingData>(
        id: 'preferences',
        title: 'Preferences',
        isSkippable: true,
        data: OnboardingData(),
      ),
      FlowStep<OnboardingData>(
        id: 'complete',
        title: 'Complete',
        data: OnboardingData(),
      ),
    ];
    
    // Initialize bloc with the steps
    _bloc = FlowBloc<OnboardingData>(steps: steps);
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<FlowBloc<OnboardingData>, FlowState<OnboardingData>>(
          bloc: _bloc,
          builder: (context, state) {
            return Text(state.currentStep.title ?? 'Onboarding');
          },
        ),
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DotsIndicator<OnboardingData>(
              bloc: _bloc,
              onStepTapped: (index) {
                _bloc.add(FlowEvent.stepSelected(index: index));
              },
            ),
          ),
          
          // Main content
          Expanded(
            child: FlowBuilder<OnboardingData>(
              bloc: _bloc,
              stepBuilder: _buildStep,
            ),
          ),
          
          // Navigation bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FlowNavigationBar<OnboardingData>(
              bloc: _bloc,
              completeLabel: const Text('FINISH'),
              nextLabel: const Text('NEXT'),
              previousLabel: const Text('BACK'),
              skipLabel: const Text('SKIP'),
            ),
          ),
        ],
      ),
    );
  }

  // Builder for each step
  Widget _buildStep(BuildContext context, FlowStep<OnboardingData> step) {
    switch (step.id) {
      case 'welcome':
        return const WelcomeStep();
      case 'profile':
        return const ProfileStep();
      case 'preferences':
        return const PreferencesStep();
      case 'complete':
        return const CompleteStep();
      default:
        return const Center(child: Text('Unknown step'));
    }
  }
}

// Data model for our onboarding flow
class OnboardingData {
  final String? name;
  final String? email;
  final List<String> interests;
  final bool notifications;
  
  OnboardingData({
    this.name,
    this.email,
    this.interests = const [],
    this.notifications = false,
  });
  
  OnboardingData copyWith({
    String? name,
    String? email,
    List<String>? interests,
    bool? notifications,
  }) {
    return OnboardingData(
      name: name ?? this.name,
      email: email ?? this.email,
      interests: interests ?? this.interests,
      notifications: notifications ?? this.notifications,
    );
  }
}

// Welcome step
class WelcomeStep extends StatelessWidget {
  const WelcomeStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.waving_hand, size: 72, color: Colors.blue),
            const SizedBox(height: 24),
            Text(
              'Welcome to Our App!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'We\'re excited to have you join us. This short onboarding will help you get started.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Profile step
class ProfileStep extends StatefulWidget {
  const ProfileStep({Key? key}) : super(key: key);

  @override
  State<ProfileStep> createState() => _ProfileStepState();
}

class _ProfileStepState extends State<ProfileStep> {
  late FormStepData _formData;
  
  @override
  void initState() {
    super.initState();
    _formData = FormStepData();
  }
  
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<FlowBloc<OnboardingData>>(context);
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: FormStepLayout(
        title: 'Your Profile',
        description: 'Please enter your basic information',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FlowFormField(
              fieldName: 'name',
              formData: _formData,
              onChanged: _updateFormData,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.toString().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            FlowFormField(
              fieldName: 'email',
              formData: _formData,
              onChanged: _updateFormData,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.toString().isEmpty) {
                  return 'Email is required';
                }
                if (!value.toString().contains('@')) {
                  return 'Enter a valid email address';
                }
                return null;
              },
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
    );
  }
  
  void _updateFormData(FormStepData updatedFormData) {
    setState(() {
      _formData = updatedFormData;
    });
    
    // Update flow data
    final bloc = BlocProvider.of<FlowBloc<OnboardingData>>(context);
    final currentData = bloc.state.currentStep.data;
    
    final updatedData = currentData.copyWith(
      name: _formData.getField<String>('name'),
      email: _formData.getField<String>('email'),
    );
    
    bloc.updateStepData(updatedData);
    bloc.add(FlowEvent.stepValidated(isValid: _formData.isFormValid));
  }
}

// Preferences step
class PreferencesStep extends StatefulWidget {
  const PreferencesStep({Key? key}) : super(key: key);

  @override
  State<PreferencesStep> createState() => _PreferencesStepState();
}

class _PreferencesStepState extends State<PreferencesStep> {
  final List<String> _availableInterests = [
    'Technology', 'Sports', 'Music', 'Travel', 'Food', 'Art', 'Science'
  ];
  
  late List<String> _selectedInterests;
  late bool _enableNotifications;
  
  @override
  void initState() {
    super.initState();
    final bloc = BlocProvider.of<FlowBloc<OnboardingData>>(context);
    final data = bloc.state.currentStep.data;
    
    _selectedInterests = List.from(data.interests);
    _enableNotifications = data.notifications;
  }
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Preferences',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Select the topics you\'re interested in',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableInterests.map((interest) {
              final isSelected = _selectedInterests.contains(interest);
              return FilterChip(
                label: Text(interest),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedInterests.add(interest);
                    } else {
                      _selectedInterests.remove(interest);
                    }
                  });
                  _updateData();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Enable notifications'),
            subtitle: const Text('We\'ll keep you updated with relevant information'),
            value: _enableNotifications,
            onChanged: (value) {
              setState(() {
                _enableNotifications = value;
              });
              _updateData();
            },
          ),
        ],
      ),
    );
  }
  
  void _updateData() {
    final bloc = BlocProvider.of<FlowBloc<OnboardingData>>(context);
    final currentData = bloc.state.currentStep.data;
    
    final updatedData = currentData.copyWith(
      interests: _selectedInterests,
      notifications: _enableNotifications,
    );
    
    bloc.updateStepData(updatedData);
    
    // Preferences step is always valid
    bloc.add(const FlowEvent.stepValidated(isValid: true));
  }
}

// Complete step
class CompleteStep extends StatelessWidget {
  const CompleteStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<FlowBloc<OnboardingData>>(context);
    final data = bloc.state.currentStep.data;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 72, color: Colors.green),
            const SizedBox(height: 24),
            Text(
              'All Set, ${data.name ?? "User"}!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your profile has been created successfully.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (data.interests.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Your interests: ${data.interests.join(", ")}',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // In a real app, you would navigate to the main app screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Onboarding complete!')),
                );
              },
              child: const Text('GET STARTED'),
            ),
          ],
        ),
      ),
    );
  }
}
