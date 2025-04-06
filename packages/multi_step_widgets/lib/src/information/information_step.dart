import 'dart:async';
import 'package:flutter/material.dart';
import 'package:multi_step_flow/multi_step_flow.dart';

/// A widget for displaying information-type steps with read tracking
class InformationStepBuilder<TStepData> extends StatefulWidget {
  /// The flow bloc
  final FlowBloc<TStepData> bloc;

  /// The current step
  final FlowStep<TStepData> step;

  /// Builder for the information content
  final Widget Function(
    BuildContext context,
    InformationStepData infoData,
    void Function(InformationStepData) onUpdate,
  )
  contentBuilder;

  /// Function to extract InformationStepData from the step data
  final InformationStepData Function(TStepData?) infoDataExtractor;

  /// Function to update the step data with information data
  final TStepData Function(TStepData?, InformationStepData) infoDataUpdater;

  /// Whether to enable automatic read tracking
  final bool enableAutoReadTracking;

  /// Whether to show a progress indicator
  final bool showProgressIndicator;

  /// Optional progress indicator builder
  final Widget Function(BuildContext context, InformationStepData infoData)?
  progressIndicatorBuilder;

  /// Constructor for [InformationStepBuilder]
  const InformationStepBuilder({
    super.key,
    required this.bloc,
    required this.step,
    required this.contentBuilder,
    required this.infoDataExtractor,
    required this.infoDataUpdater,
    this.enableAutoReadTracking = true,
    this.showProgressIndicator = true,
    this.progressIndicatorBuilder,
  });

  @override
  _InformationStepBuilderState<TStepData> createState() =>
      _InformationStepBuilderState<TStepData>();
}

class _InformationStepBuilderState<TStepData>
    extends State<InformationStepBuilder<TStepData>> {
  late InformationStepData _infoData;
  Timer? _viewTimer;
  Timer? _autoAdvanceTimer;
  final ScrollController _scrollController = ScrollController();
  bool _isScrollable = false;

  @override
  void initState() {
    super.initState();
    _infoData = widget.infoDataExtractor(widget.step.data);

    // Start the view timer
    if (widget.enableAutoReadTracking) {
      _startViewTimer();
    }

    // Set up scroll listeners for progress tracking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _isScrollable = _scrollController.position.maxScrollExtent > 0;
        if (_isScrollable) {
          _scrollController.addListener(_updateScrollProgress);
        } else {
          // If content is not scrollable, consider it fully visible
          _updateInfoData(_infoData.updateProgress(1.0));
        }
      }
    });
  }

  @override
  void didUpdateWidget(InformationStepBuilder<TStepData> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step != widget.step) {
      _infoData = widget.infoDataExtractor(widget.step.data);
      _resetTimers();
    }
  }

  @override
  void dispose() {
    _viewTimer?.cancel();
    _autoAdvanceTimer?.cancel();
    _scrollController.removeListener(_updateScrollProgress);
    _scrollController.dispose();
    super.dispose();
  }

  // Start timer for tracking view time
  void _startViewTimer() {
    _viewTimer?.cancel();
    _viewTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateInfoData(_infoData.incrementViewTime(1));

      // Check for auto-advance
      if (_infoData.shouldAutoAdvance() && _autoAdvanceTimer == null) {
        _startAutoAdvanceTimer();
      }
    });
  }

  // Start timer for auto-advancing to the next step
  void _startAutoAdvanceTimer() {
    _autoAdvanceTimer = Timer(
      Duration(seconds: _infoData.autoAdvanceAfterSeconds),
      () {
        widget.bloc.add(const FlowEvent.nextPressed());
      },
    );
  }

  // Reset all timers
  void _resetTimers() {
    _viewTimer?.cancel();
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = null;

    if (widget.enableAutoReadTracking) {
      _startViewTimer();
    }
  }

  // Update scroll progress based on scroll position
  void _updateScrollProgress() {
    if (!_scrollController.hasClients ||
        _scrollController.position.maxScrollExtent == 0) {
      return;
    }

    final scrollProgress =
        _scrollController.offset / _scrollController.position.maxScrollExtent;
    _updateInfoData(_infoData.updateProgress(scrollProgress));
  }

  // Update info data and sync with bloc
  void _updateInfoData(InformationStepData updated) {
    if (updated != _infoData) {
      setState(() {
        _infoData = updated;
      });

      // Update the step data in the bloc
      final updatedStepData = widget.infoDataUpdater(widget.step.data, updated);
      widget.bloc.add(FlowEvent.stepDataUpdated(data: updatedStepData));

      // Mark step as validated if it's considered read
      if (updated.isRead || updated.isViewComplete) {
        widget.bloc.add(const FlowEvent.stepValidated(isValid: true));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main content with scroll tracking
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: widget.contentBuilder(context, _infoData, _updateInfoData),
          ),
        ),

        // Progress indicator (optional)
        if (widget.showProgressIndicator)
          widget.progressIndicatorBuilder?.call(context, _infoData) ??
              _buildDefaultProgressIndicator(context),
      ],
    );
  }

  Widget _buildDefaultProgressIndicator(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: _infoData.viewProgress,
            backgroundColor: theme.disabledColor.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _infoData.isRead ? 'Read' : 'Reading...',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                '${(_infoData.viewProgress * 100).round()}%',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A layout for information steps with title, description, and content
class InformationStepLayout extends StatelessWidget {
  /// The title of the information step
  final String? title;

  /// The description of the information step
  final String? description;

  /// The main content of the information step
  final Widget child;

  /// Style for the title
  final TextStyle? titleStyle;

  /// Style for the description
  final TextStyle? descriptionStyle;

  /// Additional actions to show in the header
  final List<Widget>? actions;

  /// Spacing between elements
  final double spacing;

  /// Constructor for [InformationStepLayout]
  const InformationStepLayout({
    super.key,
    this.title,
    this.description,
    required this.child,
    this.titleStyle,
    this.descriptionStyle,
    this.actions,
    this.spacing = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTitleStyle = Theme.of(context).textTheme.headlineMedium;
    final defaultDescriptionStyle = Theme.of(context).textTheme.bodyLarge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Row(
            children: [
              Expanded(
                child: Text(title!, style: titleStyle ?? defaultTitleStyle),
              ),
              if (actions != null) ...actions!,
            ],
          ),
          SizedBox(height: description != null ? 8.0 : spacing),
        ],
        if (description != null) ...[
          Text(
            description!,
            style: descriptionStyle ?? defaultDescriptionStyle,
          ),
          SizedBox(height: spacing),
        ],
        Expanded(child: child),
      ],
    );
  }
}
