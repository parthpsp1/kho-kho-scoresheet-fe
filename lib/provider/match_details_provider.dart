import 'package:flutter/material.dart';

class MatchDetailsProvider extends ChangeNotifier {
  String teamAName;
  String teamBName;
  int ageGroup;
  int tossWinner;
  int defAtkChoice;

  MatchDetailsProvider({
    this.ageGroup = 0,
    this.tossWinner = 0,
    this.defAtkChoice = 0,
    this.teamAName = '',
    this.teamBName = '',
  });

  void updateTeamAName(String teamAName) {
    this.teamAName = teamAName;
  }

  void updateTeamBName(String teamBName) {
    this.teamBName = teamBName;
  }

  void updateAgeGroup(int ageGroup) {
    this.ageGroup = ageGroup;
  }

  void updateTossWinner(int tossWinner) {
    this.tossWinner = tossWinner;
  }

  void updateDefAtkChoice(int defAtkChoice) {
    this.defAtkChoice = defAtkChoice;
  }

  void clearMatchData() {
    ageGroup = 0;
    tossWinner = 0;
    defAtkChoice = 0;
    teamAName = '';
    teamBName = '';
  }
}
