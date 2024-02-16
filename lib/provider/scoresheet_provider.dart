import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ScoresheetProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _matchData = [];

  List<Map<String, dynamic>> get matchScoreList => _matchData;

  void addTurnData(List<Map<String, dynamic>> turnData, int turnCount) {
    Map<String, dynamic> allTurnsMap = {};
    allTurnsMap['$turnCount'] = turnData;
    _matchData.add(allTurnsMap);
    notifyListeners();
  }

  List exportToJson() {
    return _matchData;
  }
}
