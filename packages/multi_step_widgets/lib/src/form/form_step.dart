import 'package:flutter/material.dart';
import 'package:multi_step_flow/multi_step_flow.dart';

/// A specialized step widget for forms that manages form validation and submission
class FormStepBuilder<TStepData> extends StatefulWidget {
  /// The form bloc
  final FlowBloc<TStepData> bloc;

  /// The current step
  final FlowStep<TStepData> step;

  /// Builder for the form content
  final Widget Function(
    BuildContext context,
    FormStepData formData,
    void Function(FormStepData) onChanged,
    GlobalKey<FormState> formKey,
  )
  builder;

  /// Function to extract FormStepData from the step data
  final FormStepData Function(TStepData?) formDataExtractor;

  /// Function to update the step data with form data
  final TStepData Function(TStepData?, FormStepData) formDataUpdater;

  /// Function to validate the entire form
  final Map<String, String? Function(dynamic)> validators;

  /// Auto-validation mode for the form
  final AutovalidateMode autovalidateMode;

  /// Optional custom padding for the form
  final EdgeInsetsGeometry padding;

  /// Optional scroll physics for the form
  final ScrollPhysics? scrollPhysics;

  /// Constructor for [FormStepBuilder]
  const FormStepBuilder({
    super.key,
    required this.bloc,
    required this.step,
    required this.builder,
    required this.formDataExtractor,
    required this.formDataUpdater,
    this.validators = const {},
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.padding = const EdgeInsets.all(16.0),
    this.scrollPhysics,
  });

  @override
  _FormStepBuilderState<TStepData> createState() =>
      _FormStepBuilderState<TStepData>();
}

class _FormStepBuilderState<TStepData>
    extends State<FormStepBuilder<TStepData>> {
  late FormStepData _formData;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _formData = widget.formDataExtractor(widget.step.data);
  }

  @override
  void didUpdateWidget(FormStepBuilder<TStepData> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step != widget.step) {
      _formData = widget.formDataExtractor(widget.step.data);
    }
  }

  void _handleFormDataChanged(FormStepData updatedFormData) {
    setState(() {
      _formData = updatedFormData;
    });

    // Update the step data in the bloc
    final updatedStepData = widget.formDataUpdater(
      widget.step.data,
      updatedFormData,
    );
    widget.bloc.add(FlowEvent.stepDataUpdated(data: updatedStepData));

    // Validate the step if needed
    if (updatedFormData.isFormValid) {
      // Mark the step as valid
      widget.bloc.add(const FlowEvent.stepValidated(isValid: true));
    } else {
      // Mark the step as invalid
      widget.bloc.add(const FlowEvent.stepValidated(isValid: false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: widget.autovalidateMode,
      child: SingleChildScrollView(
        physics: widget.scrollPhysics,
        padding: widget.padding,
        child: widget.builder(
          context,
          _formData,
          _handleFormDataChanged,
          _formKey,
        ),
      ),
    );
  }
}

/// A widget that combines a form step title, description, and content
class FormStepLayout extends StatelessWidget {
  /// The step title
  final String? title;

  /// The step description
  final String? description;

  /// The form content
  final Widget child;

  /// Text style for the title
  final TextStyle? titleStyle;

  /// Text style for the description
  final TextStyle? descriptionStyle;

  /// Additional actions to show in the header
  final List<Widget>? actions;

  /// Spacing between elements
  final double spacing;

  /// Constructor for [FormStepLayout]
  const FormStepLayout({
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
        child,
      ],
    );
  }
}
