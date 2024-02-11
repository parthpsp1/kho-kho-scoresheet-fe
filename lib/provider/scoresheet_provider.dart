import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ScoresheetProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _scoreSheetList = [];

  List<Map<String, dynamic>> get scoreSheetList => _scoreSheetList;

  void addJsonObject(Map<String, dynamic> jsonObject) {
    _scoreSheetList.add(jsonObject);
    notifyListeners();
  }

  List exportToJson() {
    return _scoreSheetList;
  }
}
