class EventLog {
  final String onReason;
  final String offReason;
  final String onTime;
  final String offTime;
  final String duration;

  EventLog({
    required this.onReason,
    required this.offReason,
    required this.onTime,
    required this.offTime,
    required this.duration,
  });

  factory EventLog.fromJson(String data) {
    // print("data in the event model ==> $data");
    return EventLog(
      onReason: data.split(",")[0],
      onTime: data.split(",")[1],
      offReason: data.split(",")[2],
      offTime: data.split(",")[3],
      duration: data.split(",")[4],
    );
  }
}