import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'zone_log_pdf_builder.dart';

Future<String?> exportZoneLogToCSV(List<dynamic> records, String fileName) async {
  try {
    StringBuffer sb = StringBuffer();
    sb.writeln('Date,Program Name,Sequence Name,HeadUnit,Pump,Start Time,End Time,Duration,Start Reason,End Reason');

    for (var rec in records) {
      String dateStr = rec.dateStr.replaceAll('"', '""');
      String progStr = rec.programTitle.replaceAll('"', '""');
      String seqStr = rec.sequenceTitle.replaceAll('"', '""');
      String huStr = rec.headUnit.replaceAll('"', '""');
      String pumpStr = rec.pump.replaceAll('"', '""');
      String startStr = rec.startTime.replaceAll('"', '""');
      String endStr = rec.endTime.replaceAll('"', '""');
      String durStr = rec.duration.replaceAll('"', '""');
      String startRStr = rec.startReason.replaceAll('"', '""');
      String endRStr = rec.endReason.replaceAll('"', '""');

      sb.writeln('"$dateStr","$progStr","$seqStr","$huStr","$pumpStr","$startStr","$endStr","$durStr","$startRStr","$endRStr"');
    }

    String path = '';
    if (!kIsWeb && Platform.isAndroid) {
      path = "/storage/emulated/0/Download/$fileName.csv";
      File file = File(path);
      await file.create(recursive: true);
      await file.writeAsString(sb.toString());
    } else {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      path = "${appDocDir.path}/$fileName.csv";
      File file = File(path);
      await file.writeAsString(sb.toString());
    }
    return path;
  } catch (e) {
    debugPrint("Error exporting CSV: $e");
    return null;
  }
}

Future<String?> exportZoneLogToPDF(List<dynamic> records, String fileName) async {
  try {
    final pdfBytes = generateZoneLogPdfBytes(records, fileName);

    String path = '';
    if (!kIsWeb && Platform.isAndroid) {
      path = "/storage/emulated/0/Download/$fileName.pdf";
      File file = File(path);
      await file.create(recursive: true);
      await file.writeAsBytes(pdfBytes);
    } else {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      path = "${appDocDir.path}/$fileName.pdf";
      File file = File(path);
      await file.writeAsBytes(pdfBytes);
    }
    return path;
  } catch (e) {
    debugPrint("Error exporting PDF: $e");
    return null;
  }
}
