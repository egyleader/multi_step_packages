import 'dart:async';
import '../bloc/flow_bloc.dart';
import '../bloc/flow_events.dart';
import '../models/flow_configuration.dart';
import '../models/flow_status.dart';
import '../models/flow_step.dart';

/// A controller for managing multi-step flows
class FlowController {
  FlowController({
    required List<FlowStep> steps,
    FlowConfiguration? configuration,
  }) : _bloc = FlowBloc() {
    _subscription = _bloc.stream.listen(_onStateChanged);
    _initialize(steps, configuration);
  }

  final FlowBloc _bloc;
  StreamSubscription<FlowState>? _subscription;
  final _stateController = StreamController<FlowState>.broadcast();

  /// Stream of flow states
  Stream<FlowState> get stateStream => _stateController.stream;

  /// Current flow state
  FlowState get currentState => _bloc.state;

  /// Current step
  FlowStep? get currentStep => currentState.currentStep;

  /// Whether there is a next step
  bool get hasNext => currentState.hasNext;

  /// Whether there is a previous step
  bool get hasPrevious => currentState.hasPrevious;

  /// Whether the flow is complete
  bool get isComplete => currentState.isComplete;

  void _initialize(List<FlowStep> steps, FlowConfiguration? configuration) {
    _bloc.add(FlowInitialized(
      steps: steps,
      configuration: configuration ?? const FlowConfiguration(),
    ));
  }

  void _onStateChanged(FlowState state) {
    _stateController.add(state);
  }

  /// Move to the next step
  void next() {
    _bloc.add(const FlowNextPressed());
  }

  /// Move to the previous step
  void previous() {
    _bloc.add(const FlowPreviousPressed());
  }

  /// Skip the current step
  void skip() {
    _bloc.add(const FlowStepSkipped());
  }

  /// Mark the current step as validated
  void validate(bool isValid) {
    _bloc.add(FlowStepValidated(isValid: isValid));
  }

  /// Jump to a specific step by index
  void goToStep(int index) {
    _bloc.add(FlowStepSelected(index));
  }

  /// Reset the flow to its initial state
  void reset() {
    _bloc.add(const FlowReset());
  }

  /// Complete the flow
  void complete() {
    _bloc.add(const FlowCompleted());
  }

  /// Report an error
  void reportError(String error) {
    _bloc.add(FlowErrorOccurred(error));
  }

  /// Dispose the controller
  Future<void> dispose() async {
    await _subscription?.cancel();
    await _stateController.close();
    await _bloc.close();
  }
}
