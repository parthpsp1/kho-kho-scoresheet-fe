import 'package:excel/excel.dart';
import 'package:kho_kho_scoresheet/helpers/time_diff.dart';

void writeToExcel(List<Map<String, String>> scoreSheetData) async {
  Excel excel = Excel.createExcel();
  Sheet sheet = excel['Sheet1'];
  List<Map<String, String>> runTimes = [];

  // Write headers
  sheet.cell(CellIndex.indexByString("A2")).value =
      const TextCellValue("Defender Number");
  sheet.cell(CellIndex.indexByString("A3")).value =
      const TextCellValue("Attacker Number");
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

  excel.save(fileName: 'real_match_test.xlsx');
}
