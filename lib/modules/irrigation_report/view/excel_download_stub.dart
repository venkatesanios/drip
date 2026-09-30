import 'dart:developer';
import 'dart:io';
import 'package:excel/excel.dart';

Future<bool> generateExcel(data, String name) async {
  try {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Logs'];

    // Create header row
    dynamic headerRow = [
      data['fixedColumn'],
      if (data['generalColumnData'][0] != null)
        for (var j = 0; j < data['generalColumnData'][0].length; j++)
          data['generalColumn'][j],
      if (data['waterColumnData'][0] != null)
        for (var j = 0; j < data['waterColumnData'][0].length; j++)
          'Water ${data['waterColumn'][j]}',
      if (data['prePostColumnData'][0] != null)
        for (var j = 0; j < data['prePostColumnData'][0].length; j++)
          data['prePostColumn'][j],
      if (data['centralEcPhColumnData'][0] != null)
        for (var j = 0; j < data['centralEcPhColumnData'][0].length; j++)
          data['centralEcPhColumn'][j],
      for (var i = 1; i < 7; i++)
        if (data['centralChannel${i}ColumnData'][0] != null)
          for (var j = 0;
          j < data['centralChannel${i}ColumnData'][0].length;
          j++)
            'CH$i - ${data['centralChannel${i}Column'][j]}',
      if (data['localEcPhColumnData'][0] != null)
        for (var j = 0; j < data['localEcPhColumnData'][0].length; j++)
          data['localEcPhColumn'][j],
      for (var i = 1; i < 7; i++)
        if (data['localChannel${i}ColumnData'][0] != null)
          for (var j = 0;
          j < data['localChannel${i}ColumnData'][0].length;
          j++)
            'LH$i - ${data['localChannel${i}Column'][j]}',
    ];

    // Write header row
    sheetObject.appendRow(
        [for (var i in headerRow) TextCellValue(i)]);

    // Write data rows
    for (var i = 0; i < data['fixedColumnData'].length; i++) {
      List<String> eachRow = [data['fixedColumnData'][i]];
      for (var columnData in [
        'generalColumnData',
        'waterColumnData',
        'prePostColumnData',
        'centralEcPhColumnData',
        for (var i = 1; i < 7; i++)
          'centralChannel${i}ColumnData',
        'localEcPhColumnData',
        for (var i = 1; i < 7; i++)
          'localChannel${i}ColumnData',
      ]) {
        if (data[columnData][0] != null) {
          for (var j = 0; j < data[columnData][i].length; j++) {
            eachRow.add('${data[columnData][i][j]}');
          }
        }
      }
      sheetObject.appendRow(
          [for (var cell in eachRow) TextCellValue(cell)]);
    }

    // Save the file
    var fileBytes = excel.encode();
    if (fileBytes != null) {
      String downloadsDirectoryPath = "/storage/emulated/0/Download";
      String filePath = "$downloadsDirectoryPath/$name.xlsx";
      File file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsBytes(fileBytes);

      if (await file.exists()) {
        log("Excel file saved successfully at $filePath");
        return true;
      } else {
        log("Failed to save the Excel file.");
        return false;
      }
    } else {
      log("Error encoding the Excel file.");
      return false;
    }
  } catch (e) {
    log("Error saving the Excel file: $e");
    return false;
  }
}
