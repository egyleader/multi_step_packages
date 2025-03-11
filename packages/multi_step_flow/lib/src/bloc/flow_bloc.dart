import 'dart:async';
import 'package:bloc/bloc.dart';

import '../models/flow_configuration.dart';
import '../models/flow_status.dart';
import '../models/flow_step.dart';
import 'flow_events.dart';

/// Bloc responsible for managing the state of a multi-step flow
class FlowBloc extends Bloc<FlowEvent, FlowState> {
  /// Creates a new [FlowBloc] with an empty initial state
  FlowBloc() : super(const FlowState(steps: [])) {
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
  }

  /// Flow configuration options
  FlowConfiguration? _configuration;

  /// Timer for auto-advancing timed steps
  Timer? _stepTimer;

  /// Initializes the flow with the provided steps and configuration
  void _onFlowInitialized(FlowInitialized event, Emitter<FlowState> emit) {
    try {
      _configuration = event.configuration;

      // Initial state should have status = initial
      emit(FlowState(steps: event.steps, status: FlowStatus.initial));

      // Start timer if needed
      _startStepTimerIfNeeded(state.currentStep);
    } catch (error) {
      emit(state.copyWith(status: FlowStatus.error, error: error.toString()));
    }
  }

  /// Handles moving to the next step
  Future<void> _onFlowNextPressed(
    FlowNextPressed event,
    Emitter<FlowState> emit,
  ) async {
    try {
      // Guard conditions
      if (!state.hasNext) return;
      final currentStep = state.currentStep;
      if (currentStep == null) return;

      // Validate current step if configured and not already validated
      if (_configuration?.validateOnStepChange == true &&
          !state.isCurrentStepValidated &&
          !state.isCurrentStepSkipped) {
        emit(state.copyWith(status: FlowStatus.validating));

        // Perform the validation
        bool isValid;
        try {
          isValid = await currentStep.validate();
        } catch (e) {
          emit(state.copyWith(status: FlowStatus.error, error: e.toString()));
          return;
        }

        if (!isValid) {
          emit(state.copyWith(status: FlowStatus.invalid));
          return;
        }

        // Mark step as validated
        emit(
          state.copyWith(
            status: FlowStatus.valid,
            validatedSteps: {...state.validatedSteps, currentStep.id},
          ),
        );
      }

      // Perform exit actions for current step
      try {
        await currentStep.onExit();
      } catch (e) {
        emit(state.copyWith(status: FlowStatus.error, error: e.toString()));
        return;
      }

      // Cancel any running timer
      _cancelStepTimer();

      // Move to next step
      final nextState = state.copyWith(
        currentStepIndex: state.currentStepIndex + 1,
        status: FlowStatus.inProgress,
      );
      emit(nextState);

      // Perform enter actions for next step
      try {
        await nextState.currentStep?.onEnter();
      } catch (e) {
        emit(nextState.copyWith(status: FlowStatus.error, error: e.toString()));
        return;
      }

      // Start timer for next step if needed
      _startStepTimerIfNeeded(nextState.currentStep);
    } catch (error) {
      emit(state.copyWith(status: FlowStatus.error, error: error.toString()));
    }
  }

  /// Handles moving to the previous step
  Future<void> _onFlowPreviousPressed(
    FlowPreviousPressed event,
    Emitter<FlowState> emit,
  ) async {
    try {
      // Guard conditions
      if (!state.hasPrevious || _configuration?.allowBackNavigation == false) {
        return;
      }
      final currentStep = state.currentStep;
      if (currentStep == null) return;

      // Perform exit actions for current step
      try {
        await currentStep.onExit();
      } catch (e) {
        emit(state.copyWith(status: FlowStatus.error, error: e.toString()));
        return;
      }

      // Cancel any running timer
      _cancelStepTimer();

      // Move to previous step
      final nextState = state.copyWith(
        currentStepIndex: state.currentStepIndex - 1,
        status: FlowStatus.inProgress,
      );
      emit(nextState);

      // Perform enter actions for previous step
      try {
        await nextState.currentStep?.onEnter();
      } catch (e) {
        emit(nextState.copyWith(status: FlowStatus.error, error: e.toString()));
        return;
      }

      // Start timer for previous step if needed
      _startStepTimerIfNeeded(nextState.currentStep);
    } catch (error) {
      emit(state.copyWith(status: FlowStatus.error, error: error.toString()));
    }
  }

  /// Handles skipping the current step
  Future<void> _onFlowStepSkipped(
    FlowStepSkipped event,
    Emitter<FlowState> emit,
  ) async {
    try {
      // Guard conditions
      final currentStep = state.currentStep;
      if (currentStep == null || !currentStep.isSkippable) return;

      // Perform skip actions
      try {
        await currentStep.onSkip();
      } catch (e) {
        emit(state.copyWith(status: FlowStatus.error, error: e.toString()));
        return;
      }

      // Cancel any running timer
      _cancelStepTimer();

      // If this is the last step, complete the flow
      if (!state.hasNext) {
        await _tryCompleteFlow(emit);
        return;
      }

      // Mark step as skipped and move to next step
      emit(
        state.copyWith(
          skippedSteps: {...state.skippedSteps, currentStep.id},
          currentStepIndex: state.currentStepIndex + 1,
          status: FlowStatus.inProgress,
        ),
      );

      // Perform enter actions for next step
      try {
        await state.currentStep?.onEnter();
      } catch (e) {
        emit(state.copyWith(status: FlowStatus.error, error: e.toString()));
        return;
      }

      // Start timer for next step if needed
      _startStepTimerIfNeeded(state.currentStep);
    } catch (error) {
      emit(state.copyWith(status: FlowStatus.error, error: error.toString()));
    }
  }

  /// Handles step validation
  void _onFlowStepValidated(FlowStepValidated event, Emitter<FlowState> emit) {
    try {
      // Guard conditions
      final currentStep = state.currentStep;
      if (currentStep == null) return;

      if (event.isValid) {
        // Mark step as validated
        emit(
          state.copyWith(
            status: FlowStatus.valid,
            validatedSteps: {...state.validatedSteps, currentStep.id},
          ),
        );

        // Auto-advance if configured
        if (_configuration?.autoAdvanceOnValidation == true && state.hasNext) {
          add(const FlowNextPressed());
        }
      } else {
        emit(state.copyWith(status: FlowStatus.invalid));
      }
    } catch (error) {
      emit(state.copyWith(status: FlowStatus.error, error: error.toString()));
    }
  }

  /// Handles timer completion for timed steps
  Future<void> _onFlowStepTimerCompleted(
    FlowStepTimerCompleted event,
    Emitter<FlowState> emit,
  ) async {
    try {
      if (!state.hasNext) {
        await _tryCompleteFlow(emit);
        return;
      }

      add(const FlowNextPressed());
    } catch (error) {
      emit(state.copyWith(status: FlowStatus.error, error: error.toString()));
    }
  }

  /// Handles direct navigation to a specific step
  Future<void> _onFlowStepSelected(
    FlowStepSelected event,
    Emitter<FlowState> emit,
  ) async {
    try {
      // Guard conditions
      if (event.index < 0 || event.index >= state.steps.length) return;
      final currentStep = state.currentStep;
      if (currentStep == null) return;

      // Perform exit actions for current step
      try {
        await currentStep.onExit();
      } catch (e) {
        emit(state.copyWith(status: FlowStatus.error, error: e.toString()));
        return;
      }

      // Cancel any running timer
      _cancelStepTimer();

      // Move to selected step
      final nextState = state.copyWith(
        currentStepIndex: event.index,
        status: FlowStatus.inProgress,
      );
      emit(nextState);

      // Perform enter actions for selected step
      try {
        await nextState.currentStep?.onEnter();
      } catch (e) {
        emit(nextState.copyWith(status: FlowStatus.error, error: e.toString()));
        return;
      }

      // Start timer for selected step if needed
      _startStepTimerIfNeeded(nextState.currentStep);
    } catch (error) {
      emit(state.copyWith(status: FlowStatus.error, error: error.toString()));
    }
  }

  /// Handles error reporting
  void _onFlowErrorOccurred(FlowErrorOccurred event, Emitter<FlowState> emit) {
    emit(state.copyWith(status: FlowStatus.error, error: event.error));
  }

  /// Resets the flow to its initial state
  Future<void> _onFlowReset(FlowReset event, Emitter<FlowState> emit) async {
    try {
      _cancelStepTimer();

      // Reset to first step with clean state
      final firstState = FlowState(
        steps: state.steps,
        status: FlowStatus.initial,
      );
      emit(firstState);

      // Perform enter actions for first step
      try {
        await firstState.currentStep?.onEnter();

        // Update status to inProgress after successful onEnter
        emit(firstState.copyWith(status: FlowStatus.inProgress));
      } catch (e) {
        emit(
          firstState.copyWith(status: FlowStatus.error, error: e.toString()),
        );
        return;
      }

      // Start timer for first step if needed
      _startStepTimerIfNeeded(firstState.currentStep);
    } catch (error) {
      emit(state.copyWith(status: FlowStatus.error, error: error.toString()));
    }
  }

  /// Completes the flow
  Future<void> _onFlowCompleted(
    FlowCompleted event,
    Emitter<FlowState> emit,
  ) async {
    await _tryCompleteFlow(emit);
  }

  /// Helper method to complete the flow
  Future<void> _tryCompleteFlow(Emitter<FlowState> emit) async {
    try {
      _cancelStepTimer();

      // Execute completion callback if provided
      if (_configuration?.onFlowComplete != null) {
        try {
          await _configuration!.onFlowComplete!();
        } catch (e) {
          emit(state.copyWith(status: FlowStatus.error, error: e.toString()));
          return;
        }
      }

      // Mark flow as completed
      emit(state.copyWith(status: FlowStatus.completed));
    } catch (error) {
      emit(state.copyWith(status: FlowStatus.error, error: error.toString()));
    }
  }

  /// Starts a timer for auto-advancing timed steps
  void _startStepTimerIfNeeded(FlowStep? step) {
    if (step == null) return;

    final timeLimit = step.timeLimit ?? _configuration?.defaultStepDuration;
    if (timeLimit == null) return;

    _stepTimer = Timer(timeLimit, () {
      add(const FlowStepTimerCompleted());
    });
  }

  /// Cancels any running step timer
  void _cancelStepTimer() {
    _stepTimer?.cancel();
    _stepTimer = null;
  }

  @override
  Future<void> close() {
    _cancelStepTimer();
    return super.close();
  }
}
