import 'package:kho_kho_scoresheet/constants/symbols.dart';

String deriveSymbol(double symbolSliderValue) {
  int index = symbolSliderValue.toInt();
  if (index >= 0 && index < symbolList.length) {
    return symbolList[index];
  } else {
    return 'Invalid Index';
  }
}
