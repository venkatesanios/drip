class ConditionLibraryModel {
  final Map<String, dynamic> conditionLibrary;
  final DefaultData defaultData;

  ConditionLibraryModel({
    required this.conditionLibrary,
    required this.defaultData,
  });

  factory ConditionLibraryModel.fromJson(Map<String, dynamic> json) {
    return ConditionLibraryModel(
      conditionLibrary: json['conditionLibrary'] ?? {},
      defaultData: DefaultData.fromJson(json['default']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conditionLibrary': conditionLibrary,
      'default': defaultData.toJson(),
    };
  }
}

class DefaultData {
  final int conditionLimit;
  final List<String> dropdown;
  final List<String> reason;
  final List<String> parameter;
  final List<String> action;
  final List<String> program;
  final List<String> sequence;
  final List<String> sensors;

  DefaultData({
    required this.conditionLimit,
    required this.dropdown,
    required this.reason,
    required this.parameter,
    required this.action,
    required this.program,
    required this.sequence,
    required this.sensors,
  });

  factory DefaultData.fromJson(Map<String, dynamic> json) {
    return DefaultData(
      conditionLimit: json['conditionLimit'] ?? 0,
      dropdown: List<String>.from(json['dropdown'] ?? []),
      reason: List<String>.from(json['reason'] ?? []),
      parameter: List<String>.from(json['parameter'] ?? []),
      action: List<String>.from(json['action'] ?? []),
      program: List<String>.from(json['program'] ?? []),
      sequence: List<String>.from(json['sequence'] ?? []),
      sensors: List<String>.from(json['sensors'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conditionLimit': conditionLimit,
      'dropdown': dropdown,
      'reason': reason,
      'parameter': parameter,
      'action': action,
      'program': program,
      'sequence': sequence,
      'sensors': sensors,
    };
  }
}