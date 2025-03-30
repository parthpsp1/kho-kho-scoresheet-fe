import 'package:excel/excel.dart';

CellStyle createCellStyle({
  required HorizontalAlign horizontalAlign,
  required VerticalAlign verticalAlign,
  required BorderStyle borderStyle,
  required String borderColorHex,
}) {
  return CellStyle(
    horizontalAlign: horizontalAlign,
    verticalAlign: verticalAlign,
    bottomBorder: Border(
      borderStyle: borderStyle,
      borderColorHex: ExcelColor.fromHexString(borderColorHex),
    ),
    topBorder: Border(
      borderStyle: borderStyle,
      borderColorHex: ExcelColor.fromHexString(borderColorHex),
    ),
    leftBorder: Border(
      borderStyle: borderStyle,
      borderColorHex: ExcelColor.fromHexString(borderColorHex),
    ),
    rightBorder: Border(
      borderStyle: borderStyle,
      borderColorHex: ExcelColor.fromHexString(borderColorHex),
    ),
  );
}

final cellStyle = createCellStyle(
  horizontalAlign: HorizontalAlign.Center,
  verticalAlign: VerticalAlign.Center,
  borderStyle: BorderStyle.Thin,
  borderColorHex: "000000",
);

final cellStyleThickBorder = createCellStyle(
  horizontalAlign: HorizontalAlign.Center,
  verticalAlign: VerticalAlign.Center,
  borderStyle: BorderStyle.Thick,
  borderColorHex: "000000",
);

final cellStyleTeamNames = createCellStyle(
  horizontalAlign: HorizontalAlign.Left,
  verticalAlign: VerticalAlign.Center,
  borderStyle: BorderStyle.Thick,
  borderColorHex: "000000",
);

final cellStylePointsTable = createCellStyle(
  horizontalAlign: HorizontalAlign.Left,
  verticalAlign: VerticalAlign.Bottom,
  borderStyle: BorderStyle.Thin,
  borderColorHex: "000000",
);

void applyCellStyle(Sheet sheet, int col, int row, CellStyle style) {
  var cellIndex = CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row);
  var cell = sheet.cell(cellIndex);
  cell.cellStyle = style;
}

void addDefaultCellStyle(Sheet sheet, int col, int row) {
  applyCellStyle(sheet, col, row, cellStyle);
}

void addThickCellStyle(Sheet sheet, int col, int row) {
  applyCellStyle(sheet, col, row, cellStyleThickBorder);
}

void addIndividualNotOutCellStyle(Sheet sheet, int col, int row) {
  applyCellStyle(sheet, col, row, cellStyleThickBorder);
}

void addTeamNamesStyle(Sheet sheet, int col, int row) {
  applyCellStyle(sheet, col, row, cellStyleTeamNames);
}

void addPointsTableStyle(Sheet sheet, int col, int row) {
  applyCellStyle(sheet, col, row, cellStylePointsTable);
}
