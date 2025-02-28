import 'package:flutter/material.dart';

class MatchDetailsProvider extends ChangeNotifier {
  String teamAName;
  String teamBName;
  String ageGroup;
  String tossWinner;
  String sideChoice;

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

  void updateAgeGroup(String ageGroup) {
    this.ageGroup = ageGroup;
  }

  void updateTossWinner(String tossWinner) {
    this.tossWinner = tossWinner;
  }

  void updateDefAtkChoice(String sideChoice) {
    this.sideChoice = sideChoice;
  }

  void clearMatchData() {
    ageGroup = 'U-14';
    tossWinner = 'A';
    sideChoice = 'DEF';
    teamAName = '';
    teamBName = '';
  }
}
