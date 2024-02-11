import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kho_kho_scoresheet/helpers/permission_handler.dart';
import 'package:kho_kho_scoresheet/provider/scoresheet_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:excel/excel.dart';
import 'package:kho_kho_scoresheet/helpers/time_diff.dart';
import 'package:provider/provider.dart';

void createExcel(List defenderAndAttacker, BuildContext context) async {
  Excel excel = Excel.createExcel();
  Sheet sheet = excel['Sheet1'];
  List<Map<String, String>> runTimes = [];
  List<Map<String, dynamic>> scoreSheetData =
      Provider.of<ScoresheetProvider>(context, listen: false).scoreSheetList;

  // Write headers
  sheet.cell(CellIndex.indexByString("A2")).value =
      TextCellValue("DEF (${defenderAndAttacker[0]}) No.");
  sheet.cell(CellIndex.indexByString("A3")).value =
      TextCellValue("ATK (${defenderAndAttacker[1]}) No.");
  sheet.cell(CellIndex.indexByString("A4")).value =
      const TextCellValue("Run Time");
  sheet.cell(CellIndex.indexByString("A5")).value =
      const TextCellValue("Per Time");
  sheet.cell(CellIndex.indexByString("A6")).value =
      const TextCellValue("Symbol");

  //Fill in runTimes
  for (var i = 0; i < scoreSheetData.length; i++) {
    Map<String, String> entry = {
      "run_time": scoreSheetData[i]['run_time']!,
      "symbol": scoreSheetData[i]['symbol']!
    };
    runTimes.add(entry);
  }

  List perTimes = deriveTimeDifference(runTimes);

  // Write data
  int customColumnIndex = 1;
  for (var row in scoreSheetData) {
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: customColumnIndex, rowIndex: 1))
        .value = TextCellValue(row['def_number']!);
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: customColumnIndex, rowIndex: 2))
        .value = TextCellValue(row['atk_number']!);
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: customColumnIndex, rowIndex: 3))
        .value = TextCellValue(row['run_time']!);
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: customColumnIndex, rowIndex: 4))
        .value = TextCellValue(perTimes[customColumnIndex - 1]);
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: customColumnIndex, rowIndex: 5))
        .value = TextCellValue(row['symbol']!);
    customColumnIndex++;
  }

  writeToExcel(excel);
}

void writeToExcel(Excel excel) async {
  // if (Platform.isAndroid || Platform.isIOS) {
  //   bool isPermissionGranted = await requestPermissions();
  //   if (isPermissionGranted == true) {
  //     var fileBytes = excel.save()!;

  //     var directory = await getExternalStorageDirectory();
  //     var filePath = join(directory!.path, 'test.xlsx');

  //     File(filePath)
  //       ..createSync(recursive: true)
  //       ..writeAsBytesSync(fileBytes);
  //   }
  // } else {
  excel.save(fileName: 'test.xlsx');
  // }
}
