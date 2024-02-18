String deriveMatchScoreForTeamA(List<Map<String, dynamic>> allTurnScore) {
  for (var i = 0; i < allTurnScore.length; i++) {
    if (allTurnScore[i].containsKey('A')) {
      return allTurnScore[i]['A'].toString();
    }
  }
  return '';
}

String deriveMatchScoreForTeamB(List<Map<String, dynamic>> allTurnScore) {
  for (var i = 0; i < allTurnScore.length; i++) {
    if (allTurnScore[i].containsKey('B')) {
      return allTurnScore[i]['B'].toString();
    }
  }
  return '';
}
