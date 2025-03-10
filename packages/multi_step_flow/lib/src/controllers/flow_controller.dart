import 'dart:async';
import '../bloc/flow_bloc.dart';
import '../bloc/flow_events.dart';
import '../models/flow_configuration.dart';
import '../models/flow_status.dart';
import '../models/flow_step.dart';

/// A controller for managing multi-step flows
///
/// Acts as a facade for the underlying [FlowBloc] and provides a simpler API
/// for common flow operations.
class FlowController {
  /// Creates a new [FlowController] with the specified steps and configuration
  ///
  /// If [configuration] is not provided, default configuration is used.
  FlowController({
    required List<FlowStep> steps,
    FlowConfiguration? configuration,
  }) : _bloc = FlowBloc() {
    _subscription = _bloc.stream.listen(
      _onStateChanged,
      onError: _onStateError,
    );
    _initialize(steps, configuration);
  }

  final FlowBloc _bloc;
  StreamSubscription<FlowState>? _subscription;
  final _stateController = StreamController<FlowState>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  /// Stream of flow states
  ///
  /// Listen to this stream to be notified of state changes.
  Stream<FlowState> get stateStream => _stateController.stream;

  /// Stream of error messages
  ///
  /// Listen to this stream to be notified of errors.
  Stream<String> get errorStream => _errorController.stream;

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

  /// Total number of steps in the flow
  int get stepCount => currentState.steps.length;

  /// Current step index
  int get currentStepIndex => currentState.currentStepIndex;

  /// Whether the current step has been validated
  bool get isCurrentStepValidated => currentState.isCurrentStepValidated;

  /// Whether the current step has been skipped
  bool get isCurrentStepSkipped => currentState.isCurrentStepSkipped;

  void _initialize(List<FlowStep> steps, FlowConfiguration? configuration) {
    _bloc.add(FlowInitialized(
      steps: steps,
      configuration: configuration ?? const FlowConfiguration(),
    ));
  }

  void _onStateChanged(FlowState state) {
    _stateController.add(state);
    
    // Forward errors to error stream
    if (state.status == FlowStatus.error && state.error != null) {
      _errorController.add(state.error!);
    }
  }

  void _onStateError(Object error, StackTrace stackTrace) {
    _errorController.add(error.toString());
  }

  /// Moves to the next step if available
  ///
  /// Returns a [Future] that completes when the state has been updated.
  Future<void> next() async {
    // Create a completer that will be completed when the state changes
    final completer = Completer<void>();
    late StreamSubscription<FlowState> subscription;

    // Current step index to detect change
    final currentIndex = currentStepIndex;
    
    subscription = stateStream.listen((state) {
      // If the step has changed or an error occurred, complete the future
      if (state.currentStepIndex != currentIndex || 
          state.status == FlowStatus.error) {
        completer.complete();
        subscription.cancel();
      }
    });

    // Add timeout to avoid hanging if expected state change doesn't occur
    Timer(const Duration(seconds: 3), () {
      if (!completer.isCompleted) {
        completer.complete();
        subscription.cancel();
      }
    });

    // Add the event to the bloc
    _bloc.add(const FlowNextPressed());
    
    return completer.future;
  }

  /// Moves to the previous step if available and allowed by configuration
  ///
  /// Returns a [Future] that completes when the state has been updated.
  Future<void> previous() async {
    final completer = Completer<void>();
    late StreamSubscription<FlowState> subscription;
    
    final currentIndex = currentStepIndex;
    
    subscription = stateStream.listen((state) {
      if (state.currentStepIndex != currentIndex || 
          state.status == FlowStatus.error) {
        completer.complete();
        subscription.cancel();
      }
    });

    Timer(const Duration(seconds: 3), () {
      if (!completer.isCompleted) {
        completer.complete();
        subscription.cancel();
      }
    });

    _bloc.add(const FlowPreviousPressed());
    
    return completer.future;
  }

  /// Skips the current step if it is skippable
  ///
  /// Returns a [Future] that completes when the state has been updated.
  Future<void> skip() async {
    if (currentStep == null || !currentStep!.isSkippable) {
      return;
    }

    final completer = Completer<void>();
    late StreamSubscription<FlowState> subscription;
    
    final currentIndex = currentStepIndex;
    
    subscription = stateStream.listen((state) {
      if (state.currentStepIndex != currentIndex || 
          state.status == FlowStatus.error) {
        completer.complete();
        subscription.cancel();
      }
    });

    Timer(const Duration(seconds: 3), () {
      if (!completer.isCompleted) {
        completer.complete();
        subscription.cancel();
      }
    });

    _bloc.add(const FlowStepSkipped());
    
    return completer.future;
  }

  /// Marks the current step as valid or invalid
  ///
  /// Returns a [Future] that completes when the state has been updated.
  Future<void> validate(bool isValid) async {
    final completer = Completer<void>();
    late StreamSubscription<FlowState> subscription;
    
    final currentValidated = isCurrentStepValidated;
    
    subscription = stateStream.listen((state) {
      if (state.isCurrentStepValidated != currentValidated || 
          state.status == FlowStatus.error) {
        completer.complete();
        subscription.cancel();
      }
    });

    Timer(const Duration(seconds: 3), () {
      if (!completer.isCompleted) {
        completer.complete();
        subscription.cancel();
      }
    });

    _bloc.add(FlowStepValidated(isValid: isValid));
    
    return completer.future;
  }

  /// Jumps to a specific step by index
  ///
  /// Returns a [Future] that completes when the state has been updated.
  /// If the index is out of range, the future completes immediately and no action is taken.
  Future<void> goToStep(int index) async {
    if (index < 0 || index >= stepCount || index == currentStepIndex) {
      return;
    }

    final completer = Completer<void>();
    late StreamSubscription<FlowState> subscription;
    
    subscription = stateStream.listen((state) {
      if (state.currentStepIndex == index || 
          state.status == FlowStatus.error) {
        completer.complete();
        subscription.cancel();
      }
    });

    Timer(const Duration(seconds: 3), () {
      if (!completer.isCompleted) {
        completer.complete();
        subscription.cancel();
      }
    });

    _bloc.add(FlowStepSelected(index));
    
    return completer.future;
  }

  /// Resets the flow to its initial state
  ///
  /// Returns a [Future] that completes when the state has been updated.
  Future<void> reset() async {
    final completer = Completer<void>();
    late StreamSubscription<FlowState> subscription;
    
    subscription = stateStream.listen((state) {
      if (state.currentStepIndex == 0 && 
          state.validatedSteps.isEmpty && 
          state.skippedSteps.isEmpty) {
        completer.complete();
        subscription.cancel();
      }
    });

    Timer(const Duration(seconds: 3), () {
      if (!completer.isCompleted) {
        completer.complete();
        subscription.cancel();
      }
    });

    _bloc.add(const FlowReset());
    
    return completer.future;
  }

  /// Completes the flow
  ///
  /// Returns a [Future] that completes when the state has been updated.
  Future<void> complete() async {
    final completer = Completer<void>();
    late StreamSubscription<FlowState> subscription;
    
    subscription = stateStream.listen((state) {
      if (state.status == FlowStatus.completed || 
          state.status == FlowStatus.error) {
        completer.complete();
        subscription.cancel();
      }
    });

    Timer(const Duration(seconds: 3), () {
      if (!completer.isCompleted) {
        completer.complete();
        subscription.cancel();
      }
    });

    _bloc.add(const FlowCompleted());
    
    return completer.future;
  }

  /// Reports an error in the flow
  ///
  /// The error will be available in the error stream and the state will be updated.
  void reportError(String error) {
    _bloc.add(FlowErrorOccurred(error));
  }

  /// Dispose of the controller and close all streams
  ///
  /// This method should be called when the controller is no longer needed
  /// to prevent memory leaks.
  Future<void> dispose() async {
    await _subscription?.cancel();
    await _stateController.close();
    await _errorController.close();
    await _bloc.close();
  }
}

/// Extension to check if a completer has been completed
extension CompleterExtension on Completer {
  bool get isCompleted => future.isCompleted;
}

/// Extension to check if a future has been completed
extension FutureExtension on Future {
  bool get isCompleted {
    bool isCompleted = true;
    this.then((_) => isCompleted = true)
        .catchError((_) => isCompleted = true);
    return isCompleted;
  }
}
