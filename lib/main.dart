import 'package:flutter/material.dart';
import 'package:kho_kho_scoresheet/provider/match_details_provider.dart';
import 'package:kho_kho_scoresheet/provider/scoresheet_provider.dart';
import 'package:kho_kho_scoresheet/screens/start_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://wxtbkzexmxblkleydfdb.supabase.co';
const supabaseKey =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind4dGJremV4bXhibGtsZXlkZmRiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA3MTU1NTEsImV4cCI6MjA1NjI5MTU1MX0.CZWYvgVab01MhbYX31MeDUyjD8ug2_jqylJctYUXxoM";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
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
