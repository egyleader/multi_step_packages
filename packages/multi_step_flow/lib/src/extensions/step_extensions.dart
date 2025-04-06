import '../models/flow_step.dart';

/// Extension point for creating custom step types and behaviors.
///
/// This class provides a way to extend the behavior of FlowSteps without
/// modifying the core implementation.
abstract class StepExtension<TStepData> {
  /// The ID of this extension.
  String get id;
  
  /// Optional name of this extension for debugging.
  String get name => id;
  
  /// Called when a step with this extension is entered.
  void onStepEnter(FlowStep<TStepData> step) {}
  
  /// Called when a step with this extension is exited.
  void onStepExit(FlowStep<TStepData> step) {}
  
  /// Called when a step with this extension is skipped.
  void onStepSkip(FlowStep<TStepData> step) {}
  
  /// Called when a step with this extension is validated.
  void onStepValidate(FlowStep<TStepData> step, bool isValid) {}
  
  /// Called when a step with this extension times out.
  void onStepTimeout(FlowStep<TStepData> step) {}
  
  /// Called when the step's data is updated.
  void onStepDataUpdate(FlowStep<TStepData> step, TStepData newData) {}
}

/// Extension for handling steps with specific behaviors.
///
/// This allows you to create custom step types by extending this class
/// and implementing the required behavior.
abstract class CustomStepHandler<TStepData, TResult> {
  /// The ID of this handler.
  String get id;
  
  /// Optional name of this handler for debugging.
  String get name => id;
  
  /// Whether this handler can handle the given step.
  bool canHandle(FlowStep<TStepData> step);
  
  /// Process the step and return a result.
  TResult process(FlowStep<TStepData> step);
}

/// Registry for step extensions and custom handlers.
///
/// Use this class to register and retrieve extensions and handlers.
class StepExtensionRegistry<TStepData> {
  final Map<String, StepExtension<TStepData>> _extensions = {};
  final List<CustomStepHandler> _handlers = [];
  
  /// Register a step extension.
  void registerExtension(StepExtension<TStepData> extension) {
    _extensions[extension.id] = extension;
  }
  
  /// Unregister a step extension.
  void unregisterExtension(String id) {
    _extensions.remove(id);
  }
  
  /// Get a step extension by ID.
  StepExtension<TStepData>? getExtension(String id) {
    return _extensions[id];
  }
  
  /// Register a custom step handler.
  void registerHandler(CustomStepHandler handler) {
    _handlers.add(handler);
  }
  
  /// Unregister a custom step handler.
  void unregisterHandler(CustomStepHandler handler) {
    _handlers.remove(handler);
  }
  
  /// Get a handler that can handle the given step.
  CustomStepHandler? findHandlerForStep<TResult>(FlowStep<TStepData> step) {
    for (final handler in _handlers) {
      if (handler is CustomStepHandler<TStepData, TResult> && 
          handler.canHandle(step)) {
        return handler;
      }
    }
    return null;
  }
  
  /// Process a step with a suitable handler and return the result.
  TResult? processStep<TResult>(FlowStep<TStepData> step) {
    final handler = findHandlerForStep<TResult>(step);
    if (handler != null) {
      return (handler as CustomStepHandler<TStepData, TResult>).process(step);
    }
    return null;
  }
  
  /// Notify all relevant extensions about a step event.
  void notifyStepEvent(
    FlowStep<TStepData> step,
    void Function(StepExtension<TStepData> extension) notify,
  ) {
    // Get all extensions that apply to this step
    final extensions = _getExtensionsForStep(step);
    
    // Notify each extension
    for (final extension in extensions) {
      notify(extension);
    }
  }
  
  /// Get all extensions that apply to a specific step.
  List<StepExtension<TStepData>> _getExtensionsForStep(FlowStep<TStepData> step) {
    final result = <StepExtension<TStepData>>[];
    
    // Get extension IDs from the step
    final extensionIds = _getStepExtensionIds(step);
    if (extensionIds != null) {
      for (final id in extensionIds) {
        final extension = _extensions[id];
        if (extension != null) {
          result.add(extension);
        }
      }
    }
    
    return result;
  }
  
  /// Helper to get extension IDs from a step
  List<String>? _getStepExtensionIds(FlowStep<TStepData> step) {
    // Extensions are stored in a field or property on the step
    // This implementation depends on how FlowStep stores extension information
    if (step.description?.contains('extensions:') == true) {
      // Parse extensions from description (simple implementation)
      final pattern = RegExp(r'extensions:\[(.*?)\]');
      final match = pattern.firstMatch(step.description ?? '');
      if (match != null && match.group(1) != null) {
        return match.group(1)!.split(',').map((e) => e.trim()).toList();
      }
    }
    return null;
  }
}

/// Extension methods on FlowStep to make it easier to work with extensions.
extension FlowStepExtensions<TStepData> on FlowStep<TStepData> {
  /// Adds an extension ID to this step.
  FlowStep<TStepData> withExtension(String extensionId) {
    final currentDescription = description ?? '';
    final extensionsPattern = RegExp(r'extensions:\[(.*?)\]');
    
    if (extensionsPattern.hasMatch(currentDescription)) {
      // Update existing extensions
      final updatedDescription = currentDescription.replaceAllMapped(
        extensionsPattern,
        (match) {
          final currentExtensions = match.group(1)!.split(',').map((e) => e.trim()).toList();
          if (!currentExtensions.contains(extensionId)) {
            currentExtensions.add(extensionId);
          }
          return 'extensions:[${currentExtensions.join(', ')}]';
        },
      );
      return copyWith(description: updatedDescription);
    } else {
      // Add new extensions section
      final updatedDescription = '$currentDescription\nextensions:[$extensionId]';
      return copyWith(description: updatedDescription);
    }
  }
  
  /// Adds multiple extension IDs to this step.
  FlowStep<TStepData> withExtensions(List<String> extensionIds) {
    FlowStep<TStepData> updatedStep = this;
    for (final id in extensionIds) {
      updatedStep = updatedStep.withExtension(id);
    }
    return updatedStep;
  }
  
  /// Checks if this step has a specific extension.
  bool hasExtension(String extensionId) {
    final currentDescription = description ?? '';
    final extensionsPattern = RegExp(r'extensions:\[(.*?)\]');
    final match = extensionsPattern.firstMatch(currentDescription);
    
    if (match != null && match.group(1) != null) {
      final extensions = match.group(1)!.split(',').map((e) => e.trim()).toList();
      return extensions.contains(extensionId);
    }
    return false;
  }
}
