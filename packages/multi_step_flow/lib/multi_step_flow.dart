/// A Flutter package for creating customizable multi-step flows
///
/// This package provides a state management solution for multi-step flows and forms.
/// It handles navigation between steps, validation, data persistence, and more.
library;

// Core models
export 'src/models/flow_configuration.dart';
export 'src/models/flow_status.dart';
export 'src/models/flow_state_model.dart';
export 'src/models/flow_step.dart';
export 'src/models/form_step_data.dart';
export 'src/models/information_step_data.dart';

// Bloc and events
export 'src/bloc/flow_bloc.dart';
export 'src/bloc/flow_events.dart';

// Extensions
export 'src/extensions/step_extensions.dart';

// Utilities
export 'src/utils/json_converters.dart';
