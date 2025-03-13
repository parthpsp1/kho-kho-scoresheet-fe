import 'dart:io';

import 'package:excel/excel.dart' as xl;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kho_kho_scoresheet/helpers/excel_helper.dart';
import 'package:kho_kho_scoresheet/helpers/time_manipulation.dart';
import 'package:kho_kho_scoresheet/screens/start_screen.dart';
import 'package:kho_kho_scoresheet/supabase/db_queries.dart';
import 'package:open_filex/open_filex.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateExcel extends StatefulWidget {
  const CreateExcel({super.key, required this.matchId});

  final int matchId;

  @override
  State<CreateExcel> createState() => _CreateExcelState();
}

class _CreateExcelState extends State<CreateExcel> {
  @override
  void initState() {
    super.initState();
    _processExcel();
  }

  Future<void> _processExcel() async {
    await readAndWriteExcel(widget.matchId);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StartScreen()),
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog.adaptive(
            title: const Text('Exported Successfully'),
            content: const Text(
              'Excel exported to Downloads folder',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Okay'),
              ),
              TextButton(
                onPressed: () async {
                  const path = "/storage/emulated/0/Download/";
                  await OpenFilex.open(path);
                  Navigator.of(context).pop();
                },
                child: const Text('Open Location'),
              ),
            ],
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(18),
              ),
            ),
            titlePadding: const EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
            ),
            titleTextStyle: const TextStyle(
              color: Color.fromRGBO(17, 47, 27, 1),
              fontSize: 21,
              fontWeight: FontWeight.w600,
            ),
            contentPadding: const EdgeInsets.only(
              top: 10,
              left: 20,
              right: 20,
              bottom: 24,
            ),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            actionsPadding: const EdgeInsets.only(
              bottom: 16,
              left: 20,
              right: 20,
              top: 10,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LinearProgressIndicator(),
          SizedBox(
            height: 16,
          ),
          Text(
            "Generating Excel...",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}

Future<void> readAndWriteExcel(int matchId) async {
  PostgrestList matchData = await SupabaseDBQuery().fetchMatchData(matchId);
  PostgrestList matchTurnData =
      await SupabaseDBQuery().fetchMatchTurnData(matchId);
  PostgrestList tossData =
      await SupabaseDBQuery().fetchTossWinnerDetailsForMatch(matchId);
  try {
    // Define file path in Downloads directory
    String filePath =
        "/storage/emulated/0/Download/${getTimeDateForFileName()}_scoresheet.xlsx";
    File file = File(filePath);
    List<xl.CellIndex> cellsToStyle = [];
    List<xl.CellIndex> cellsToStyleTurnEnd = [];

    // Load the Excel file from assets if it doesn't exist
    if (!await file.exists()) {
      ByteData data =
          await rootBundle.load("assets/files/base_scoresheet.xlsx");
      List<int> bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes);
      print("File copied to: $filePath");
    }

    // Read the existing file
    List<int> fileBytes = await file.readAsBytes();
    if (fileBytes.isEmpty) {
      print("Error: File is empty or unreadable.");
      return;
    }

    // Use `excel` package to read data
    var excel = xl.Excel.decodeBytes(fileBytes);
    var sheet = excel.tables[excel.tables.keys.first]; // First sheet

    // Print existing data
    print("Existing Data:");
    for (var row in sheet!.rows) {
      print(row.map((cell) => cell?.value ?? "").join(", "));
    }

    // Condition 1
    if ((matchData[0]['team_a_name'] == tossData[0]['toss_winner_team_name']) &&
        tossData[0]['chosen_side'] == "DEF") {
      List<Map<String, dynamic>> turnOneData =
          matchTurnData.where((map) => map["turn_no"] == 1).toList();

      for (int i = 0; i < turnOneData.length; i++) {
        var defNoCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 22 + i, rowIndex: 33);
        var atkNoCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 22 + i, rowIndex: 34);
        var wicketTimeCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 22 + i, rowIndex: 35);
        var perTimeCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 22 + i, rowIndex: 36);
        var symbolCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 22 + i, rowIndex: 37);

        // Update cells
        sheet.updateCell(defNoCell, xl.IntCellValue(turnOneData[i]['def_no']));
        if (turnOneData[i]['atk_no'] != null) {
          sheet.updateCell(
              atkNoCell, xl.IntCellValue(turnOneData[i]['atk_no']));
        } else {
          sheet.updateCell(
              atkNoCell, xl.TextCellValue(turnOneData[i]['symbol']));
        }
        sheet.updateCell(
            wicketTimeCell, xl.TextCellValue(turnOneData[i]['wicket_time']));
        sheet.updateCell(
            perTimeCell, xl.TextCellValue(turnOneData[i]['per_time']));
        sheet.updateCell(
            symbolCell, xl.TextCellValue(turnOneData[i]['symbol']));

        if (turnOneData[i]['symbol'] != "-") {
          cellsToStyle.addAll(
              [defNoCell, atkNoCell, wicketTimeCell, perTimeCell, symbolCell]);
        } else {
          cellsToStyleTurnEnd.addAll(
              [defNoCell, atkNoCell, wicketTimeCell, perTimeCell, symbolCell]);
        }
      }

      List<Map<String, dynamic>> turnTwoData =
          matchTurnData.where((map) => map["turn_no"] == 2).toList();

      for (int i = 0; i < turnTwoData.length; i++) {
        var defNoCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 2 + i, rowIndex: 33);
        var atkNoCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 2 + i, rowIndex: 34);
        var wicketTimeCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 2 + i, rowIndex: 35);
        var perTimeCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 2 + i, rowIndex: 36);
        var symbolCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 2 + i, rowIndex: 37);

        sheet.updateCell(defNoCell, xl.IntCellValue(turnTwoData[i]['def_no']));
        if (turnTwoData[i]['atk_no'] != null) {
          sheet.updateCell(
              atkNoCell, xl.IntCellValue(turnTwoData[i]['atk_no']));
        } else {
          sheet.updateCell(
              atkNoCell, xl.TextCellValue(turnTwoData[i]['symbol']));
        }
        sheet.updateCell(
            wicketTimeCell, xl.TextCellValue(turnTwoData[i]['wicket_time']));
        sheet.updateCell(
            perTimeCell, xl.TextCellValue(turnTwoData[i]['per_time']));
        sheet.updateCell(
            symbolCell, xl.TextCellValue(turnTwoData[i]['symbol']));

        if (turnOneData[i]['symbol'] != "-") {
          cellsToStyle.addAll(
              [defNoCell, atkNoCell, wicketTimeCell, perTimeCell, symbolCell]);
        } else {
          cellsToStyleTurnEnd.addAll(
              [defNoCell, atkNoCell, wicketTimeCell, perTimeCell, symbolCell]);
        }
      }
    }

    // Condition 2
    if ((matchData[0]['team_a_name'] == tossData[0]['toss_winner_team_name']) &&
        tossData[0]['chosen_side'] == "ATK") {
      List<Map<String, dynamic>> turnOneData =
          matchTurnData.where((map) => map["turn_no"] == 1).toList();

      for (int i = 0; i < turnOneData.length; i++) {
        var defNoCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 2 + i, rowIndex: 33);
        var atkNoCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 2 + i, rowIndex: 34);
        var wicketTimeCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 2 + i, rowIndex: 35);
        var perTimeCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 2 + i, rowIndex: 36);
        var symbolCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 2 + i, rowIndex: 37);

        // Update cells
        sheet.updateCell(defNoCell, xl.IntCellValue(turnOneData[i]['def_no']));
        if (turnOneData[i]['atk_no'] != null) {
          sheet.updateCell(
              atkNoCell, xl.IntCellValue(turnOneData[i]['atk_no']));
        } else {
          sheet.updateCell(
              atkNoCell, xl.TextCellValue(turnOneData[i]['symbol']));
        }
        sheet.updateCell(
            wicketTimeCell, xl.TextCellValue(turnOneData[i]['wicket_time']));
        sheet.updateCell(
            perTimeCell, xl.TextCellValue(turnOneData[i]['per_time']));
        sheet.updateCell(
            symbolCell, xl.TextCellValue(turnOneData[i]['symbol']));

        if (turnOneData[i]['symbol'] != "-") {
          cellsToStyle.addAll(
              [defNoCell, atkNoCell, wicketTimeCell, perTimeCell, symbolCell]);
        } else {
          cellsToStyleTurnEnd.addAll(
              [defNoCell, atkNoCell, wicketTimeCell, perTimeCell, symbolCell]);
        }
      }

      List<Map<String, dynamic>> turnTwoData =
          matchTurnData.where((map) => map["turn_no"] == 2).toList();

      for (int i = 0; i < turnTwoData.length; i++) {
        var defNoCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 22 + i, rowIndex: 33);
        var atkNoCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 22 + i, rowIndex: 34);
        var wicketTimeCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 22 + i, rowIndex: 35);
        var perTimeCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 22 + i, rowIndex: 36);
        var symbolCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 22 + i, rowIndex: 37);

        sheet.updateCell(defNoCell, xl.IntCellValue(turnTwoData[i]['def_no']));
        if (turnTwoData[i]['atk_no'] != null) {
          sheet.updateCell(
              atkNoCell, xl.IntCellValue(turnTwoData[i]['atk_no']));
        } else {
          sheet.updateCell(
              atkNoCell, xl.TextCellValue(turnTwoData[i]['symbol']));
        }
        sheet.updateCell(
            wicketTimeCell, xl.TextCellValue(turnTwoData[i]['wicket_time']));
        sheet.updateCell(
            perTimeCell, xl.TextCellValue(turnTwoData[i]['per_time']));
        sheet.updateCell(
            symbolCell, xl.TextCellValue(turnTwoData[i]['symbol']));

        if (turnTwoData[i]['symbol'] != "-") {
          cellsToStyle.addAll(
              [defNoCell, atkNoCell, wicketTimeCell, perTimeCell, symbolCell]);
        } else {
          cellsToStyleTurnEnd.addAll(
              [defNoCell, atkNoCell, wicketTimeCell, perTimeCell, symbolCell]);
        }
      }
    }

    // To Write Else of this
    if ((matchData[0]['team_a_name'] ==
        matchData[0]['turn_3_attacking_team_name'])) {
      List<Map<String, dynamic>> turnThreeData =
          matchTurnData.where((map) => map["turn_no"] == 3).toList();

      for (int i = 0; i < turnThreeData.length; i++) {
        var defNoCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 2 + i, rowIndex: 38);
        var atkNoCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 2 + i, rowIndex: 39);
        var wicketTimeCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 2 + i, rowIndex: 40);
        var perTimeCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 2 + i, rowIndex: 41);
        var symbolCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 2 + i, rowIndex: 42);

        sheet.updateCell(
            defNoCell, xl.IntCellValue(turnThreeData[i]['def_no']));
        if (turnThreeData[i]['atk_no'] != null) {
          sheet.updateCell(
              atkNoCell, xl.IntCellValue(turnThreeData[i]['atk_no']));
        } else {
          sheet.updateCell(
              atkNoCell, xl.TextCellValue(turnThreeData[i]['symbol']));
        }
        sheet.updateCell(
            wicketTimeCell, xl.TextCellValue(turnThreeData[i]['wicket_time']));
        sheet.updateCell(
            perTimeCell, xl.TextCellValue(turnThreeData[i]['per_time']));
        sheet.updateCell(
            symbolCell, xl.TextCellValue(turnThreeData[i]['symbol']));

        if (turnThreeData[i]['symbol'] != "-") {
          cellsToStyle.addAll(
              [defNoCell, atkNoCell, wicketTimeCell, perTimeCell, symbolCell]);
        } else {
          cellsToStyleTurnEnd.addAll(
              [defNoCell, atkNoCell, wicketTimeCell, perTimeCell, symbolCell]);
        }
      }

      List<Map<String, dynamic>> turnFourData =
          matchTurnData.where((map) => map["turn_no"] == 4).toList();
      for (int i = 0; i < turnFourData.length; i++) {
        var defNoCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 22 + i, rowIndex: 38);
        var atkNoCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 22 + i, rowIndex: 39);
        var wicketTimeCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 22 + i, rowIndex: 40);
        var perTimeCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 22 + i, rowIndex: 41);
        var symbolCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 22 + i, rowIndex: 42);

        sheet.updateCell(defNoCell, xl.IntCellValue(turnFourData[i]['def_no']));
        if (turnFourData[i]['atk_no'] != null) {
          sheet.updateCell(
              atkNoCell, xl.IntCellValue(turnFourData[i]['atk_no']));
        } else {
          sheet.updateCell(
              atkNoCell, xl.TextCellValue(turnFourData[i]['symbol']));
        }
        sheet.updateCell(
            wicketTimeCell, xl.TextCellValue(turnFourData[i]['wicket_time']));
        sheet.updateCell(
            perTimeCell, xl.TextCellValue(turnFourData[i]['per_time']));
        sheet.updateCell(
            symbolCell, xl.TextCellValue(turnFourData[i]['symbol']));

        if (turnFourData[i]['symbol'] != "-") {
          cellsToStyle.addAll(
              [defNoCell, atkNoCell, wicketTimeCell, perTimeCell, symbolCell]);
        } else {
          cellsToStyleTurnEnd.addAll(
              [defNoCell, atkNoCell, wicketTimeCell, perTimeCell, symbolCell]);
        }
      }
    } else {
      List<Map<String, dynamic>> turnThreeData =
          matchTurnData.where((map) => map["turn_no"] == 3).toList();

      for (int i = 0; i < turnThreeData.length; i++) {
        var defNoCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 22 + i, rowIndex: 38);
        var atkNoCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 22 + i, rowIndex: 39);
        var wicketTimeCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 22 + i, rowIndex: 40);
        var perTimeCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 22 + i, rowIndex: 41);
        var symbolCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 22 + i, rowIndex: 42);

        sheet.updateCell(
            defNoCell, xl.IntCellValue(turnThreeData[i]['def_no']));
        if (turnThreeData[i]['atk_no'] != null) {
          sheet.updateCell(
              atkNoCell, xl.IntCellValue(turnThreeData[i]['atk_no']));
        } else {
          sheet.updateCell(
              atkNoCell, xl.TextCellValue(turnThreeData[i]['symbol']));
        }
        sheet.updateCell(
            wicketTimeCell, xl.TextCellValue(turnThreeData[i]['wicket_time']));
        sheet.updateCell(
            perTimeCell, xl.TextCellValue(turnThreeData[i]['per_time']));
        sheet.updateCell(
            symbolCell, xl.TextCellValue(turnThreeData[i]['symbol']));

        if (turnThreeData[i]['symbol'] != "-") {
          cellsToStyle.addAll(
              [defNoCell, atkNoCell, wicketTimeCell, perTimeCell, symbolCell]);
        } else {
          cellsToStyleTurnEnd.addAll(
              [defNoCell, atkNoCell, wicketTimeCell, perTimeCell, symbolCell]);
        }
      }

      List<Map<String, dynamic>> turnFourData =
          matchTurnData.where((map) => map["turn_no"] == 4).toList();
      for (int i = 0; i < turnFourData.length; i++) {
        var defNoCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 2 + i, rowIndex: 38);
        var atkNoCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 2 + i, rowIndex: 39);
        var wicketTimeCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 2 + i, rowIndex: 40);
        var perTimeCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 2 + i, rowIndex: 41);
        var symbolCell =
            xl.CellIndex.indexByColumnRow(columnIndex: 2 + i, rowIndex: 42);

        sheet.updateCell(defNoCell, xl.IntCellValue(turnFourData[i]['def_no']));
        if (turnFourData[i]['atk_no'] != null) {
          sheet.updateCell(
              atkNoCell, xl.IntCellValue(turnFourData[i]['atk_no']));
        } else {
          sheet.updateCell(
              atkNoCell, xl.TextCellValue(turnFourData[i]['symbol']));
        }
        sheet.updateCell(
            wicketTimeCell, xl.TextCellValue(turnFourData[i]['wicket_time']));
        sheet.updateCell(
            perTimeCell, xl.TextCellValue(turnFourData[i]['per_time']));
        sheet.updateCell(
            symbolCell, xl.TextCellValue(turnFourData[i]['symbol']));

        if (turnFourData[i]['symbol'] != "-") {
          cellsToStyle.addAll(
              [defNoCell, atkNoCell, wicketTimeCell, perTimeCell, symbolCell]);
        } else {
          cellsToStyleTurnEnd.addAll(
              [defNoCell, atkNoCell, wicketTimeCell, perTimeCell, symbolCell]);
        }
      }
    }

    // Apply borders from Row 47 to Column 40
    var borderStyle = xl.CellStyle(
      bottomBorder: xl.Border(
          borderStyle: xl.BorderStyle.Thin,
          borderColorHex: xl.ExcelColor.fromHexString("000000")),
      topBorder: xl.Border(
          borderStyle: xl.BorderStyle.Thin,
          borderColorHex: xl.ExcelColor.fromHexString("000000")),
      leftBorder: xl.Border(
          borderStyle: xl.BorderStyle.Thin,
          borderColorHex: xl.ExcelColor.fromHexString("000000")),
      rightBorder: xl.Border(
          borderStyle: xl.BorderStyle.Thin,
          borderColorHex: xl.ExcelColor.fromHexString("000000")),
    );

    for (int row = 0; row <= 46; row++) {
      for (int col = 0; col <= 39; col++) {
        var cellIndex =
            xl.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row);
        var cell = sheet.cell(cellIndex);

        // Apply border only if the cell exists, preserving its value
        cell.cellStyle = borderStyle;
      }
    }
    // Try to add border and center
    for (var cell in cellsToStyle) {
      addDefaultCellStyle(sheet, cell.columnIndex, cell.rowIndex);
    }
    for (var cell in cellsToStyleTurnEnd) {
      addThickCellStyle(sheet, cell.columnIndex, cell.rowIndex);
    }
    // Save modified file
    List<int>? modifiedBytes = excel.encode();
    if (modifiedBytes != null) {
      await file.writeAsBytes(modifiedBytes);
      print("Excel file modified and saved at: $filePath");
    } else {
      print("Error: Failed to save modified Excel file.");
    }
  } catch (e) {
    print("An error occurred: $e");
  }
}
