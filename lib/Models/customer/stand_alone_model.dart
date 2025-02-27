class StandAloneModel
{
  bool startTogether;
  String time, flow;
  int method;
  final List<Selection> selection;

  StandAloneModel({
    required this.startTogether,
    required this.time,
    required this.flow,
    required this.method,
    required this.selection,
  });

  factory StandAloneModel.fromJson(Map<String, dynamic> json) {
    return StandAloneModel(
      startTogether: json['startTogether'] as bool,
      time: json['duration'] as String,
      flow: json['flow'] as String,
      method: json['method'] as int,
      selection: (json['selection'] as List<dynamic>?)
          ?.map((e) => Selection.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class Selection {
  final double sNo;
  final bool selected;

  Selection({
    required this.sNo,
    required this.selected,
  });

  factory Selection.fromJson(Map<String, dynamic> json) {
    return Selection(
      sNo: json['sNo'].toDouble(),
      selected: json['selected'],
    );
  }
}