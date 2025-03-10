import 'package:meta/meta.dart';

/// Represents a single step in a multi-step flow
///
/// This abstract class defines the contract for all steps in a flow.
/// Implement this class to create custom step types with specific behavior.
@immutable
abstract class FlowStep {
  /// Creates a new flow step
  ///
  /// [id] is a unique identifier for the step and is required.
  /// [title] and [description] are optional metadata.
  /// [isSkippable] determines whether the step can be skipped.
  /// [timeLimit] sets an optional auto-advance timer for the step.
  const FlowStep({
    required this.id,
    this.title,
    this.description,
    this.isSkippable = false,
    this.timeLimit,
    this.data,
  });

  /// Unique identifier for the step
  final String id;

  /// Optional title of the step
  final String? title;

  /// Optional description of the step
  final String? description;

  /// Whether this step can be skipped
  ///
  /// If true, the flow controller's [skip] method will work on this step.
  /// If false, the step must be completed or navigated away from with [next] or [previous].
  final bool isSkippable;

  /// Optional time limit for timed steps
  ///
  /// If set, the flow will automatically advance to the next step
  /// after this duration has passed.
  final Duration? timeLimit;

  /// Optional data associated with this step
  ///
  /// This can be used to store additional information relevant to the step.
  final Map<String, dynamic>? data;

  /// Validates the current step
  ///
  /// Override this method to provide custom validation logic.
  /// Return true if the step is valid, or false if it's invalid.
  ///
  /// By default, all steps are considered valid.
  /// 
  /// Example:
  /// ```dart
  /// @override
  /// Future<bool> validate() async {
  ///   return form.isValid;
  /// }
  /// ```
  Future<bool> validate() async => true;

  /// Called when the step is entered
  ///
  /// Override this method to perform actions when the step becomes active.
  /// This is a good place to initialize step-specific resources.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Future<void> onEnter() async {
  ///   await loadStepData();
  ///   analytics.trackStepViewed(id);
  /// }
  /// ```
  Future<void> onEnter() async {}

  /// Called when the step is exited
  ///
  /// Override this method to perform cleanup when leaving a step.
  /// This is called when moving to the next or previous step.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Future<void> onExit() async {
  ///   await saveStepData();
  ///   disposeStepResources();
  /// }
  /// ```
  Future<void> onExit() async {}

  /// Called when the step is skipped
  ///
  /// Override this method to perform actions when a step is explicitly skipped.
  /// This is distinct from [onExit], which is called for any transition.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Future<void> onSkip() async {
  ///   analytics.trackStepSkipped(id);
  ///   await saveDefaultValues();
  /// }
  /// ```
  Future<void> onSkip() async {}

  /// Creates a copy of this step with the given fields replaced with new values
  ///
  /// This is required for immutable updates to steps.
  FlowStep copyWith({
    String? id,
    String? title,
    String? description,
    bool? isSkippable,
    Duration? timeLimit,
    Map<String, dynamic>? data,
  });

  /// Retrieves data from the step's data map
  ///
  /// Returns the value associated with [key], or [defaultValue] if the key
  /// doesn't exist or the data map is null.
  T? getValue<T>(String key, [T? defaultValue]) {
    if (data == null) return defaultValue;
    final value = data![key];
    return value is T ? value : defaultValue;
  }

  /// Returns a string representation of the step
  @override
  String toString() => 'FlowStep(id: $id, title: $title)';
}
