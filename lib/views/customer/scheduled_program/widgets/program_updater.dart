import '../../../../models/customer/site_model.dart';

class ProgramUpdater {
  static void updateProgramsFromMqtt(
      List<String> spLive,
      List<ProgramList> scheduledPrograms,
      List<String> conditionPayloadList,
      ) {
    for (var sp in spLive) {
      final values = sp.split(",");
      if (values.length > 11) {
        final serialNumber = int.tryParse(values[0]);
        if (serialNumber == null) continue;

        final index = scheduledPrograms.indexWhere(
                (program) => program.serialNumber == serialNumber);
        if (index == -1) continue;

        scheduledPrograms[index]
          ..startDate = values[3]
          ..startTime = values[4]
          ..endDate = values[5]
          ..programStatusPercentage = int.tryParse(values[6]) ?? 0
          ..startStopReason = int.tryParse(values[7]) ?? 0
          ..pauseResumeReason = int.tryParse(values[8]) ?? 0
          ..prgOnOff = values[10]
          ..prgPauseResume = values[11]
          ..status = 1;

        for (var payload in conditionPayloadList) {
          final parts = payload.split(",");
          if (parts.length > 2) {
            final conditionSerialNo = int.tryParse(parts[0].trim());
            final conditionStatus = int.tryParse(parts[2].trim());
            final actualValue = parts[4].trim();

            final matches = scheduledPrograms[index]
                .conditions
                .where((c) => c.sNo == conditionSerialNo);

            for (var condition in matches) {
              condition.conditionStatus = conditionStatus ?? 0;
              condition.actualValue = actualValue;
            }
          }
        }
      }
    }
  }
}