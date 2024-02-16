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
    for (var j = 0; j < derivedData.length; j++) {
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: customColumnIndex, rowIndex: customRowIndex))
          .value = TextCellValue(derivedData[j]);
      customColumnIndex++;
      print(derivedData);
    }
  }
  writeToExcel(excel);
}

void writeToExcel(Excel excel) async {
  if (Platform.isAndroid || Platform.isIOS) {
    bool isPermissionGranted = await requestPermissions();
    if (isPermissionGranted == true) {
      var fileBytes = excel.save()!;
      String filePath =
          join('/storage/emulated/0/Download/', 'mobile_test.xlsx');

      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);

      print('File saved at: $filePath');
    }
  } else {
    excel.save(fileName: 'test.xlsx');
  }
}
