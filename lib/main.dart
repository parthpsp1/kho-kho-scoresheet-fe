import 'package:flutter/material.dart';
import 'package:kho_kho_scoresheet/provider/match_details_provider.dart';
import 'package:kho_kho_scoresheet/provider/scoresheet_provider.dart';
import 'package:kho_kho_scoresheet/screens/start_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => MatchDetailsProvider(),
        lazy: true,
      ),
      ChangeNotifierProvider(
        create: (context) => ScoresheetProvider(),
        lazy: true,
      ),
    ],
    child: const KhoKhoScoresheet(),
  ));
}

class KhoKhoScoresheet extends StatelessWidget {
  const KhoKhoScoresheet({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
        ),
      ),
      home: const StartScreen(),
    );
  }
}
