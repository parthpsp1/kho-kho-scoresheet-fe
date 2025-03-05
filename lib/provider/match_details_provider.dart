import 'package:flutter/material.dart';

class MatchDetailsProvider extends ChangeNotifier {
  String teamAName;
  String teamBName;
  String ageGroup;
  String tossWinner;
  String sideChoice;
  Map<String, String> defAttackerMap = {};
  // Save perTimes i.e. wicket time t2 - t1 wicket times etc.
  List<Duration> perTimes = [];

  MatchDetailsProvider({
    this.ageGroup = 'U-14',
    this.tossWinner = 'A',
    this.sideChoice = 'DEF',
    this.teamAName = '',
    this.teamBName = '',
  });

  void updateTeamAName(String teamAName) {
    this.teamAName = teamAName;
  }

  void updateTeamBName(String teamBName) {
    this.teamBName = teamBName;
  }
}
