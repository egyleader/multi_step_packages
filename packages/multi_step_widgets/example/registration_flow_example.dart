import 'package:flutter/material.dart';
import 'package:multi_step_flow/multi_step_flow.dart';
import 'package:multi_step_widgets/multi_step_widgets.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registration Flow Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        extensions: const [
          FlowTheme(
            stepIndicatorTheme: StepIndicatorThemeData(
              activeColor: Colors.blue,
              inactiveColor: Colors.grey,
              completedColor: Colors.green,
              size: 12,
              spacing: 8,
            ),
          ),
        ],
      ),
      home: const RegistrationScreen(),
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late FlowController controller;

  @override
  void initState() {
    super.initState();
    controller = FlowController(
      steps: [
        PersonalInfoStep(),
        AccountDetailsStep(data: {'requirePassword': true}),
        PreferencesStep(
          isSkippable: true,
          data: {
            'options': ['notifications', 'marketing', 'analytics'],
          },
        ),
      ],
      configuration: const FlowConfiguration(validateOnStepChange: true),
    );

    // Listen for errors
    controller.errorStream.listen((error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $error')));
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registration')),
      body: FlowLayout(
        controller: controller,
        stepBuilder: (context, step) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: step as Widget,
          );
        },
      ),
    );
  }
}

class PersonalInfoStep extends StatefulWidget implements FlowStep {
  PersonalInfoStep({super.key, Map<String, dynamic>? data})
    : id = 'personal_info',
      title = 'Personal Information',
      description = 'Enter your personal details',
      isSkippable = false,
      timeLimit = null,
      data = data ?? {};

  @override
  final String id;

  @override
  final String title;

  @override
  final String? description;

  @override
  final bool isSkippable;

  @override
  final Duration? timeLimit;

  @override
  final Map<String, dynamic>? data;

  @override
  State<PersonalInfoStep> createState() => _PersonalInfoStepState();

  @override
  Future<void> onEnter() async {}

  @override
  Future<void> onExit() async {}

  @override
  Future<void> onSkip() async {}

  @override
  Future<bool> validate() async {
    // Simple validation - could integrate with Formz here
    return true;
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
    return PersonalInfoStep(data: data ?? this.data);
  }

  @override
  T? getValue<T>(String key, [T? defaultValue]) {
    return data?[key] as T? ?? defaultValue;
  }
}

class _PersonalInfoStepState extends State<PersonalInfoStep> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.headlineMedium),
        if (widget.description != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              widget.description!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        const SizedBox(height: 24),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}

class AccountDetailsStep extends StatefulWidget implements FlowStep {
  AccountDetailsStep({super.key, Map<String, dynamic>? data})
    : id = 'account_details',
      title = 'Account Details',
      description = 'Set up your account',
      isSkippable = false,
      timeLimit = null,
      data = data ?? {};

  @override
  final String id;

  @override
  final String title;

  @override
  final String? description;

  @override
  final bool isSkippable;

  @override
  final Duration? timeLimit;

  @override
  final Map<String, dynamic>? data;

  @override
  State<AccountDetailsStep> createState() => _AccountDetailsStepState();

  @override
  Future<void> onEnter() async {}

  @override
  Future<void> onExit() async {}

  @override
  Future<void> onSkip() async {}

  @override
  Future<bool> validate() async {
    // Example of using step data to conditionally validate
    final requirePassword = getValue<bool>('requirePassword') ?? false;
    if (requirePassword) {
      // In a real app, we would check if password is valid
      return true;
    }
    return true;
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
    return AccountDetailsStep(data: data ?? this.data);
  }

  @override
  T? getValue<T>(String key, [T? defaultValue]) {
    return data?[key] as T? ?? defaultValue;
  }
}

class _AccountDetailsStepState extends State<AccountDetailsStep> {
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final requirePassword = widget.getValue<bool>('requirePassword') ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.headlineMedium),
        if (widget.description != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              widget.description!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        const SizedBox(height: 24),
        if (requirePassword)
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
      ],
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}

class PreferencesStep extends StatefulWidget implements FlowStep {
  PreferencesStep({
    super.key,
    bool isSkippable = true,
    Map<String, dynamic>? data,
  }) : id = 'preferences',
       title = 'Preferences',
       description = 'Set your preferences',
       isSkippable = isSkippable,
       timeLimit = null,
       data = data ?? {};

  @override
  final String id;

  @override
  final String title;

  @override
  final String? description;

  @override
  final bool isSkippable;

  @override
  final Duration? timeLimit;

  @override
  final Map<String, dynamic>? data;

  @override
  State<PreferencesStep> createState() => _PreferencesStepState();

  @override
  Future<void> onEnter() async {}

  @override
  Future<void> onExit() async {}

  @override
  Future<void> onSkip() async {}

  @override
  Future<bool> validate() async => true;

  @override
  FlowStep copyWith({
    String? id,
    String? title,
    String? description,
    bool? isSkippable,
    Duration? timeLimit,
    Map<String, dynamic>? data,
  }) {
    return PreferencesStep(
      isSkippable: isSkippable ?? this.isSkippable,
      data: data ?? this.data,
    );
  }

  @override
  T? getValue<T>(String key, [T? defaultValue]) {
    return data?[key] as T? ?? defaultValue;
  }
}

class _PreferencesStepState extends State<PreferencesStep> {
  final _preferences = <String, bool>{};

  @override
  void initState() {
    super.initState();
    final options = widget.getValue<List<dynamic>>('options') ?? [];
    for (final option in options) {
      _preferences[option.toString()] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.headlineMedium),
        if (widget.description != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              widget.description!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        const SizedBox(height: 24),
        ..._preferences.entries.map(
          (entry) => SwitchListTile(
            title: Text(_formatOptionName(entry.key)),
            value: entry.value,
            onChanged: (value) {
              setState(() {
                _preferences[entry.key] = value;
              });
            },
          ),
        ),
        if (_preferences.isEmpty)
          const Center(child: Text('No preference options available')),
        if (widget.isSkippable)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text('This step is optional - you can skip it'),
          ),
      ],
    );
  }

  String _formatOptionName(String name) {
    return name.replaceFirst(name[0], name[0].toUpperCase());
  }
}
