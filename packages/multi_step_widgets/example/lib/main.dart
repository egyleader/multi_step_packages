import 'package:flutter/material.dart';
import 'package:multi_step_flow/multi_step_flow.dart';
import 'package:multi_step_widgets/multi_step_widgets.dart';

/// A comprehensive example showing various features of multi_step_flow and multi_step_widgets
/// including different step types, validation, navigation controls, and themes.
void main() {
  runApp(const ComprehensiveExample());
}

class ComprehensiveExample extends StatelessWidget {
  const ComprehensiveExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-Step Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        // Apply FlowTheme as an extension to the theme
        extensions: const [
          FlowTheme(
            stepIndicatorTheme: StepIndicatorThemeData(
              activeColor: Colors.indigo,
              inactiveColor: Colors.grey,
              completedColor: Colors.green,
              size: 14,
              spacing: 8,
            ),
            transitionDuration: Duration(milliseconds: 300),
          ),
        ],
      ),
      home: const OnboardingFlow(),
    );
  }
}

/// Example of a complete onboarding flow
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  late FlowController controller;
  bool showNavigationBar = true;
  // Map to store custom button text for each step
  final Map<String, String> stepButtonText = {
    'welcome': 'Get Started',
    'profile': 'Save Profile',
    'notifications': 'Set Preferences',
    'account_connection': 'Connect',
    'summary': 'Finish'
  };

  @override
  void initState() {
    super.initState();
    // Initialize the flow controller with different step types
    controller = FlowController(
      steps: [
        WelcomeStep(),
        ProfileSetupStep(),
        NotificationsStep(isSkippable: true),
        AccountConnectionStep(
          isSkippable: true,
          data: {
            'services': ['Google', 'Apple', 'Facebook'],
          },
        ),
        SummaryStep(),
      ],
      configuration: const FlowConfiguration(
        allowBackNavigation: true,
        validateOnStepChange: true,
        autoAdvanceOnValidation: false,
        showStepIndicator: true,
      ),
    );
    
    // Set controller reference for steps that need it
    for (final step in controller.currentState.steps) {
      if (step is NotificationsStep) {
        (step as NotificationsStep).setController(controller);
      } else if (step is AccountConnectionStep) {
        (step as AccountConnectionStep).setController(controller);
      }
    }

    // Mark the welcome step as valid immediately after controller initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.validate(true);
    });

    // Listen to flow state changes
    controller.stateStream.listen(_onStateChanged);

    // Listen to flow errors
    controller.errorStream.listen(_onError);
  }

  void _onStateChanged(FlowState state) {
    if (state.status == FlowStatus.completed) {
      // Handle flow completion
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Setup Complete!'),
            content: const Text(
              'You have successfully completed the onboarding.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _onError(String error) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<FlowState>(
          stream: controller.stateStream,
          initialData: controller.currentState,
          builder: (context, snapshot) {
            final step = snapshot.data!.currentStep;
            return Text(step?.title ?? 'Onboarding');
          },
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Main content area with step transitions
          Expanded(
            child: FlowBuilder(
              controller: controller,
              stepBuilder: (context, step) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: step as Widget,
                );
              },
              // Disable horizontal scrolling
              physics: const NeverScrollableScrollPhysics(),
              indicator: DotsIndicator(
                state: controller.currentState,
                onStepTapped: (index) => controller.goToStep(index),
              ),
              transitionBuilder: (context, child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.2, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
            ),
          ),

          // Navigation bar with custom labels per step
          StreamBuilder<FlowState>(
            stream: controller.stateStream,
            initialData: controller.currentState,
            builder: (context, snapshot) {
              final state = snapshot.data!;
              final currentStepId = state.currentStep?.id ?? '';
              
              // Hide next/complete button on the final Summary step
              final isSummaryStep = currentStepId == 'summary';
              
              // Don't show navigation bar at all on summary step
              if (isSummaryStep) {
                return const SizedBox.shrink();
              }
              
              return FlowNavigationBar(
                controller: controller,
                nextLabel: Text(stepButtonText[currentStepId] ?? 'Continue'),
                previousLabel: const Text('Back'),
                skipLabel: const Text('Skip'),
                showSkip: true,
                showNextButton: true,
                backgroundColor: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Welcome step with basic information
class WelcomeStep extends StatelessWidget implements FlowStep {
  WelcomeStep({Map<String, dynamic>? data})
      : id = 'welcome',
        title = 'Welcome',
        description = 'Welcome to the multi-step flow demo',
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
  Future<void> onEnter() async {
    debugPrint('Entering welcome step');
  }

  @override
  Future<void> onExit() async {
    debugPrint('Exiting welcome step');
  }

  @override
  Future<void> onSkip() async {
    // This won't be called since step isn't skippable
  }

  @override
  Future<bool> validate() async {
    // Always return true to keep the "Continue" button enabled
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
    return WelcomeStep(data: data ?? this.data);
  }

  @override
  T? getValue<T>(String key, [T? defaultValue]) {
    return data?[key] as T? ?? defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.waving_hand, size: 80, color: Colors.amber),
          const SizedBox(height: 24),
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Text(
            description!,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          const Text(
            'This example demonstrates different types of steps, validation, and navigation controls provided by multi_step_flow and multi_step_widgets packages.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Profile setup step with form validation
class ProfileSetupStep extends StatefulWidget implements FlowStep {
  ProfileSetupStep({Map<String, dynamic>? data})
      : id = 'profile',
        title = 'Profile Setup',
        description = 'Tell us about yourself',
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
  State<ProfileSetupStep> createState() => _ProfileSetupStepState();

  @override
  Future<void> onEnter() async {
    debugPrint('Entering profile step');
  }

  @override
  Future<void> onExit() async {
    debugPrint('Exiting profile step');
  }

  @override
  Future<void> onSkip() async {
    // This won't be called since step isn't skippable
  }

  @override
  Future<bool> validate() async {
    // The state will handle validation
    final formIsValid = _ProfileSetupStepState.formKey.currentState?.validate() ?? false;
    return formIsValid;
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
    return ProfileSetupStep(data: data ?? this.data);
  }

  @override
  T? getValue<T>(String key, [T? defaultValue]) {
    return data?[key] as T? ?? defaultValue;
  }
}

class _ProfileSetupStepState extends State<ProfileSetupStep> {
  static final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  bool isFormValid = false;

  @override
  void initState() {
    super.initState();
    // Initial validation when the widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateForm();
    });
  }

  void _validateForm() {
    if (!mounted) return;
    
    final valid = formKey.currentState?.validate() ?? false;
    if (valid != isFormValid) {
      setState(() {
        isFormValid = valid;
      });
      
      // Try to find the flow controller in the widget tree
      final flowState = context.findAncestorStateOfType<_OnboardingFlowState>();
      if (flowState != null) {
        // Let the controller know about validation status
        flowState.controller.validate(isFormValid);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (widget.description != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                child: Text(widget.description!),
              ),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your full name',
                border: OutlineInputBorder(),
                filled: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
              onChanged: (_) => _validateForm(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email address',
                border: OutlineInputBorder(),
                filled: true,
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
              onChanged: (_) => _validateForm(),
            ),
            const SizedBox(height: 24),
            const Text(
              'This step demonstrates form validation. Both fields must be valid to proceed.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}

/// Notifications step with toggle options
class NotificationsStep extends StatefulWidget implements FlowStep {
  NotificationsStep({
    this.isSkippable = true,
    Map<String, dynamic>? data,
  })  : id = 'notifications',
        title = 'Notification Preferences',
        description = 'Choose which notifications you want to receive',
        timeLimit = null,
        data = data ?? {};

  // Controller reference for validation
  FlowController? _controller;
  
  void setController(FlowController controller) {
    _controller = controller;
  }
  
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
  State<NotificationsStep> createState() => _NotificationsStepState();

  @override
  Future<void> onEnter() async {
    debugPrint('Entering notifications step');
  }

  @override
  Future<void> onExit() async {
    debugPrint('Exiting notifications step');
  }

  @override
  Future<void> onSkip() async {
    debugPrint('Skipping notifications step');
  }

  @override
  Future<bool> validate() async {
    // Step is valid only if at least one notification option is enabled
    return _NotificationsStepState.enablePush || 
           _NotificationsStepState.enableEmail || 
           _NotificationsStepState.enableInApp;
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
    final step = NotificationsStep(
      isSkippable: isSkippable ?? this.isSkippable,
      data: data ?? this.data,
    );
    if (_controller != null) {
      step.setController(_controller!);
    }
    return step;
  }

  @override
  T? getValue<T>(String key, [T? defaultValue]) {
    return data?[key] as T? ?? defaultValue;
  }
}

class _NotificationsStepState extends State<NotificationsStep> {
  // Static state for validation access
  static bool enablePush = false;
  static bool enableEmail = false;
  static bool enableInApp = false;
  
  @override
  void initState() {
    super.initState();
    // All notifications start disabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateValidationState();
    });
  }
  
  void _updateValidationState() {
    final isValid = enablePush || enableEmail || enableInApp;
    
    if (widget._controller != null) {
      widget._controller!.validate(isValid);
    } else {
      // Find the flow controller in the widget tree
      final flowState = context.findAncestorStateOfType<_OnboardingFlowState>();
      if (flowState != null) {
        flowState.controller.validate(isValid);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: Theme.of(context).textTheme.headlineMedium),
          if (widget.description != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              child: Text(widget.description!),
            ),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive notifications on your device'),
            value: enablePush,
            onChanged: (value) {
              setState(() {
                enablePush = value;
                _updateValidationState();
              });
            },
          ),
          SwitchListTile(
            title: const Text('Email Notifications'),
            subtitle: const Text('Receive updates via email'),
            value: enableEmail,
            onChanged: (value) {
              setState(() {
                enableEmail = value;
                _updateValidationState();
              });
            },
          ),
          SwitchListTile(
            title: const Text('In-App Notifications'),
            subtitle: const Text('See notifications within the app'),
            value: enableInApp,
            onChanged: (value) {
              setState(() {
                enableInApp = value;
                _updateValidationState();
              });
            },
          ),
          const SizedBox(height: 24),
          // Instruction text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber),
                    SizedBox(width: 8),
                    Text(
                      'Instructions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'You need to enable at least one notification type to continue.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                if (widget.isSkippable)
                  const Text(
                    'Alternatively, you can skip this step if you prefer.',
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Account connection step with service selection
class AccountConnectionStep extends StatefulWidget implements FlowStep {
  AccountConnectionStep({this.isSkippable = true, Map<String, dynamic>? data})
      : id = 'account_connection',
        title = 'Connect Accounts',
        description = 'Connect your other accounts for a better experience',
        timeLimit = null,
        data = data ?? {'services': []};
        
  // Controller reference for validation
  FlowController? _controller;
  
  void setController(FlowController controller) {
    _controller = controller;
  }

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
  State<AccountConnectionStep> createState() => _AccountConnectionStepState();

  @override
  Future<void> onEnter() async {
    debugPrint('Entering account connection step');
  }

  @override
  Future<void> onExit() async {
    debugPrint('Exiting account connection step');
  }

  @override
  Future<void> onSkip() async {
    debugPrint('Skipping account connection step');
  }

  @override
  Future<bool> validate() async {
    // Valid only if at least one account is connected
    return _AccountConnectionStepState.hasConnectedService;
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
    return AccountConnectionStep(
      isSkippable: isSkippable ?? this.isSkippable,
      data: data ?? this.data,
    );
  }

  @override
  T? getValue<T>(String key, [T? defaultValue]) {
    return data?[key] as T? ?? defaultValue;
  }
}

class _AccountConnectionStepState extends State<AccountConnectionStep> {
  final Map<String, bool> selectedServices = {};
  static bool hasConnectedService = false;

  @override
  void initState() {
    super.initState();
    final services = widget.getValue<List<dynamic>>('services') ?? [];
    for (final service in services) {
      selectedServices[service.toString()] = false;
    }
    
    // Set initial validation state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateValidationState();
    });
  }
  
  void _updateValidationState() {
    // Check if any service is connected
    final anyConnected = selectedServices.values.any((connected) => connected);
    if (anyConnected != hasConnectedService) {
      setState(() {
        hasConnectedService = anyConnected;
      });
      
      // Update validation in controller
      if (widget._controller != null) {
        widget._controller!.validate(anyConnected);
      } else {
        final flowState = context.findAncestorStateOfType<_OnboardingFlowState>();
        if (flowState != null) {
          flowState.controller.validate(anyConnected);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.headlineMedium),
        if (widget.description != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            child: Text(widget.description!),
          ),
        ...selectedServices.entries.map(
          (entry) => _buildServiceTile(entry.key),
        ),
        if (selectedServices.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No services available to connect'),
            ),
          ),
        const SizedBox(height: 24),
        // Instruction text
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber),
                  SizedBox(width: 8),
                  Text(
                    'Instructions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'You need to connect at least one account to continue.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              if (widget.isSkippable)
                const Text(
                  'Alternatively, you can skip this step if you prefer.',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (widget.isSkippable)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'This step is optional - you can skip it if you prefer.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }

  Widget _buildServiceTile(String service) {
    IconData icon;
    Color color;

    switch (service) {
      case 'Google':
        icon = Icons.g_mobiledata;
        color = Colors.red;
        break;
      case 'Apple':
        icon = Icons.apple;
        color = Colors.black87;
        break;
      case 'Facebook':
        icon = Icons.facebook;
        color = Colors.blue;
        break;
      default:
        icon = Icons.account_circle;
        color = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text('Connect with $service'),
        trailing: selectedServices[service] == true
            ? const Icon(Icons.check_circle, color: Colors.green)
            : OutlinedButton(
                onPressed: () {
                  setState(() {
                    selectedServices[service] = true;
                    _updateValidationState();
                  });
                },
                child: const Text('Connect'),
              ),
      ),
    );
  }
}

/// Summary step to complete the flow
class SummaryStep extends StatelessWidget implements FlowStep {
  SummaryStep({Map<String, dynamic>? data})
      : id = 'summary',
        title = 'Summary',
        description = 'You\'re all set!',
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
  Future<void> onEnter() async {
    debugPrint('Entering summary step');
  }

  @override
  Future<void> onExit() async {
    debugPrint('Exiting summary step');
  }

  @override
  Future<void> onSkip() async {
    // This won't be called since step isn't skippable
  }

  @override
  Future<bool> validate() async {
    return true; // Always valid
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
    return SummaryStep(data: data ?? this.data);
  }

  @override
  T? getValue<T>(String key, [T? defaultValue]) {
    return data?[key] as T? ?? defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
          const SizedBox(height: 24),
          Text(
            'Setup Complete',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          const Text(
            'Thank you for completing the onboarding flow.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          const Text(
            'This is the end of the comprehensive example that demonstrates the features of the multi_step_flow and multi_step_widgets packages.',
            textAlign: TextAlign.center,
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // In a real app, you might navigate to the main app screen
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Example Complete'),
                  content: const Text(
                    'In a real app, this would navigate to the main app screen.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.rocket_launch),
            label: const Text('Get Started'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
