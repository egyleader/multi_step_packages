/// Represents the current status of a flow
enum FlowStatus {
  /// Initial state before the flow starts
  initial,

  /// Flow is in progress - user is navigating through steps
  inProgress,

  /// Current step has been validated successfully
  valid,

  /// Current step has validation errors
  invalid,

  /// The step is in the process of being validated
  validating,

  /// Flow is in a loading state
  loading,

  /// The step has been skipped
  skipped,

  /// Flow has been completed successfully
  completed,

  /// An error occurred during flow execution
  error,
}
