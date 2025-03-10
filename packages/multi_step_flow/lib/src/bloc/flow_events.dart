import 'package:equatable/equatable.dart';
import '../models/flow_step.dart';
import '../models/flow_configuration.dart';

/// Base class for all flow events
abstract class FlowEvent extends Equatable {
  const FlowEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize the flow with steps and configuration
class FlowInitialized extends FlowEvent {
  const FlowInitialized({
    required this.steps,
    this.configuration = const FlowConfiguration(),
  });

  final List<FlowStep> steps;
  final FlowConfiguration configuration;

  @override
  List<Object?> get props => [steps, configuration];
}

/// Event to move to the next step
class FlowNextPressed extends FlowEvent {
  const FlowNextPressed();
}

/// Event to move to the previous step
class FlowPreviousPressed extends FlowEvent {
  const FlowPreviousPressed();
}

/// Event to skip the current step
class FlowStepSkipped extends FlowEvent {
  const FlowStepSkipped();
}

/// Event when step validation completes
class FlowStepValidated extends FlowEvent {
  const FlowStepValidated({required this.isValid});

  final bool isValid;

  @override
  List<Object?> get props => [isValid];
}

/// Event when step timer completes
class FlowStepTimerCompleted extends FlowEvent {
  const FlowStepTimerCompleted();
}

/// Event to jump to a specific step
class FlowStepSelected extends FlowEvent {
  const FlowStepSelected(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

/// Event when an error occurs
class FlowErrorOccurred extends FlowEvent {
  const FlowErrorOccurred(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}

/// Event to reset the flow
class FlowReset extends FlowEvent {
  const FlowReset();
}

/// Event to complete the flow
class FlowCompleted extends FlowEvent {
  const FlowCompleted();
}
