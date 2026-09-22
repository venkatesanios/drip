import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'zone_log_pdf_builder.dart';

Future<Directory> _resolveDownloadDirectory() async {
  Directory? directory;
  try {
    if (!kIsWeb && Platform.isAndroid) {
      // 1. Try standard Android public Download directory
      final directDownload = Directory('/storage/emulated/0/Download');
      if (await directDownload.exists()) {
        try {
          final testFile = File('${directDownload.path}/.test_probe');
          await testFile.writeAsString('probe');
          await testFile.delete();
          return directDownload;
        } catch (_) {}
      }

      // 2. Try path_provider getDownloadsDirectory
      directory = await getDownloadsDirectory();

      // 3. Try path_provider getExternalStorageDirectories for downloads
      if (directory == null) {
        final extDirs = await getExternalStorageDirectories(
            type: StorageDirectory.downloads);
        if (extDirs != null && extDirs.isNotEmpty) {
          directory = extDirs.first;
        }
      }
    } else if (!kIsWeb && Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else if (!kIsWeb) {
      directory = await getDownloadsDirectory();
    }
  } catch (e) {
    debugPrint("Error resolving download directory: $e");
  }

  directory ??= await getApplicationDocumentsDirectory();
  return directory;
}

Future<String?> exportZoneLogToCSV(
    List<dynamic> records, String fileName) async {
  try {
    // 1. Generate Excel (.xlsx) workbook
    final excel = Excel.createExcel();
    final String defaultSheet = excel.getDefaultSheet() ?? 'Sheet1';
    final Sheet sheet = excel[defaultSheet];

    sheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Program Name'),
      TextCellValue('Sequence Name'),
      TextCellValue('HeadUnit'),
      TextCellValue('Pump'),
      TextCellValue('Start Time'),
      TextCellValue('End Time'),
      TextCellValue('Duration'),
      TextCellValue('Start Reason'),
      TextCellValue('End Reason'),
    ]);

    for (var rec in records) {
      sheet.appendRow([
        TextCellValue(rec.dateStr?.toString() ?? ''),
        TextCellValue(rec.programTitle?.toString() ?? ''),
        TextCellValue(rec.sequenceTitle?.toString() ?? ''),
        TextCellValue(rec.headUnit?.toString() ?? ''),
        TextCellValue(rec.pump?.toString() ?? ''),
        TextCellValue(rec.startTime?.toString() ?? ''),
        TextCellValue(rec.endTime?.toString() ?? ''),
        TextCellValue(rec.duration?.toString() ?? ''),
        TextCellValue(rec.startReason?.toString() ?? ''),
        TextCellValue(rec.endReason?.toString() ?? ''),
      ]);
    }

    final fileBytes = excel.encode();
    if (fileBytes == null) return null;

    Directory downloadDir = await _resolveDownloadDirectory();
    String xlsxPath = "${downloadDir.path}/$fileName.xlsx";
    File xlsxFile = File(xlsxPath);
    await xlsxFile.create(recursive: true);
    await xlsxFile.writeAsBytes(fileBytes);

    // Also write CSV version to Downloads
    StringBuffer sb = StringBuffer();
    sb.writeln(
        'Date,Program Name,Sequence Name,HeadUnit,Pump,Start Time,End Time,Duration,Start Reason,End Reason');

    for (var rec in records) {
      String dateStr = (rec.dateStr?.toString() ?? '').replaceAll('"', '""');
      String progStr =
          (rec.programTitle?.toString() ?? '').replaceAll('"', '""');
      String seqStr =
          (rec.sequenceTitle?.toString() ?? '').replaceAll('"', '""');
      String huStr = (rec.headUnit?.toString() ?? '').replaceAll('"', '""');
      String pumpStr = (rec.pump?.toString() ?? '').replaceAll('"', '""');
      String startStr = (rec.startTime?.toString() ?? '').replaceAll('"', '""');
      String endStr = (rec.endTime?.toString() ?? '').replaceAll('"', '""');
      String durStr = (rec.duration?.toString() ?? '').replaceAll('"', '""');
      String startRStr =
          (rec.startReason?.toString() ?? '').replaceAll('"', '""');
      String endRStr = (rec.endReason?.toString() ?? '').replaceAll('"', '""');

      sb.writeln(
          '"$dateStr","$progStr","$seqStr","$huStr","$pumpStr","$startStr","$endStr","$durStr","$startRStr","$endRStr"');
    }

    String csvPath = "${downloadDir.path}/$fileName.csv";
    File csvFile = File(csvPath);
    await csvFile.create(recursive: true);
    await csvFile.writeAsString(sb.toString());

    // If public Download folder exists on Android, copy there as well for visibility
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final publicDownload = Directory('/storage/emulated/0/Download');
        if (await publicDownload.exists() &&
            publicDownload.path != downloadDir.path) {
          File pubXlsx = File("${publicDownload.path}/$fileName.xlsx");
          await pubXlsx.writeAsBytes(fileBytes);
          File pubCsv = File("${publicDownload.path}/$fileName.csv");
          await pubCsv.writeAsString(sb.toString());
        }
      } catch (_) {}
    }

    return "$fileName.xlsx";
  } catch (e) {
    debugPrint("Error exporting Excel/CSV: $e");
    return null;
  }
}

Future<String?> exportZoneLogToPDF(
    List<dynamic> records, String fileName) async {
  try {
    final pdfBytes = generateZoneLogPdfBytes(records, fileName);

    Directory downloadDir = await _resolveDownloadDirectory();
    String pdfPath = "${downloadDir.path}/$fileName.pdf";
    File pdfFile = File(pdfPath);
    await pdfFile.create(recursive: true);
    await pdfFile.writeAsBytes(pdfBytes);

    // If public Download folder exists on Android, copy there as well for visibility
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final publicDownload = Directory('/storage/emulated/0/Download');
        if (await publicDownload.exists() &&
            publicDownload.path != downloadDir.path) {
          File pubPdf = File("${publicDownload.path}/$fileName.pdf");
          await pubPdf.writeAsBytes(pdfBytes);
        }
      } catch (_) {}
    }

    return "$fileName.pdf";
  } catch (e) {
    debugPrint("Error exporting PDF: $e");
    return null;
  }
}
