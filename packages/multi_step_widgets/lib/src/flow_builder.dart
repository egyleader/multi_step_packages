import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_step_flow/multi_step_flow.dart';

/// A widget that builds the UI for a flow step based on the current [FlowState].
///
/// This is the core widget for displaying multi-step flows. It automatically
/// handles state transitions, animations, and error states.
class FlowBuilder<TStepData> extends StatefulWidget {
  /// The FlowBloc that manages this flow's state
  final FlowBloc<TStepData>? bloc;
  
  /// Builder function for rendering the current step
  final Widget Function(BuildContext, FlowStep<TStepData>) stepBuilder;
  
  /// Optional builder for loading state
  final Widget Function(BuildContext, FlowState<TStepData>)? loadingBuilder;
  
  /// Optional builder for error state
  final Widget Function(BuildContext, String?)? errorBuilder;
  
  /// Optional builder for completed state
  final Widget Function(BuildContext, FlowState<TStepData>)? completedBuilder;
  
  /// Duration for step transitions
  final Duration transitionDuration;
  
  /// Curve for step transitions
  final Curve transitionCurve;
  
  /// Whether to animate transitions between steps
  final bool animateTransitions;
  
  /// Callback fired when the flow completes
  final VoidCallback? onFlowCompleted;

  /// Custom transition builder for animating between steps
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;

  /// Creates a new [FlowBuilder] widget.
  ///
  /// If [bloc] is not provided, it will try to find a [FlowBloc] in the widget tree
  /// using [BlocProvider]. At least one of these must be available.
  const FlowBuilder({
    Key? key,
    this.bloc,
    required this.stepBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.completedBuilder,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.transitionCurve = Curves.easeInOut,
    this.animateTransitions = true,
    this.onFlowCompleted,
    this.transitionBuilder,
  }) : super(key: key);

  @override
  _FlowBuilderState<TStepData> createState() => _FlowBuilderState<TStepData>();
}

class _FlowBuilderState<TStepData> extends State<FlowBuilder<TStepData>> {
  FlowBloc<TStepData>? _bloc;
  bool _hasCalledOnCompleted = false;

  @override
  void initState() {
    super.initState();
    _updateBloc();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateBloc();
  }

  @override
  void didUpdateWidget(FlowBuilder<TStepData> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bloc != oldWidget.bloc) {
      _updateBloc();
    }
  }

  void _updateBloc() {
    _bloc = widget.bloc ?? context.read<FlowBloc<TStepData>>();
    assert(_bloc != null, 'FlowBloc not found. Provide a bloc or use BlocProvider.');
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FlowBloc<TStepData>, FlowState<TStepData>>(
      bloc: _bloc,
      listenWhen: (previous, current) => 
          previous.status != current.status && 
          current.status == FlowStatus.completed,
      listener: (context, state) {
        if (state.status == FlowStatus.completed && 
            !_hasCalledOnCompleted && 
            widget.onFlowCompleted != null) {
          _hasCalledOnCompleted = true;
          widget.onFlowCompleted!();
        }
      },
      builder: (context, state) {
        // Handle different states
        switch (state.status) {
          case FlowStatus.initial:
          case FlowStatus.inProgress:
          case FlowStatus.valid:
          case FlowStatus.invalid:
          case FlowStatus.validating:
          case FlowStatus.loading:
          case FlowStatus.skipped:
            // Main step rendering with animation
            return AnimatedSwitcher(
              duration: widget.animateTransitions 
                  ? widget.transitionDuration 
                  : Duration.zero,
              switchInCurve: widget.transitionCurve,
              switchOutCurve: widget.transitionCurve,
              transitionBuilder: widget.transitionBuilder ?? defaultTransitionBuilder,
              child: KeyedSubtree(
                key: ValueKey('step_${state.currentStepIndex}'),
                child: widget.stepBuilder(context, state.currentStep),
              ),
            );
          
          case FlowStatus.error:
            // Error state
            if (widget.errorBuilder != null) {
              return widget.errorBuilder!(context, state.error);
            }
            return _defaultErrorBuilder(context, state.error);
            
          case FlowStatus.completed:
            // Completed state
            if (widget.completedBuilder != null) {
              return widget.completedBuilder!(context, state);
            }
            return _defaultCompletedBuilder(context, state);
        }
      },
    );
  }

  // Default transition animation
  Widget defaultTransitionBuilder(Widget child, Animation<double> animation) {
    return FadeTransition(opacity: animation, child: child);
  }
  
  // Default error UI
  Widget _defaultErrorBuilder(BuildContext context, String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'An error occurred',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _bloc?.resetFlow(),
              child: const Text('Restart Flow'),
            ),
          ],
        ),
      ),
    );
  }
  
  // Default completion UI
  Widget _defaultCompletedBuilder(BuildContext context, FlowState<TStepData> state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Flow Completed',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _bloc?.resetFlow(),
              child: const Text('Start Over'),
            ),
          ],
        ),
      ),
    );
  }
}

/// A provider widget that makes a [FlowBloc] available to its descendants.
///
/// This is typically used at the top of your flow widget tree.
class FlowBlocProvider<TStepData> extends StatelessWidget {
  /// The child widget
  final Widget child;
  
  /// The FlowBloc to provide
  final FlowBloc<TStepData> bloc;
  
  /// Whether to dispose the bloc when this widget is removed
  final bool disposeBloc;

  /// Creates a new [FlowBlocProvider] widget.
  const FlowBlocProvider({
    Key? key,
    required this.child,
    required this.bloc,
    this.disposeBloc = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FlowBloc<TStepData>>.value(
      value: bloc,
      child: child,
    );
  }
}
