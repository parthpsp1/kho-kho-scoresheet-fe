import 'package:flutter/material.dart';

class MatchDetailsProvider extends ChangeNotifier {
  int ageGroup;
  int tossWinner;
  int defAtkChoice;

  MatchDetailsProvider({
    this.ageGroup = 0,
    this.tossWinner = 0,
    this.defAtkChoice = 0,
  });

  void updateAgeGroup(int ageGroup) {
    this.ageGroup = ageGroup;
  }

  void updateTossWinner(int tossWinner) {
    this.tossWinner = tossWinner;
  }

  void updateDefAtkChoice(int defAtkChoice) {
    this.defAtkChoice = defAtkChoice;
  }

  void clearData() {
    ageGroup = 0;
    tossWinner = 0;
    defAtkChoice = 0;
  }
}
