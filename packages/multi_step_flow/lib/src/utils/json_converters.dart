import 'package:json_annotation/json_annotation.dart';
import '../models/flow_step.dart';

/// A JsonConverter for FlowStep that handles generic data
class FlowStepConverter<T>
    implements JsonConverter<FlowStep<T>, Map<String, dynamic>> {
  const FlowStepConverter(this.fromJsonT, this.toJsonT);

  final T Function(Object? json) fromJsonT;
  final Object? Function(T value) toJsonT;

  @override
  FlowStep<T> fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final title = json['title'] as String?;
    final description = json['description'] as String?;
    final isSkippable = json['isSkippable'] as bool? ?? false;
    final timeLimit =
        json['timeLimit'] == null
            ? null
            : Duration(milliseconds: json['timeLimit'] as int);

    final rawData = json['data'];
    final T data = fromJsonT(rawData);

    return FlowStep<T>(
      id: id,
      title: title,
      description: description,
      isSkippable: isSkippable,
      timeLimit: timeLimit,
      data: data,
    );
  }

  @override
  Map<String, dynamic> toJson(FlowStep<T> step) {
    return {
      'id': step.id,
      'title': step.title,
      'description': step.description,
      'isSkippable': step.isSkippable,
      'timeLimit': step.timeLimit?.inMilliseconds,
      'data': toJsonT(step.data),
    };
  }
}

/// A JsonConverter for List<FlowStep> that handles generic data
class FlowStepsConverter<T>
    implements JsonConverter<List<FlowStep<T>>, List<dynamic>> {
  const FlowStepsConverter(this.fromJsonT, this.toJsonT);

  final T Function(Object? json) fromJsonT;
  final Object? Function(T value) toJsonT;

  @override
  List<FlowStep<T>> fromJson(List<dynamic> json) {
    return json
        .map(
          (e) => FlowStepConverter<T>(
            fromJsonT,
            toJsonT,
          ).fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  List<dynamic> toJson(List<FlowStep<T>> steps) {
    return steps
        .map((step) => FlowStepConverter<T>(fromJsonT, toJsonT).toJson(step))
        .toList();
  }
}
