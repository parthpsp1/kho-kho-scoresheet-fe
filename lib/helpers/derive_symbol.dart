import 'package:kho_kho_scoresheet/constants/symbols.dart';

String deriveSymbol(int selectedSymbolIndex) {
  if (selectedSymbolIndex >= 0 && selectedSymbolIndex < symbolList.length) {
    return symbolList[selectedSymbolIndex];
  } else {
    return 'Invalid Index';
  }
}
