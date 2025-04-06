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
        // Make the first step skippable so Next is enabled
        isSkippable: true,
        data: RegistrationData(
          firstName: '',
          lastName: '',
        ),
      ),
      FlowStep<RegistrationData>(
        id: 'account',
        title: 'Account Details',
        data: RegistrationData(
          email: '',
          password: '',
        ),
      ),
      FlowStep<RegistrationData>(
        id: 'preferences',
        title: 'Preferences',
        isSkippable: true,
        data: RegistrationData(
          receiveNewsletter: false,
          preferredTheme: 'system',
        ),
      ),
    ];

    // Initialize the bloc
    _bloc = FlowBloc<RegistrationData>(steps: steps);
    
    // Make sure the first step is valid so the Next button is enabled
    _bloc.validateStep(true);
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
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    // Initialize from current step data if available
    final bloc = BlocProvider.of<FlowBloc<RegistrationData>>(context, listen: false);
    final currentData = bloc.state.currentStep.data;
    _firstName = currentData.firstName ?? '';
    _lastName = currentData.lastName ?? '';
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Please enter your name',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            onChanged: _validateForm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  initialValue: _firstName,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    hintText: 'Enter your first name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'First name is required';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _firstName = value;
                    });
                    _updateData();
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _lastName,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    hintText: 'Enter your last name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Last name is required';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _lastName = value;
                    });
                    _updateData();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    setState(() {
      _isValid = isValid;
    });
    
    // Update validation status in the bloc
    final bloc = BlocProvider.of<FlowBloc<RegistrationData>>(context);
    bloc.validateStep(_isValid);
  }
  
  void _updateData() {
    final bloc = BlocProvider.of<FlowBloc<RegistrationData>>(context);
    final currentData = bloc.state.currentStep.data;
    
    final updatedData = currentData.copyWith(
      firstName: _firstName,
      lastName: _lastName,
    );
    
    bloc.updateStepData(updatedData);
  }
}

// Account Details Form
class AccountDetailsForm extends StatefulWidget {
  const AccountDetailsForm({Key? key}) : super(key: key);
  
  @override
  State<AccountDetailsForm> createState() => _AccountDetailsFormState();
}

class _AccountDetailsFormState extends State<AccountDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _obscurePassword = true;
  bool _isValid = false;
  
  @override
  void initState() {
    super.initState();
    // Initialize from current step data if available
    final bloc = BlocProvider.of<FlowBloc<RegistrationData>>(context, listen: false);
    final currentData = bloc.state.currentStep.data;
    _email = currentData.email ?? '';
    _password = currentData.password ?? '';
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Details',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your account credentials',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            onChanged: _validateForm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  initialValue: _email,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@')) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    setState(() {
                      _email = value;
                    });
                    _updateData();
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _password,
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
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _password = value;
                    });
                    _updateData();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    setState(() {
      _isValid = isValid;
    });
    
    // Update validation status in the bloc
    final bloc = BlocProvider.of<FlowBloc<RegistrationData>>(context);
    bloc.validateStep(_isValid);
  }
  
  void _updateData() {
    final bloc = BlocProvider.of<FlowBloc<RegistrationData>>(context);
    final currentData = bloc.state.currentStep.data;
    
    final updatedData = currentData.copyWith(
      email: _email,
      password: _password,
    );
    
    bloc.updateStepData(updatedData);
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
    bloc.validateStep(true);
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
