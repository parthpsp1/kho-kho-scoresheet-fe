import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kho_kho_scoresheet/provider/match_details_provider.dart';
import 'package:path/path.dart';
import 'package:excel/excel.dart';
import 'package:kho_kho_scoresheet/helpers/permission_handler.dart';
import 'package:kho_kho_scoresheet/helpers/time_diff.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

int excelColumn = 2;
int customColumnIndex = 1;
int customRowIndex = 2;
int turnCount = 0;

void createExcel(
  BuildContext context,
  List matchData,
  List defenderAndAttacker,
  List teamATurn1Score,
  List teamATurn2Score,
  List teamATurn3Score,
  List teamATurn4Score,
  List teamBTurn1Score,
  List teamBTurn2Score,
  List teamBTurn3Score,
  List teamBTurn4Score,
) async {
  Excel excel = Excel.createExcel();
  Sheet sheet = excel['Sheet1'];
  String teamAName =
      Provider.of<MatchDetailsProvider>(context, listen: false).teamAName;
  String teamBName =
      Provider.of<MatchDetailsProvider>(context, listen: false).teamBName;

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

  void writeMatchResult(context) {
    customRowIndex += 4;
    customColumnIndex = 0;
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: customColumnIndex, rowIndex: customRowIndex))
        .value = const TextCellValue('Team');
    customColumnIndex++;
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: customColumnIndex, rowIndex: customRowIndex))
        .value = const TextCellValue('I');
    customColumnIndex++;
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: customColumnIndex, rowIndex: customRowIndex))
        .value = const TextCellValue('II');
    customColumnIndex++;
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: customColumnIndex, rowIndex: customRowIndex))
        .value = const TextCellValue('III');
    customColumnIndex++;
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: customColumnIndex, rowIndex: customRowIndex))
        .value = const TextCellValue('IV');
    customColumnIndex++;
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: customColumnIndex, rowIndex: customRowIndex))
        .value = const TextCellValue('Total');
    customRowIndex++;

    customColumnIndex = 0;
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: customColumnIndex, rowIndex: customRowIndex))
        .value = TextCellValue(teamAName);
    customColumnIndex++;
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: customColumnIndex, rowIndex: customRowIndex))
        .value = TextCellValue(teamATurn1Score.length.toString());
    customColumnIndex++;
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: customColumnIndex, rowIndex: customRowIndex))
        .value = TextCellValue(teamATurn2Score.length.toString());
    customColumnIndex++;
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: customColumnIndex, rowIndex: customRowIndex))
        .value = TextCellValue(teamATurn3Score.length.toString());
    customColumnIndex++;
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: customColumnIndex, rowIndex: customRowIndex))
        .value = TextCellValue(teamATurn4Score.length.toString());
    customColumnIndex++;
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: customColumnIndex, rowIndex: customRowIndex))
        .value = TextCellValue((teamATurn1Score.length +
            teamATurn2Score.length +
            teamATurn3Score.length +
            teamATurn4Score.length)
        .toString());
    customRowIndex++;

    customColumnIndex = 0;
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: customColumnIndex, rowIndex: customRowIndex))
        .value = TextCellValue(teamBName);
    customColumnIndex++;
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: customColumnIndex, rowIndex: customRowIndex))
        .value = TextCellValue(teamBTurn1Score.length.toString());
    customColumnIndex++;
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: customColumnIndex, rowIndex: customRowIndex))
        .value = TextCellValue(teamBTurn2Score.length.toString());
    customColumnIndex++;
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: customColumnIndex, rowIndex: customRowIndex))
        .value = TextCellValue(teamBTurn3Score.length.toString());
    customColumnIndex++;
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: customColumnIndex, rowIndex: customRowIndex))
        .value = TextCellValue(teamBTurn4Score.length.toString());
    customColumnIndex++;
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: customColumnIndex, rowIndex: customRowIndex))
        .value = TextCellValue((teamBTurn1Score.length +
            teamBTurn2Score.length +
            teamBTurn3Score.length +
            teamBTurn4Score.length)
        .toString());
    customRowIndex + 2;

    int teamATotalScore = (teamATurn1Score.length +
            teamATurn2Score.length +
            teamATurn3Score.length +
            teamATurn4Score.length)
        .toInt();
    int teamBTotalScore = (teamBTurn1Score.length +
            teamBTurn2Score.length +
            teamBTurn3Score.length +
            teamBTurn4Score.length)
        .toInt();
    customColumnIndex = 0;
    customRowIndex += 2;
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: customColumnIndex, rowIndex: customRowIndex))
        .value = TextCellValue(
      teamATotalScore > teamBTotalScore
          ? '$teamAName won by ${teamATotalScore - teamBTotalScore} point(s)'
          : '$teamBName won by ${teamBTotalScore - teamATotalScore} point(s)',
    );
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
  writeMatchResult(context);
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
          join('$downloadsDir', '${getTimeDateForFileName()}_scoresheet.xlsx');

      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }
  } else {
    //Platform is web
    excel.save(fileName: '${getTimeDateForFileName()}_scoresheet.xlsx');
  }
}
