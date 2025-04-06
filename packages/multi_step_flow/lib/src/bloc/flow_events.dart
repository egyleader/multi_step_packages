import 'package:meta/meta.dart';

import '../models/flow_configuration.dart';
import '../models/flow_step.dart';

/// Base flow event class
@immutable
abstract class FlowEvent {
  const FlowEvent();

  /// Flow initialized event
  const factory FlowEvent.initialized({FlowConfiguration? configuration}) =
      FlowInitialized;

  /// Next button pressed event
  const factory FlowEvent.nextPressed() = FlowNextPressed;

  /// Previous button pressed event
  const factory FlowEvent.previousPressed() = FlowPreviousPressed;

  /// Skip button pressed event
  const factory FlowEvent.skipPressed() = FlowStepSkipped;

  /// Step validated event
  const factory FlowEvent.stepValidated({required bool isValid}) =
      FlowStepValidated;

  /// Step timer completed event
  const factory FlowEvent.stepTimerCompleted() = FlowStepTimerCompleted;

  /// Step selected event
  const factory FlowEvent.stepSelected({required int index}) = FlowStepSelected;

  /// Error occurred event
  const factory FlowEvent.errorOccurred({required String message}) =
      FlowErrorOccurred;

  /// Reset flow event
  const factory FlowEvent.reset() = FlowReset;

  /// Flow completed event
  const factory FlowEvent.completed() = FlowCompleted;

  /// Loading event
  const factory FlowEvent.loading() = FlowLoading;

  /// Steps modified event
  const factory FlowEvent.stepsModified({required List<FlowStep> steps}) =
      FlowStepsModified;

  /// Step data updated event
  const factory FlowEvent.stepDataUpdated({required dynamic data}) =
      FlowStepDataUpdated;
}

/// Flow initialized event
class FlowInitialized extends FlowEvent {
  /// Optional configuration for the flow
  final FlowConfiguration? configuration;

  /// Creates a flow initialized event
  const FlowInitialized({this.configuration});
}

/// Next button pressed event
class FlowNextPressed extends FlowEvent {
  const FlowNextPressed();
}

/// Previous button pressed event
class FlowPreviousPressed extends FlowEvent {
  const FlowPreviousPressed();
}

/// Skip button pressed event
class FlowStepSkipped extends FlowEvent {
  const FlowStepSkipped();
}

/// Step validated event
class FlowStepValidated extends FlowEvent {
  /// Whether the step is valid
  final bool isValid;

  /// Creates a step validated event
  const FlowStepValidated({required this.isValid});
}

/// Step timer completed event
class FlowStepTimerCompleted extends FlowEvent {
  const FlowStepTimerCompleted();
}

/// Step selected event
class FlowStepSelected extends FlowEvent {
  /// Index of the selected step
  final int index;

  /// Creates a step selected event
  const FlowStepSelected({required this.index});
}

/// Error occurred event
class FlowErrorOccurred extends FlowEvent {
  /// Error message
  final String message;

  /// Creates an error occurred event
  const FlowErrorOccurred({required this.message});
}

/// Reset flow event
class FlowReset extends FlowEvent {
  const FlowReset();
}

/// Flow completed event
class FlowCompleted extends FlowEvent {
  const FlowCompleted();
}

/// Loading event
class FlowLoading extends FlowEvent {
  const FlowLoading();
}

/// Steps modified event
class FlowStepsModified extends FlowEvent {
  /// New list of steps
  final List<FlowStep> steps;

  /// Creates a steps modified event
  const FlowStepsModified({required this.steps});
}

/// Step data updated event
class FlowStepDataUpdated extends FlowEvent {
  /// Updated step data
  final dynamic data;

  /// Creates a step data updated event
  const FlowStepDataUpdated({required this.data});
}
