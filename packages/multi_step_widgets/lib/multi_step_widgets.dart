/// Multi-step flow UI components
///
/// This library provides widgets for building multi-step flows, forms, and wizards.
/// It integrates with the multi_step_flow package for state management.
library;

// Flow building
export 'src/flow_builder.dart';

// Indicators
export 'src/indicators/base_indicator.dart';
export 'src/indicators/dots_indicator.dart';

// Navigation
export 'src/navigation/flow_navigation_bar.dart';
export 'src/navigation/navigation_button.dart';

// Layouts
export 'src/layouts/flow_layout.dart';

// Form
export 'src/form/form_field.dart';
export 'src/form/form_step.dart';

// Information
export 'src/information/information_step.dart';

// Themes
export 'src/theme/flow_theme.dart';
export 'src/theme/indicator_theme.dart';

// Re-export types from multi_step_flow
export 'package:multi_step_flow/multi_step_flow.dart'
    show
        // Models
        FlowStep,
        FlowState,
        FlowConfiguration,
        FlowStatus,
        FormStepData,
        InformationStepData,
        // Controllers
        FlowController,
        // BLoC
        FlowBloc,
        FlowEvent;
