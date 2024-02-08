import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kho_kho_scoresheet/constants/color_constants.dart';
import 'package:kho_kho_scoresheet/constants/symbols.dart';
import 'package:kho_kho_scoresheet/helpers/derive_symbol.dart';
import 'package:kho_kho_scoresheet/helpers/write_to_excel.dart';
import 'package:kho_kho_scoresheet/screens/start_screen.dart';
import 'package:remix_icon_icons/remix_icon_icons.dart';

class ScoreSheet extends StatefulWidget {
  const ScoreSheet({super.key});

  @override
  State<ScoreSheet> createState() => _ScoreSheetState();
}

TextEditingController defenderFieldController = TextEditingController();
TextEditingController attackerFieldController = TextEditingController();

String defenderFieldValue = "";
String attackerFieldValue = "";

void onDefenderFieldChange(defenderFieldValue) {
  defenderFieldValue = defenderFieldValue;
}

void onAttackerFieldChange(attackerFieldValue) {
  attackerFieldValue = attackerFieldValue;
}

class _ScoreSheetState extends State<ScoreSheet> {
  int _secondsRemaining = 0;
  late Timer _timer;

  void _updateTimer(Timer timer) {
    setState(() {
      _secondsRemaining++;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  double sliderValue = 0;
  bool isMatchStarted = false;
  List<Map<String, String>> data = [];

  @override
  Widget build(BuildContext context) {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Kho-Kho Scoresheet'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isMatchStarted = true;
                });
                _timer = Timer.periodic(
                  const Duration(seconds: 1),
                  _updateTimer,
                );
              },
              child: const Text('Start Match'),
            ),
            Center(
              child: Text(
                '$minutes:${seconds < 10 ? '0' : ''}$seconds',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Defender\'s Number',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                        RegExp(r"^[0-9]+$"),
                      )
                    ],
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      onDefenderFieldChange(value);
                    },
                    controller: defenderFieldController,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 16,
                      ),
                      errorStyle: TextStyle(
                        color: ColorConstants.error,
                      ),
                      counterText: '',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        borderSide: BorderSide(
                          width: 1,
                          color: Colors.black,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        borderSide: BorderSide(
                          width: 1,
                          color: Colors.black,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        borderSide: BorderSide(
                          width: 1,
                          color: ColorConstants.error,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        borderSide: BorderSide(
                          width: 1,
                          color: ColorConstants.error,
                        ),
                      ),
                    ),
                    autofocus: true,
                    maxLength: 2,
                    autocorrect: false,
                    enableSuggestions: false,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      defenderFieldController.clear();
                    });
                  },
                  icon: const Icon(
                    RemixIcon.close_outline,
                    color: Colors.red,
                  ),
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                      Colors.white,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attacker\'s Number ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                        RegExp(r"^[0-9]+$"),
                      )
                    ],
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      onAttackerFieldChange(value);
                    },
                    controller: attackerFieldController,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 16,
                      ),
                      errorStyle: TextStyle(
                        color: ColorConstants.error,
                      ),
                      counterText: '',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        borderSide: BorderSide(
                          width: 1,
                          color: Colors.black,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        borderSide: BorderSide(
                          width: 1,
                          color: Colors.black,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        borderSide: BorderSide(
                          width: 1,
                          color: ColorConstants.error,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        borderSide: BorderSide(
                          width: 1,
                          color: ColorConstants.error,
                        ),
                      ),
                    ),
                    autofocus: true,
                    maxLength: 2,
                    autocorrect: false,
                    enableSuggestions: false,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      attackerFieldController.clear();
                    });
                  },
                  icon: const Icon(
                    RemixIcon.close_outline,
                    color: Colors.red,
                  ),
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                      Colors.white,
                    ),
                  ),
                  tooltip: 'Clear',
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Symbol',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            Slider.adaptive(
              value: sliderValue,
              divisions: 11,
              min: 0,
              max: 11,
              autofocus: true,
              secondaryActiveColor: Colors.red,
              activeColor: Colors.blue,
              overlayColor: const MaterialStatePropertyAll(Colors.blue),
              allowedInteraction: SliderInteraction.tapAndSlide,
              label: deriveSymbol(sliderValue),
              thumbColor: Colors.blue,
              onChanged: (value) {
                setState(() {
                  sliderValue = value;
                });
              },
            ),
            // ListView.builder(
            //   scrollDirection: Axis.horizontal,
            //   itemCount: symbolList.length,
            //   itemBuilder: (context, index) {
            //     return Text(symbolList[index]);
            //   },
            // ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (isMatchStarted == true) {
                    Map<String, String> entry = {
                      "def_number": defenderFieldController.text,
                      "atk_number": attackerFieldController.text,
                      "run_time":
                          '$minutes:${seconds < 10 ? '0$seconds' : seconds}',
                      "symbol": deriveSymbol(sliderValue),
                    };
                    data.add(entry);
                    setState(() {
                      defenderFieldController.clear();
                      attackerFieldController.clear();
                      sliderValue = 0;
                    });
                  } else {
                    null;
                  }
                },
                child: const Text('Enter Data'),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                writeToExcel(data);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const StartScreen(),
                  ),
                );
              },
              child: const Text('End Match'),
            )
          ],
        ),
      ),
    );
  }
}
