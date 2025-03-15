import 'package:excel/excel.dart';

var cellStyle = CellStyle(
  horizontalAlign: HorizontalAlign.Center,
  verticalAlign: VerticalAlign.Center,
  bottomBorder: Border(
      borderStyle: BorderStyle.Thin,
      borderColorHex: ExcelColor.fromHexString("000000")),
  topBorder: Border(
      borderStyle: BorderStyle.Thin,
      borderColorHex: ExcelColor.fromHexString("000000")),
  leftBorder: Border(
      borderStyle: BorderStyle.Thin,
      borderColorHex: ExcelColor.fromHexString("000000")),
  rightBorder: Border(
      borderStyle: BorderStyle.Thin,
      borderColorHex: ExcelColor.fromHexString("000000")),
);

var cellStyleThickBorder = CellStyle(
  horizontalAlign: HorizontalAlign.Center,
  verticalAlign: VerticalAlign.Center,
  bottomBorder: Border(
      borderStyle: BorderStyle.Thick,
      borderColorHex: ExcelColor.fromHexString("000000")),
  topBorder: Border(
      borderStyle: BorderStyle.Thick,
      borderColorHex: ExcelColor.fromHexString("000000")),
  leftBorder: Border(
      borderStyle: BorderStyle.Thick,
      borderColorHex: ExcelColor.fromHexString("000000")),
  rightBorder: Border(
      borderStyle: BorderStyle.Thick,
      borderColorHex: ExcelColor.fromHexString("000000")),
);

var cellStyleTeamNames = CellStyle(
  horizontalAlign: HorizontalAlign.Left,
  verticalAlign: VerticalAlign.Center,
  bottomBorder: Border(
      borderStyle: BorderStyle.Thick,
      borderColorHex: ExcelColor.fromHexString("000000")),
  topBorder: Border(
      borderStyle: BorderStyle.Thick,
      borderColorHex: ExcelColor.fromHexString("000000")),
  leftBorder: Border(
      borderStyle: BorderStyle.Thick,
      borderColorHex: ExcelColor.fromHexString("000000")),
  rightBorder: Border(
      borderStyle: BorderStyle.Thick,
      borderColorHex: ExcelColor.fromHexString("000000")),
);

var cellStylePointsTable = CellStyle(
  horizontalAlign: HorizontalAlign.Left,
  verticalAlign: VerticalAlign.Bottom,
  bottomBorder: Border(
      borderStyle: BorderStyle.Thin,
      borderColorHex: ExcelColor.fromHexString("000000")),
  topBorder: Border(
      borderStyle: BorderStyle.Thin,
      borderColorHex: ExcelColor.fromHexString("000000")),
  leftBorder: Border(
      borderStyle: BorderStyle.Thin,
      borderColorHex: ExcelColor.fromHexString("000000")),
  rightBorder: Border(
      borderStyle: BorderStyle.Thin,
      borderColorHex: ExcelColor.fromHexString("000000")),
);

addDefaultCellStyle(sheet, col, row) {
  var cellIndex = CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row);
  var cell = sheet.cell(cellIndex);

  // Apply border only if the cell exists, preserving its value
  cell.cellStyle = cellStyle;
}

addThickCellStyle(sheet, col, row) {
  var cellIndex = CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row);
  var cell = sheet.cell(cellIndex);

  // Apply border only if the cell exists, preserving its value
  cell.cellStyle = cellStyleThickBorder;
}

addIndividualNotOutCellStyle(sheet, col, row) {
  var cellIndex = CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row);
  var cell = sheet.cell(cellIndex);

  // Apply border only if the cell exists, preserving its value
  cell.cellStyle = cellStyleThickBorder;
}

addTeamNamesStyle(sheet, col, row) {
  var cellIndex = CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row);
  var cell = sheet.cell(cellIndex);

  // Apply border only if the cell exists, preserving its value
  cell.cellStyle = cellStyleTeamNames;
}

addPointsTableStyle(sheet, col, row) {
  var cellIndex = CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row);
  var cell = sheet.cell(cellIndex);

  // Apply border only if the cell exists, preserving its value
  cell.cellStyle = cellStylePointsTable;
}
