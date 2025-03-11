import 'dart:io';

import 'package:excel/excel.dart' as xl;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kho_kho_scoresheet/helpers/excel_helper.dart';
import 'package:kho_kho_scoresheet/helpers/time_manipulation.dart';
import 'package:kho_kho_scoresheet/supabase/db_queries.dart';
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
    readAndWriteExcel(widget.matchId);
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
            "Creating excel",
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
        sheet.updateCell(atkNoCell, xl.IntCellValue(turnOneData[i]['atk_no']));
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

        sheet.updateCell(defNoCell, xl.IntCellValue(turnOneData[i]['def_no']));
        sheet.updateCell(atkNoCell, xl.IntCellValue(turnTwoData[i]['atk_no']));
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
