import 'package:meta/meta.dart';

/// Represents a single step in a multi-step flow
@immutable
abstract class FlowStep {
  const FlowStep({
    required this.id,
    this.title,
    this.description,
    this.isSkippable = false,
    this.timeLimit,
  });

  /// Unique identifier for the step
  final String id;

  /// Optional title of the step
  final String? title;

  /// Optional description of the step
  final String? description;

  /// Whether this step can be skipped
  final bool isSkippable;

  /// Optional time limit in seconds for timed steps
  final Duration? timeLimit;

  /// Validates the current step
  /// Returns true if validation passes, false otherwise
  Future<bool> validate() async => true;

  /// Called when the step is entered
  Future<void> onEnter() async {}

  /// Called when the step is exited
  Future<void> onExit() async {}

  /// Called when the step is skipped
  Future<void> onSkip() async {}

  /// Creates a copy of this step with the given fields replaced with new values
  FlowStep copyWith({
    String? id,
    String? title,
    String? description,
    bool? isSkippable,
    Duration? timeLimit,
  });
}
