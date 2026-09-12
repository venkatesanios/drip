import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'excel_builder.dart';

/// This file is selected by the conditional import in log_home.dart on
/// every platform WITHOUT dart:html (i.e. everything except web - Android,
/// iOS, desktop). It must never import dart:html, or non-web builds fail
/// to compile with an "unsupported dart:html import" error.
///
/// Must stay functionally equivalent to excel_download_web.dart's web
/// counterpart - both call the same buildLogsExcel() so header/data
/// columns can never drift apart between platforms.
Future<bool> generateExcel(Map<String, dynamic> data, String name) async {
  try {
    if (Platform.isAndroid && !await _hasStorageAccess()) {
      return false;
    }

    final excel = buildLogsExcel(data);

    final fileBytes = excel.encode();
    if (fileBytes == null) {
      return false;
    }

    // Matches the path already shown to the user in log_home.dart's
    // "saved successfully" dialog.
    final downloadDir = Directory('/storage/emulated/0/Download');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }

    final file = File('${downloadDir.path}/$name.xlsx');
    await file.writeAsBytes(fileBytes);

    return true;
  } catch (e, stackTrace) {
    print('Error generating Excel: $e');
    print('stackTrace generating Excel: $stackTrace');
    return false;
  }
}

/// Requests whichever storage permission is actually meaningful on the
/// device's Android version and returns whether we ended up with write
/// access to the public Download folder.
///
/// - Android 10 and below (and 11-12 with legacy storage enabled): a
///   granted Permission.storage is enough.
/// - Android 11+ (API 30+): Permission.storage no longer grants broad
///   filesystem writes - Permission.manageExternalStorage ("All files
///   access") is required instead. That one takes the user to a system
///   settings screen rather than a normal dialog, so only request it if
///   the plain storage permission wasn't sufficient.
Future<bool> _hasStorageAccess() async {
  final storageStatus = await Permission.storage.request();
  if (storageStatus.isGranted) {
    return true;
  }
  final manageStatus = await Permission.manageExternalStorage.request();
  return manageStatus.isGranted;
}