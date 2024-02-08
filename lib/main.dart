import 'package:flutter/material.dart';
import 'package:kho_kho_scoresheet/screens/start_screen.dart';

void main() {
  runApp(const KhoKhoScoresheet());
}

class KhoKhoScoresheet extends StatelessWidget {
  const KhoKhoScoresheet({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const StartScreen(),
    );
  }
}
