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
      title: 'Registration Flow Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const RegistrationScreen(),
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late FlowBloc<RegistrationData> _bloc;

  @override
  void initState() {
    super.initState();

    // Create steps for registration flow
    final steps = [
      FlowStep<RegistrationData>(
        id: 'personal',
        title: 'Personal Information',
        data: RegistrationData(),
      ),
      FlowStep<RegistrationData>(
        id: 'account',
        title: 'Account Details',
        data: RegistrationData(),
      ),
      FlowStep<RegistrationData>(
        id: 'preferences',
        title: 'Preferences',
        isSkippable: true,
        data: RegistrationData(),
      ),
    ];

    // Initialize the bloc
    _bloc = FlowBloc<RegistrationData>(steps: steps);
    
    // Mark the registration flow as initially invalid
    _bloc.add(const FlowEvent.stepValidated(isValid: false));
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
        title: BlocBuilder<FlowBloc<RegistrationData>, FlowState<RegistrationData>>(
          bloc: _bloc,
          builder: (context, state) {
            return Text(state.currentStep.title ?? 'Registration');
          },
        ),
      ),
      body: FlowBlocProvider<RegistrationData>(
        bloc: _bloc,
        child: BlocBuilder<FlowBloc<RegistrationData>, FlowState<RegistrationData>>(
          bloc: _bloc,
          builder: (context, state) {
            return Column(
              children: [
                // Step indicator
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DotsIndicator<RegistrationData>(
                    bloc: _bloc,
                  ),
                ),
                
                // Main content
                Expanded(
                  child: _buildStep(context, state.currentStep),
                ),
                
                // Navigation bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FlowNavigationBar<RegistrationData>(
                    bloc: _bloc,
                    completeLabel: const Text('COMPLETE'),
                    nextLabel: const Text('NEXT'),
                    previousLabel: const Text('BACK'),
                    skipLabel: const Text('SKIP'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildStep(BuildContext context, FlowStep<RegistrationData> step) {
    switch (step.id) {
      case 'personal':
        return const PersonalInfoForm();
      case 'account':
        return const AccountDetailsForm();
      case 'preferences':
        return const PreferencesForm();
      default:
        return const Center(child: Text('Unknown step'));
    }
  }
}

// Data model for registration flow
class RegistrationData {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? password;
  final bool receiveNewsletter;
  final String? preferredTheme;
  
  const RegistrationData({
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.receiveNewsletter = false,
    this.preferredTheme,
  });
  
  RegistrationData copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    bool? receiveNewsletter,
    String? preferredTheme,
  }) {
    return RegistrationData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      receiveNewsletter: receiveNewsletter ?? this.receiveNewsletter,
      preferredTheme: preferredTheme ?? this.preferredTheme,
    );
  }
}

// Personal Information Form
class PersonalInfoForm extends StatefulWidget {
  const PersonalInfoForm({Key? key}) : super(key: key);
  
  @override
  State<PersonalInfoForm> createState() => _PersonalInfoFormState();
}

class _PersonalInfoFormState extends State<PersonalInfoForm> {
  late FormStepData _formData;
  
  @override
  void initState() {
    super.initState();
    _formData = FormStepData();
  }
  
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<FlowBloc<RegistrationData>>(context);
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: FormStepLayout(
        title: 'Personal Information',
        description: 'Please enter your name',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FlowFormField(
              fieldName: 'firstName',
              formData: _formData,
              onChanged: _updateFormData,
              decoration: const InputDecoration(
                labelText: 'First Name',
                hintText: 'Enter your first name',
              ),
              validator: (value) {
                if (value == null || value.toString().isEmpty) {
                  return 'First name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            FlowFormField(
              fieldName: 'lastName',
              formData: _formData,
              onChanged: _updateFormData,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                hintText: 'Enter your last name',
              ),
              validator: (value) {
                if (value == null || value.toString().isEmpty) {
                  return 'Last name is required';
                }
                return null;
              },
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
    
    final bloc = BlocProvider.of<FlowBloc<RegistrationData>>(context);
    final currentData = bloc.state.currentStep.data;
    
    final updatedData = currentData.copyWith(
      firstName: _formData.getField<String>('firstName'),
      lastName: _formData.getField<String>('lastName'),
    );
    
    bloc.updateStepData(updatedData);
    bloc.add(FlowEvent.stepValidated(isValid: _formData.isFormValid));
  }
}

// Account Details Form
class AccountDetailsForm extends StatefulWidget {
  const AccountDetailsForm({Key? key}) : super(key: key);
  
  @override
  State<AccountDetailsForm> createState() => _AccountDetailsFormState();
}

class _AccountDetailsFormState extends State<AccountDetailsForm> {
  late FormStepData _formData;
  bool _obscurePassword = true;
  
  @override
  void initState() {
    super.initState();
    _formData = FormStepData();
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: FormStepLayout(
        title: 'Account Details',
        description: 'Create your account credentials',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            const SizedBox(height: 16),
            FlowFormField(
              fieldName: 'password',
              formData: _formData,
              onChanged: _updateFormData,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Create a password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.toString().isEmpty) {
                  return 'Password is required';
                }
                if (value.toString().length < 8) {
                  return 'Password must be at least 8 characters';
                }
                return null;
              },
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
    
    final bloc = BlocProvider.of<FlowBloc<RegistrationData>>(context);
    final currentData = bloc.state.currentStep.data;
    
    final updatedData = currentData.copyWith(
      email: _formData.getField<String>('email'),
      password: _formData.getField<String>('password'),
    );
    
    bloc.updateStepData(updatedData);
    bloc.add(FlowEvent.stepValidated(isValid: _formData.isFormValid));
  }
}

// Preferences Form
class PreferencesForm extends StatefulWidget {
  const PreferencesForm({Key? key}) : super(key: key);
  
  @override
  State<PreferencesForm> createState() => _PreferencesFormState();
}

class _PreferencesFormState extends State<PreferencesForm> {
  bool _receiveNewsletter = false;
  String _selectedTheme = 'system';
  
  final List<Map<String, dynamic>> _themes = [
    {'value': 'light', 'label': 'Light Theme', 'icon': Icons.light_mode},
    {'value': 'dark', 'label': 'Dark Theme', 'icon': Icons.dark_mode},
    {'value': 'system', 'label': 'System Default', 'icon': Icons.brightness_auto},
  ];
  
  @override
  void initState() {
    super.initState();
    final bloc = BlocProvider.of<FlowBloc<RegistrationData>>(context);
    final currentData = bloc.state.currentStep.data;
    
    _receiveNewsletter = currentData.receiveNewsletter;
    _selectedTheme = currentData.preferredTheme ?? 'system';
    
    // Preferences step is always valid
    bloc.add(const FlowEvent.stepValidated(isValid: true));
  }
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferences',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Customize your experience',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          
          // Theme selection
          Text(
            'Theme',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...List.generate(_themes.length, (index) {
            final theme = _themes[index];
            return RadioListTile<String>(
              title: Text(theme['label']),
              value: theme['value'],
              groupValue: _selectedTheme,
              secondary: Icon(theme['icon']),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedTheme = value;
                  });
                  _updateData();
                }
              },
            );
          }),
          const SizedBox(height: 16),
          
          // Newsletter option
          SwitchListTile(
            title: const Text('Receive Newsletter'),
            subtitle: const Text('Get product updates and news'),
            value: _receiveNewsletter,
            onChanged: (value) {
              setState(() {
                _receiveNewsletter = value;
              });
              _updateData();
            },
          ),
        ],
      ),
    );
  }
  
  void _updateData() {
    final bloc = BlocProvider.of<FlowBloc<RegistrationData>>(context);
    final currentData = bloc.state.currentStep.data;
    
    final updatedData = currentData.copyWith(
      receiveNewsletter: _receiveNewsletter,
      preferredTheme: _selectedTheme,
    );
    
    bloc.updateStepData(updatedData);
  }
}
