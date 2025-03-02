import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> matchData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMatchData();
  }

  Future<void> fetchMatchData() async {
    final response = await supabase
        .from('matches')
        .select('*,toss_details(*)')
        .eq('id', '27');

    if (mounted) {
      setState(() {
        matchData = response;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Players')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: matchData.length,
              itemBuilder: (context, index) {
                final player = matchData[index];
                return ListTile(
                  title: Text(player['age_group']),
                );
              },
            ),
    );
  }
}
