import 'dart:async';

import 'package:bloc/bloc.dart';

import '../models/flow_configuration.dart';
import '../models/flow_state_model.dart';
import '../models/flow_status.dart';
import '../models/flow_step.dart';
import 'flow_events.dart';

/// Bloc for managing a multi-step flow
class FlowBloc<TStepData> extends Bloc<FlowEvent, FlowState<TStepData>> {
  /// The steps in the flow
  late List<FlowStep<TStepData>> _steps;

  /// The configuration for the flow
  FlowConfiguration _configuration;

  /// Timer for timed steps
  Timer? _timer;

  /// Creates a new flow bloc with the given steps and configuration
  FlowBloc({
    required List<FlowStep<TStepData>> steps,
    FlowConfiguration? configuration,
  }) : _steps = steps,
       _configuration = configuration ?? FlowConfiguration(),
       super(FlowState<TStepData>(steps: steps, status: FlowStatus.initial)) {
    // Set up event handlers
    on<FlowInitialized>(_onFlowInitialized);
    on<FlowNextPressed>(_onFlowNextPressed);
    on<FlowPreviousPressed>(_onFlowPreviousPressed);
    on<FlowStepSkipped>(_onFlowStepSkipped);
    on<FlowStepValidated>(_onFlowStepValidated);
    on<FlowStepTimerCompleted>(_onFlowStepTimerCompleted);
    on<FlowStepSelected>(_onFlowStepSelected);
    on<FlowErrorOccurred>(_onFlowErrorOccurred);
    on<FlowReset>(_onFlowReset);
    on<FlowCompleted>(_onFlowCompleted);
    on<FlowLoading>(_onFlowLoading);
    on<FlowStepsModified>(_onFlowStepsModified);
    on<FlowStepDataUpdated>(_onFlowStepDataUpdated);

    // Start the flow
    add(FlowInitialized(configuration: configuration));
  }

  FlowStep<TStepData> get currentStep => state.currentStep;

  FlowState<TStepData> get currentState => state;

  List<FlowStep<TStepData>> get steps => _steps;

  FlowConfiguration get configuration => _configuration;

  // Update a step's data
  void updateStepData(TStepData data) {
    add(FlowStepDataUpdated(data: data));
  }

  Future<void> _onFlowInitialized(
    FlowInitialized event,
    Emitter<FlowState<TStepData>> emit,
  ) async {
    if (event.configuration != null) {
      _configuration = event.configuration!;
    }

    // Update the state with the new configuration
    emit(
      FlowState<TStepData>(
        steps: _steps,
        status: _configuration.persistState ? state.status : FlowStatus.initial,
      ),
    );

    // Start timer for this step if it has a time limit
    _startStepTimer();

    // Call the onEnter method for the current step
    await _executeCurrentStepCallback((step) => step.onEnter());
  }

  Future<void> _onFlowNextPressed(
    FlowNextPressed event,
    Emitter<FlowState<TStepData>> emit,
  ) async {
    // Cancel any existing timer
    _cancelStepTimer();

    // Validate the current step if required by the configuration
    if (_configuration.validateOnTransition) {
      final isValid = await state.currentStep.validate();
      if (!isValid) {
        emit(state.copyWith(status: FlowStatus.invalid));
        return;
      }
    }

    // If this is the last step, complete the flow
    if (!state.hasNext) {
      // Call exit callback for current step
      await _executeCurrentStepCallback((step) => step.onExit());

      // Emit the completed state
      emit(state.copyWith(status: FlowStatus.completed));

      // Fire completion event
      add(const FlowCompleted());

      return;
    }

    // Call exit callback for current step
    await _executeCurrentStepCallback((step) => step.onExit());

    // Move to the next step
    final nextStepIndex = state.currentStepIndex + 1;
    emit(
      state.copyWith(
        currentStepIndex: nextStepIndex,
        status: FlowStatus.inProgress,
      ),
    );

    // Call enter callback for the new step
    await _executeCurrentStepCallback((step) => step.onEnter());

    // Start timer for this step if it has a time limit
    _startStepTimer();
  }

  Future<void> _onFlowPreviousPressed(
    FlowPreviousPressed event,
    Emitter<FlowState<TStepData>> emit,
  ) async {
    if (!state.hasPrevious) return;

    // Cancel any existing timer
    _cancelStepTimer();

    // Call exit callback for current step
    await _executeCurrentStepCallback((step) => step.onExit());

    // Move to previous step
    final prevStepIndex = state.currentStepIndex - 1;
    emit(
      state.copyWith(
        currentStepIndex: prevStepIndex,
        status: FlowStatus.inProgress,
      ),
    );

    // Call enter callback for the new step
    await _executeCurrentStepCallback((step) => step.onEnter());

    // Start timer for this step if it has a time limit
    _startStepTimer();
  }

  Future<void> _onFlowStepSkipped(
    FlowStepSkipped event,
    Emitter<FlowState<TStepData>> emit,
  ) async {
    if (!state.currentStep.isSkippable) return;

    // Cancel any existing timer
    _cancelStepTimer();

    // Call skip callback for current step
    await _executeCurrentStepCallback((step) => step.onSkip());

    // If this is the last step, complete the flow
    if (!state.hasNext) {
      // Emit the completed state
      emit(
        state.copyWith(
          status: FlowStatus.completed,
          skippedSteps: {...state.skippedSteps, state.currentStep.id},
        ),
      );

      // Fire completion event
      add(const FlowCompleted());

      return;
    }

    // Move to the next step
    final nextStepIndex = state.currentStepIndex + 1;
    emit(
      state.copyWith(
        currentStepIndex: nextStepIndex,
        status: FlowStatus.inProgress,
        skippedSteps: {
          ...state.skippedSteps,
          state.steps[state.currentStepIndex].id,
        },
      ),
    );

    // Call enter callback for the new step
    await _executeCurrentStepCallback((step) => step.onEnter());

    // Start timer for this step if it has a time limit
    _startStepTimer();
  }

  Future<void> _onFlowStepValidated(
    FlowStepValidated event,
    Emitter<FlowState<TStepData>> emit,
  ) async {
    final isValid = event.isValid;
    final currentStepId = state.currentStep.id;

    if (isValid) {
      // Add to validated steps
      final validatedSteps = {...state.validatedSteps, currentStepId};

      emit(
        state.copyWith(
          validatedSteps: validatedSteps,
          status: FlowStatus.valid,
        ),
      );

      // If auto advance is enabled, move to next step automatically
      if (_configuration.autoAdvanceOnValidation && state.hasNext) {
        add(const FlowNextPressed());
      }
    } else {
      // Remove from validated steps if it exists
      final validatedSteps = {...state.validatedSteps};
      validatedSteps.remove(currentStepId);

      emit(
        state.copyWith(
          validatedSteps: validatedSteps,
          status: FlowStatus.invalid,
        ),
      );
    }
  }

  Future<void> _onFlowStepTimerCompleted(
    FlowStepTimerCompleted event,
    Emitter<FlowState<TStepData>> emit,
  ) async {
    // Move to the next step automatically
    if (state.hasNext) {
      add(const FlowNextPressed());
    } else {
      // This is the last step, complete the flow
      add(const FlowCompleted());
    }
  }

  Future<void> _onFlowStepSelected(
    FlowStepSelected event,
    Emitter<FlowState<TStepData>> emit,
  ) async {
    final selectedIndex = event.index;

    // Validate index is within bounds
    if (selectedIndex < 0 || selectedIndex >= _steps.length) {
      emit(
        state.copyWith(
          status: FlowStatus.error,
          error: 'Invalid step index: $selectedIndex',
        ),
      );
      return;
    }

    // If trying to navigate directly to the same step, do nothing
    if (selectedIndex == state.currentStepIndex) return;

    // Cancel any existing timer
    _cancelStepTimer();

    // Call exit callback for current step
    await _executeCurrentStepCallback((step) => step.onExit());

    // Move to selected step
    emit(
      state.copyWith(
        currentStepIndex: selectedIndex,
        status: FlowStatus.inProgress,
      ),
    );

    // Call enter callback for the new step
    await _executeCurrentStepCallback((step) => step.onEnter());

    // Start timer for this step if it has a time limit
    _startStepTimer();
  }

  Future<void> _onFlowErrorOccurred(
    FlowErrorOccurred event,
    Emitter<FlowState<TStepData>> emit,
  ) async {
    emit(state.copyWith(status: FlowStatus.error, error: event.message));
  }

  Future<void> _onFlowReset(
    FlowReset event,
    Emitter<FlowState<TStepData>> emit,
  ) async {
    // Cancel any existing timer
    _cancelStepTimer();

    // Call exit callback for current step
    await _executeCurrentStepCallback((step) => step.onExit());

    // Reset the flow state
    emit(FlowState<TStepData>(steps: _steps, status: FlowStatus.initial));

    // Call enter callback for the first step
    await _executeCurrentStepCallback((step) => step.onEnter());

    // Start timer for this step if it has a time limit
    _startStepTimer();
  }

  Future<void> _onFlowCompleted(
    FlowCompleted event,
    Emitter<FlowState<TStepData>> emit,
  ) async {
    // Flow has been completed
    emit(state.copyWith(status: FlowStatus.completed));
  }

  Future<void> _onFlowLoading(
    FlowLoading event,
    Emitter<FlowState<TStepData>> emit,
  ) async {
    emit(state.copyWith(status: FlowStatus.loading));
  }

  Future<void> _onFlowStepsModified(
    FlowStepsModified event,
    Emitter<FlowState<TStepData>> emit,
  ) async {
    final newSteps =
        event.steps.map((step) => step as FlowStep<TStepData>).toList();
    _steps = newSteps;

    // If current step index is out of bounds, reset to the first step
    final currentStepIndex =
        state.currentStepIndex < newSteps.length ? state.currentStepIndex : 0;

    emit(
      FlowState<TStepData>(
        steps: _steps,
        currentStepIndex: currentStepIndex,
        status: FlowStatus.inProgress,
        validatedSteps: state.validatedSteps,
        skippedSteps: state.skippedSteps,
      ),
    );

    // Start timer for this step if it has a time limit
    _startStepTimer();
  }

  Future<void> _onFlowStepDataUpdated(
    FlowStepDataUpdated event,
    Emitter<FlowState<TStepData>> emit,
  ) async {
    // Update the data for the current step
    final stepData = event.data as TStepData;
    final currentStepIndex = state.currentStepIndex;

    final updatedStep = _steps[currentStepIndex].copyWith(data: stepData);
    final updatedSteps = List<FlowStep<TStepData>>.from(_steps);
    updatedSteps[currentStepIndex] = updatedStep;
    _steps = updatedSteps;

    emit(state.copyWith(steps: _steps));
  }

  // Start a timer for the current step if it has a time limit
  void _startStepTimer() {
    _cancelStepTimer(); // Cancel any existing timers first

    final step = state.currentStep;
    final timeLimit = step.timeLimit;

    if (timeLimit == null) return;

    _timer = Timer(timeLimit, () {
      add(const FlowStepTimerCompleted());
    });
  }

  // Cancel the current step timer
  void _cancelStepTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
      _timer = null;
    }
  }

  // Helper to execute callbacks on the current step
  Future<void> _executeCurrentStepCallback(
    Future<void> Function(FlowStep<TStepData> step) callback,
  ) async {
    try {
      await callback(state.currentStep);
    } catch (e) {
      add(FlowErrorOccurred(message: e.toString()));
    }
  }

  /// Gets the current step
  FlowStep<TStepData> getCurrentStep() {
    return state.currentStep;
  }

  /// Moves to the next step
  void nextStep() => add(const FlowNextPressed());

  /// Moves to the previous step
  void previousStep() => add(const FlowPreviousPressed());

  /// Skips the current step
  void skipStep() => add(const FlowStepSkipped());

  /// Validates the current step
  void validateStep(bool isValid) => add(FlowStepValidated(isValid: isValid));

  /// Resets the flow to the start
  void resetFlow() => add(const FlowReset());

  /// Reports an error
  void reportError(String message) => add(FlowErrorOccurred(message: message));

  /// Updates the steps in the flow
  void updateSteps(List<FlowStep<TStepData>> steps) =>
      add(FlowStepsModified(steps: steps));

  /// Completes the flow
  void completeFlow() => add(const FlowCompleted());

  /// Go to a specific step by index
  void goToStep(int index) => add(FlowStepSelected(index: index));

  @override
  Future<void> close() {
    _cancelStepTimer();
    return super.close();
  }
}
