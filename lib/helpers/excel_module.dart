import 'dart:io';
import 'package:path/path.dart';
import 'package:excel/excel.dart';
import 'package:kho_kho_scoresheet/helpers/permission_handler.dart';
import 'package:kho_kho_scoresheet/helpers/time_diff.dart';
import 'package:path_provider/path_provider.dart';

int excelColumn = 2;
int customColumnIndex = 1;
int customRowIndex = 2;
int turnCount = 0;

void createExcel(
  List matchData,
  List defenderAndAttacker,
) async {
  Excel excel = Excel.createExcel();
  Sheet sheet = excel['Sheet1'];

  void writeHeaders() {
    // Write headers
    sheet.cell(CellIndex.indexByString("A$excelColumn")).value =
        TextCellValue("Turn ${(turnCount + 1).toString()}");
    excelColumn++;
    sheet.cell(CellIndex.indexByString("A$excelColumn")).value = TextCellValue(
        "DEF (${turnCount.isEven ? defenderAndAttacker[0] : defenderAndAttacker[1]}) No.");
    excelColumn++;
    sheet.cell(CellIndex.indexByString("A$excelColumn")).value = TextCellValue(
        "ATK (${turnCount.isEven ? defenderAndAttacker[1] : defenderAndAttacker[0]}) No.");
    excelColumn++;
    sheet.cell(CellIndex.indexByString("A$excelColumn")).value =
        const TextCellValue("Run Time");
    excelColumn++;
    sheet.cell(CellIndex.indexByString("A$excelColumn")).value =
        const TextCellValue("Per Time");
    excelColumn++;
    sheet.cell(CellIndex.indexByString("A$excelColumn")).value =
        const TextCellValue("Symbol");
    excelColumn += 2;
    turnCount++;
  }

  for (var i = 0; i < matchData.length; i++) {
    writeHeaders();
    List row = matchData[i][i.toString()];
    customColumnIndex = 1;
    for (var item in row) {
      customRowIndex = 2;
      if (i == 1) {
        customRowIndex = 9;
      }
      if (i == 2) {
        customRowIndex = 16;
      }
      if (i == 3) {
        customRowIndex = 23;
      }
      if (i == 4) {
        customRowIndex = 30;
      }
      if (i == 5) {
        customRowIndex = 37;
      }
      if (i == 6) {
        customRowIndex = 44;
      }
      if (i == 7) {
        customRowIndex = 51;
      }
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: customColumnIndex, rowIndex: customRowIndex))
          .value = TextCellValue(item['def_number']);
      customRowIndex++;
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: customColumnIndex, rowIndex: customRowIndex))
          .value = TextCellValue(item['atk_number']);
      customRowIndex++;
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: customColumnIndex, rowIndex: customRowIndex))
          .value = TextCellValue(item['run_time']);
      customRowIndex++;
      customRowIndex++;
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: customColumnIndex, rowIndex: customRowIndex))
          .value = TextCellValue(item['symbol']);
      customColumnIndex++;
    }
  }
  for (var i = 0; i < matchData.length; i++) {
    List row = matchData[i][i.toString()];
    List derivedData = deriveTimeDifference(row);
    customColumnIndex = 1;
    if (i == 0) {
      customRowIndex = 5;
    }
    if (i == 1) {
      customRowIndex = 12;
    }
    if (i == 2) {
      customRowIndex = 19;
    }
    if (i == 3) {
      customRowIndex = 26;
    }
    if (i == 4) {
      customRowIndex = 33;
    }
    if (i == 5) {
      customRowIndex = 40;
    }
    if (i == 6) {
      customRowIndex = 47;
    }
    if (i == 7) {
      customRowIndex = 54;
    }
    for (var j = 0; j < derivedData.length; j++) {
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: customColumnIndex, rowIndex: customRowIndex))
          .value = TextCellValue(derivedData[j]);
      customColumnIndex++;
    }
  }
  writeToExcel(excel);
}

void writeToExcel(Excel excel) async {
  bool isPermissionGranted = await requestPermissions();
  if (isPermissionGranted == true) {
    if (Platform.isAndroid) {
      var fileBytes = excel.save()!;
      String filePath = join('/storage/emulated/0/Download/',
          '${getTimeDateForFileName()} scoresheet.xlsx');

      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }
    if (Platform.isIOS ||
        Platform.isLinux ||
        Platform.isMacOS ||
        Platform.isWindows) {
      final Directory? downloadsDir = await getDownloadsDirectory();
      var fileBytes = excel.save()!;
      String filePath =
          join('$downloadsDir', '${getTimeDateForFileName()} scoresheet.xlsx');

      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }
  } else {
    //Platform is web
    excel.save(fileName: '${getTimeDateForFileName()} scoresheet.xlsx');
  }
}
