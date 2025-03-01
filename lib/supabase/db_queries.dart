import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDBQuery {
  // Singleton Instance
  static final SupabaseDBQuery _instance = SupabaseDBQuery._internal();
  factory SupabaseDBQuery() => _instance;
  SupabaseDBQuery._internal();

  final supabase = Supabase.instance.client;

  /// Inserts a match and returns its ID
  Future<int> insertIntoMatches(
      String ageGroup, String teamAName, String teamBName) async {
    try {
      final response = await supabase
          .from('matches')
          .insert({
            'age_group': ageGroup,
            'team_a_name': teamAName,
            'team_b_name': teamBName,
          })
          .select('id') // Fetch the inserted row ID
          .single(); // Extract single row

      return response['id']; // Return the ID
    } catch (error) {
      print('Error inserting match: $error');
      throw Exception('Failed to insert match');
    }
  }

  /// Inserts toss details linked to a match ID
  Future<void> insertIntoTossDetails(
      int matchId, String tossWinner, String sideChoice) async {
    try {
      await supabase.from('toss_details').insert({
        'match_id': matchId,
        'toss_winner_team_name': tossWinner,
        'chosen_side': sideChoice,
      });
    } catch (error) {
      print('Error inserting toss details: $error');
      throw Exception('Failed to insert toss details');
    }
  }

  /// Inserts round_details linked to a match ID
  Future<void> insertIntoRoundDetails(int roundNo, int matchId, int defNo,
      int atkNo, String wicketTime, String symbol) async {
    try {
      await supabase.from('round_details').insert({
        'round_no': roundNo,
        'match_id': matchId,
        'def_no': defNo,
        'atk_no': atkNo,
        'wicket_time': wicketTime,
        'symbol': symbol,
      });
    } catch (error) {
      print('Error inserting toss details: $error');
      throw Exception('Failed to insert toss details');
    }
  }
}
