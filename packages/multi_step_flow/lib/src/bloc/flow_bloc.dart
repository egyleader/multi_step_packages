import 'dart:async';
import 'package:bloc/bloc.dart';

import '../models/flow_configuration.dart';
import '../models/flow_status.dart';
import '../models/flow_step.dart';
import 'flow_events.dart';

class FlowBloc extends Bloc<FlowEvent, FlowState> {
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

  FlowConfiguration? _configuration;
  Timer? _stepTimer;

  void _onFlowInitialized(FlowInitialized event, Emitter<FlowState> emit) {
    _configuration = event.configuration;
    emit(FlowState(
      steps: event.steps,
      status: FlowStatus.inProgress,
    ));
    _startStepTimerIfNeeded(state.currentStep);
  }

  Future<void> _onFlowNextPressed(FlowNextPressed event, Emitter<FlowState> emit) async {
    if (!state.hasNext) return;
    
    final currentStep = state.currentStep;
    if (currentStep == null) return;

    if (_configuration?.validateOnStepChange == true && 
        !state.isCurrentStepValidated &&
        !state.isCurrentStepSkipped) {
      emit(state.copyWith(status: FlowStatus.validating));
      final isValid = await currentStep.validate();
      if (!isValid) {
        emit(state.copyWith(status: FlowStatus.invalid));
        return;
      }
      emit(state.copyWith(
        status: FlowStatus.valid,
        validatedSteps: {...state.validatedSteps, currentStep.id},
      ));
    }

    await currentStep.onExit();
    _cancelStepTimer();

    final nextState = state.copyWith(
      currentStepIndex: state.currentStepIndex + 1,
      status: FlowStatus.inProgress,
    );
    emit(nextState);

    await nextState.currentStep?.onEnter();
    _startStepTimerIfNeeded(nextState.currentStep);
  }

  Future<void> _onFlowPreviousPressed(FlowPreviousPressed event, Emitter<FlowState> emit) async {
    if (!state.hasPrevious || _configuration?.allowBackNavigation == false) return;

    final currentStep = state.currentStep;
    if (currentStep == null) return;

    await currentStep.onExit();
    _cancelStepTimer();

    final nextState = state.copyWith(
      currentStepIndex: state.currentStepIndex - 1,
      status: FlowStatus.inProgress,
    );
    emit(nextState);

    await nextState.currentStep?.onEnter();
    _startStepTimerIfNeeded(nextState.currentStep);
  }

  Future<void> _onFlowStepSkipped(FlowStepSkipped event, Emitter<FlowState> emit) async {
    final currentStep = state.currentStep;
    if (currentStep == null || !currentStep.isSkippable) return;

    await currentStep.onSkip();
    _cancelStepTimer();

    if (!state.hasNext) {
      await _tryCompleteFlow(emit);
      return;
    }

    emit(state.copyWith(
      skippedSteps: {...state.skippedSteps, currentStep.id},
      currentStepIndex: state.currentStepIndex + 1,
      status: FlowStatus.inProgress,
    ));

    await state.currentStep?.onEnter();
    _startStepTimerIfNeeded(state.currentStep);
  }

  void _onFlowStepValidated(FlowStepValidated event, Emitter<FlowState> emit) {
    final currentStep = state.currentStep;
    if (currentStep == null) return;

    if (event.isValid) {
      emit(state.copyWith(
        status: FlowStatus.valid,
        validatedSteps: {...state.validatedSteps, currentStep.id},
      ));

      if (_configuration?.autoAdvanceOnValidation == true) {
        add(const FlowNextPressed());
      }
    } else {
      emit(state.copyWith(status: FlowStatus.invalid));
    }
  }

  Future<void> _onFlowStepTimerCompleted(FlowStepTimerCompleted event, Emitter<FlowState> emit) async {
    if (!state.hasNext) {
      await _tryCompleteFlow(emit);
      return;
    }

    add(const FlowNextPressed());
  }

  Future<void> _onFlowStepSelected(FlowStepSelected event, Emitter<FlowState> emit) async {
    if (event.index < 0 || event.index >= state.steps.length) return;

    final currentStep = state.currentStep;
    if (currentStep == null) return;

    await currentStep.onExit();
    _cancelStepTimer();

    final nextState = state.copyWith(
      currentStepIndex: event.index,
      status: FlowStatus.inProgress,
    );
    emit(nextState);

    await nextState.currentStep?.onEnter();
    _startStepTimerIfNeeded(nextState.currentStep);
  }

  void _onFlowErrorOccurred(FlowErrorOccurred event, Emitter<FlowState> emit) {
    emit(state.copyWith(
      status: FlowStatus.error,
      error: event.error,
    ));
  }

  Future<void> _onFlowReset(FlowReset event, Emitter<FlowState> emit) async {
    _cancelStepTimer();
    
    final firstState = FlowState(
      steps: state.steps,
      status: FlowStatus.inProgress,
    );
    emit(firstState);

    await firstState.currentStep?.onEnter();
    _startStepTimerIfNeeded(firstState.currentStep);
  }

  Future<void> _onFlowCompleted(FlowCompleted event, Emitter<FlowState> emit) async {
    await _tryCompleteFlow(emit);
  }

  Future<void> _tryCompleteFlow(Emitter<FlowState> emit) async {
    _cancelStepTimer();
    
    await _configuration?.onFlowComplete?.call();
    
    emit(state.copyWith(status: FlowStatus.completed));
  }

  void _startStepTimerIfNeeded(FlowStep? step) {
    if (step == null) return;
    
    final timeLimit = step.timeLimit ?? _configuration?.defaultStepDuration;
    if (timeLimit == null) return;

    _stepTimer = Timer(timeLimit, () {
      add(const FlowStepTimerCompleted());
    });
  }

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
