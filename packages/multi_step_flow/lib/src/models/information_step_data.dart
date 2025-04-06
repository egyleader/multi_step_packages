/// A specialized data model for information steps
///
/// This provides structured handling for informational content,
/// including read tracking and auto-advance features
class InformationStepData {
  /// Whether the information has been read
  final bool isRead;

  /// Percentage of content that has been viewed (0.0 to 1.0)
  final double viewProgress;

  /// Time spent viewing the content in seconds
  final int viewTimeSeconds;

  /// Whether auto-advance is enabled for this step
  final bool autoAdvance;

  /// Time in seconds before auto-advancing to the next step
  final int autoAdvanceAfterSeconds;

  /// Whether all required content has been viewed
  final bool isViewComplete;

  /// Additional metadata related to the information content
  final Map<String, dynamic> metadata;

  /// Creates a new [InformationStepData]
  const InformationStepData({
    this.isRead = false,
    this.viewProgress = 0.0,
    this.viewTimeSeconds = 0,
    this.autoAdvance = false,
    this.autoAdvanceAfterSeconds = 5,
    this.isViewComplete = false,
    this.metadata = const {},
  });

  /// Creates an InformationStepData from JSON
  factory InformationStepData.fromJson(Map<String, dynamic> json) =>
      InformationStepData(
        isRead: json['isRead'] ?? false,
        viewProgress: (json['viewProgress'] ?? 0.0).toDouble(),
        viewTimeSeconds: json['viewTimeSeconds'] ?? 0,
        autoAdvance: json['autoAdvance'] ?? false,
        autoAdvanceAfterSeconds: json['autoAdvanceAfterSeconds'] ?? 5,
        isViewComplete: json['isViewComplete'] ?? false,
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      );

  /// Converts to JSON
  Map<String, dynamic> toJson() => {
    'isRead': isRead,
    'viewProgress': viewProgress,
    'viewTimeSeconds': viewTimeSeconds,
    'autoAdvance': autoAdvance,
    'autoAdvanceAfterSeconds': autoAdvanceAfterSeconds,
    'isViewComplete': isViewComplete,
    'metadata': metadata,
  };

  /// Creates a copy with modified properties
  InformationStepData copyWith({
    bool? isRead,
    double? viewProgress,
    int? viewTimeSeconds,
    bool? autoAdvance,
    int? autoAdvanceAfterSeconds,
    bool? isViewComplete,
    Map<String, dynamic>? metadata,
  }) {
    return InformationStepData(
      isRead: isRead ?? this.isRead,
      viewProgress: viewProgress ?? this.viewProgress,
      viewTimeSeconds: viewTimeSeconds ?? this.viewTimeSeconds,
      autoAdvance: autoAdvance ?? this.autoAdvance,
      autoAdvanceAfterSeconds:
          autoAdvanceAfterSeconds ?? this.autoAdvanceAfterSeconds,
      isViewComplete: isViewComplete ?? this.isViewComplete,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Mark the step as read
  InformationStepData markAsRead() {
    return copyWith(isRead: true, isViewComplete: true, viewProgress: 1.0);
  }

  /// Update the viewing progress
  InformationStepData updateProgress(double progress) {
    final newProgress = progress.clamp(0.0, 1.0);
    final isComplete = newProgress >= 1.0;

    return copyWith(
      viewProgress: newProgress,
      isViewComplete: isComplete,
      isRead: isRead || isComplete,
    );
  }

  /// Increment the view time
  InformationStepData incrementViewTime(int seconds) {
    return copyWith(
      viewTimeSeconds: viewTimeSeconds + seconds,
      isRead: isRead || (viewTimeSeconds + seconds >= autoAdvanceAfterSeconds),
    );
  }

  /// Check if the step should auto-advance
  bool shouldAutoAdvance() {
    return autoAdvance &&
        (isViewComplete || viewTimeSeconds >= autoAdvanceAfterSeconds);
  }

  /// Add or update metadata
  InformationStepData updateMetadata(String key, dynamic value) {
    final newMetadata = Map<String, dynamic>.from(metadata);
    newMetadata[key] = value;
    return copyWith(metadata: newMetadata);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InformationStepData &&
        other.isRead == isRead &&
        other.viewProgress == viewProgress &&
        other.viewTimeSeconds == viewTimeSeconds &&
        other.autoAdvance == autoAdvance &&
        other.autoAdvanceAfterSeconds == autoAdvanceAfterSeconds &&
        other.isViewComplete == isViewComplete &&
        _mapsEqual(other.metadata, metadata);
  }

  @override
  int get hashCode => Object.hash(
    isRead,
    viewProgress,
    viewTimeSeconds,
    autoAdvance,
    autoAdvanceAfterSeconds,
    isViewComplete,
    Object.hashAll(metadata.entries),
  );

  bool _mapsEqual(Map map1, Map map2) {
    if (identical(map1, map2)) return true;
    if (map1.length != map2.length) return false;

    for (final key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) {
        return false;
      }
    }

    return true;
  }
}
