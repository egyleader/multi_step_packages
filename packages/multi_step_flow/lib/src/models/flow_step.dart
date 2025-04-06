/// A step in a multi-step flow
class FlowStep<TStepData> {
  /// Unique identifier for the step
  final String id;

  /// Optional title for the step
  final String? title;

  /// Optional description for the step
  final String? description;

  /// Whether the step can be skipped
  final bool isSkippable;

  /// Optional time limit for the step (null means no limit)
  final Duration? timeLimit;

  /// Step data
  final TStepData data;

  /// Step metadata for custom properties
  final Map<String, dynamic> metadata;

  /// Creates a new flow step with the given properties
  const FlowStep({
    required this.id,
    this.title,
    this.description,
    this.isSkippable = false,
    this.timeLimit,
    required this.data,
    this.metadata = const {},
  });

  /// Called when entering this step
  Future<void> onEnter() async {}

  /// Called when exiting this step
  Future<void> onExit() async {}

  /// Called when skipping this step
  Future<void> onSkip() async {}

  /// Validates the step data
  Future<bool> validate() async => true;

  /// Creates a copy of this step with the given fields replaced
  FlowStep<TStepData> copyWith({
    String? id,
    String? title,
    String? description,
    bool? isSkippable,
    Duration? timeLimit,
    TStepData? data,
    Map<String, dynamic>? metadata,
  }) {
    return FlowStep<TStepData>(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isSkippable: isSkippable ?? this.isSkippable,
      timeLimit: timeLimit ?? this.timeLimit,
      data: data ?? this.data,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Gets a value from the step metadata
  T? getValue<T>(String key, [T? defaultValue]) {
    if (!metadata.containsKey(key)) {
      return defaultValue;
    }

    final value = metadata[key];
    if (value is T) {
      return value;
    }

    return defaultValue;
  }

  /// Create a map representation of this step
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isSkippable': isSkippable,
      'timeLimit': timeLimit?.inMilliseconds,
      'data': data,
      'metadata': metadata,
    };
  }

  /// Create a FlowStep from a map representation
  static FlowStep<TStepData> fromJson<TStepData>(
    Map<String, dynamic> json,
    TStepData Function(dynamic json) dataConverter,
  ) {
    return FlowStep<TStepData>(
      id: json['id'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      isSkippable: json['isSkippable'] as bool? ?? false,
      timeLimit:
          json['timeLimit'] != null
              ? Duration(milliseconds: json['timeLimit'] as int)
              : null,
      data: dataConverter(json['data']),
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FlowStep<TStepData> &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.isSkippable == isSkippable &&
        other.timeLimit == timeLimit &&
        other.data == data;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, description, isSkippable, timeLimit, data);
  }
}
