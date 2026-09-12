import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
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

    final bytes = utf8.encode(sb.toString());
    final content = base64Encode(bytes);
    html.AnchorElement(
      href: 'data:text/csv;charset=utf-8;base64,$content',
    )
      ..setAttribute('download', '$fileName.csv')
      ..click();

    return "Downloaded $fileName.csv";
  } catch (e) {
    debugPrint("Error exporting CSV Web: $e");
    return null;
  }
}

Future<String?> exportZoneLogToPDF(List<dynamic> records, String fileName) async {
  try {
    final pdfBytes = generateZoneLogPdfBytes(records, fileName);
    final content = base64Encode(pdfBytes);
    html.AnchorElement(
      href: 'data:application/pdf;base64,$content',
    )
      ..setAttribute('download', '$fileName.pdf')
      ..click();

    return "Downloaded $fileName.pdf";
  } catch (e) {
    debugPrint("Error exporting PDF Web: $e");
    return null;
  }
}
