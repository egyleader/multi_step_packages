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
        primarySwatch: Colors.blue,
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
        AccountDetailsStep(),
        PreferencesStep(),
      ],
      configuration: const FlowConfiguration(
        validateOnStepChange: true,
        autoAdvanceOnValidation: true,
      ),
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
  PersonalInfoStep()
      : id = 'personal_info',
        title = 'Personal Information',
        description = 'Enter your personal details',
        isSkippable = false;

  @override
  final String id;

  @override
  final String title;

  @override
  final String? description;

  @override
  final bool isSkippable;

  @override
  Duration? get timeLimit => null;

  @override
  State<PersonalInfoStep> createState() => _PersonalInfoStepState();

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
  }) {
    return PersonalInfoStep();
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
  AccountDetailsStep()
      : id = 'account_details',
        title = 'Account Details',
        description = 'Set up your account',
        isSkippable = false;

  @override
  final String id;

  @override
  final String title;

  @override
  final String? description;

  @override
  final bool isSkippable;

  @override
  Duration? get timeLimit => null;

  @override
  State<AccountDetailsStep> createState() => _AccountDetailsStepState();

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
  }) {
    return AccountDetailsStep();
  }
}

class _AccountDetailsStepState extends State<AccountDetailsStep> {
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
  PreferencesStep()
      : id = 'preferences',
        title = 'Preferences',
        description = 'Set your preferences',
        isSkippable = true;

  @override
  final String id;

  @override
  final String title;

  @override
  final String? description;

  @override
  final bool isSkippable;

  @override
  Duration? get timeLimit => null;

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
  }) {
    return PreferencesStep();
  }
}

class _PreferencesStepState extends State<PreferencesStep> {
  bool _receiveNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          title: const Text('Receive Notifications'),
          value: _receiveNotifications,
          onChanged: (value) {
            setState(() {
              _receiveNotifications = value;
            });
          },
        ),
      ],
    );
  }
}
