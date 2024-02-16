import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kho_kho_scoresheet/constants/color_constants.dart';
import 'package:kho_kho_scoresheet/constants/symbols.dart';
import 'package:kho_kho_scoresheet/helpers/derive_symbol.dart';
import 'package:kho_kho_scoresheet/helpers/excel_module.dart';
import 'package:kho_kho_scoresheet/helpers/permission_handler.dart';
import 'package:kho_kho_scoresheet/provider/match_details_provider.dart';
import 'package:kho_kho_scoresheet/screens/start_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:remix_icon_icons/remix_icon_icons.dart';

class ScoreSheet extends StatefulWidget {
  const ScoreSheet({
    super.key,
  });

  @override
  State<ScoreSheet> createState() => _ScoreSheetState();
}

TextEditingController defenderFieldController = TextEditingController();
TextEditingController attackerFieldController = TextEditingController();

String defenderFieldValue = "";
String attackerFieldValue = "";
int selectedSymbol = -1;
String wicketTime = '';
bool isTurnTimEnded = false;
bool isWicketAdded = false;
int turnCount = 0;

Map<String, dynamic> singleTurnData = {};
List<Map<String, dynamic>> allRunTimes = [];
List<Map<String, dynamic>> matchData = [];

void onDefenderFieldChange(defenderFieldValue) {
  defenderFieldValue = defenderFieldValue;
}

void onAttackerFieldChange(attackerFieldValue) {
  attackerFieldValue = attackerFieldValue;
}

List<String> deriveDefenderAttacker(tossWinnerIndex, defAtkChoiceIndex) {
  if (tossWinnerIndex == 0 && defAtkChoiceIndex == 0) {
    return ['A', 'B'];
  }
  if (tossWinnerIndex == 1 && defAtkChoiceIndex == 1) {
    return ['A', 'B'];
  }
  if (tossWinnerIndex == 0 && defAtkChoiceIndex == 1) {
    return ['B', 'A'];
  }
  return ['B', 'A'];
}

class _ScoreSheetState extends State<ScoreSheet> {
  int _secondsPassed = 0;
  late Timer _timer;

  void _updateTimer(Timer timer, int ageGroup) {
    if (ageGroup == 0) {
      if (_secondsPassed < 7 * 60) {
        setState(() {
          _secondsPassed++;
        });
      } else {
        setState(() {
          isTurnTimEnded = true;
        });
      }
    }
    if (ageGroup == 1) {
      if (_secondsPassed < 9 * 60) {
        setState(() {
          _secondsPassed++;
        });
      } else {
        setState(() {
          isTurnTimEnded = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  bool isMatchStarted = false;

  @override
  void initState() {
    runRequestPermissions();
    super.initState();
  }

  Future<void> runRequestPermissions() async {
    await requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    int minutes = _secondsPassed ~/ 60;
    int seconds = _secondsPassed % 60;

    List<String> defenderAndAttacker = deriveDefenderAttacker(
        Provider.of<MatchDetailsProvider>(context, listen: false).tossWinner,
        Provider.of<MatchDetailsProvider>(context, listen: false).defAtkChoice);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Kho-Kho Scoresheet'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              child: IconButton(
                color: Colors.white,
                onPressed: () {
                  showAdaptiveDialog(
                    context: context,
                    builder: (builder) {
                      return AlertDialog.adaptive(
                        title: const Text("End Match?"),
                        content: const IntrinsicHeight(
                          child: Text(
                            "Do you really wish to end the match and export the match details to excel?",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: const ButtonStyle(
                              overlayColor: MaterialStatePropertyAll(
                                  ColorConstants.primaryOverlayColor),
                            ),
                            child: const Text(
                              "No",
                              style: TextStyle(
                                color: Color.fromRGBO(17, 27, 47, 1),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              createExcel(matchData, defenderAndAttacker);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const StartScreen(),
                                ),
                              );
                              setState(() {
                                turnCount = 0;
                              });
                            },
                            style: const ButtonStyle(
                              overlayColor: MaterialStatePropertyAll(
                                  ColorConstants.primaryOverlayColor),
                            ),
                            child: const Text(
                              "Confirm",
                              style: TextStyle(
                                color: Color.fromRGBO(17, 27, 47, 1),
                              ),
                            ),
                          ),
                        ],
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(18),
                          ),
                        ),
                        titlePadding: const EdgeInsets.only(
                          top: 20,
                          left: 20,
                          right: 20,
                        ),
                        titleTextStyle: const TextStyle(
                          color: Color.fromRGBO(17, 47, 27, 1),
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                        ),
                        contentPadding: const EdgeInsets.only(
                          top: 10,
                          left: 20,
                          right: 20,
                          bottom: 24,
                        ),
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.white,
                        actionsPadding: const EdgeInsets.only(
                          bottom: 16,
                          left: 20,
                          right: 20,
                          top: 10,
                        ),
                      );
                    },
                  );
                },
                icon: const Icon(RemixIcon.close_outline),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: PopScope(
          canPop: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Turn ${turnCount + 1} will end at ${Provider.of<MatchDetailsProvider>(context, listen: false).ageGroup == 0 ? "7:00" : "9:00"} minutes',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 28,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      '$minutes:${seconds < 10 ? '0' : ''}$seconds',
                      style: const TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
                const SizedBox(
                  height: 8,
                ),
                isMatchStarted == true
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    wicketTime =
                                        '$minutes:${seconds < 10 ? '0' : ''}$seconds';
                                    isWicketAdded = true;
                                  });
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(RemixIcon.add_circle_outline),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      'Add Wicket',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(
                        height: 40,
                      ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DEF (${defenderAndAttacker[0]}) Number',
                      style: const TextStyle(
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
                            vertical: 12,
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
                        autofocus: false,
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
                if (selectedSymbol != 4 &&
                    selectedSymbol != 5 &&
                    selectedSymbol != 6 &&
                    selectedSymbol != 8 &&
                    selectedSymbol != 11 &&
                    selectedSymbol != 12)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ATK (${defenderAndAttacker[1]}) Number',
                        style: const TextStyle(
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
                              vertical: 12,
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
                  )
                else
                  const SizedBox(height: 48),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Wicket Time',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      wicketTime,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          wicketTime = '';
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
                  height: 8,
                ),
                const Text(
                  'Symbol',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: GridView.count(
                    crossAxisCount: 7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: List.generate(13, (index) {
                      return SizedBox(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              if (selectedSymbol == index) {
                                selectedSymbol = -1;
                              } else {
                                selectedSymbol = index;
                              }
                            });
                          },
                          style: ButtonStyle(
                            surfaceTintColor:
                                const MaterialStatePropertyAll(Colors.black),
                            shape: const MaterialStatePropertyAll(
                              ContinuousRectangleBorder(
                                side: BorderSide(
                                  color: Colors.transparent,
                                  width: 0,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                            ),
                            padding: const MaterialStatePropertyAll(
                              EdgeInsets.all(0),
                            ),
                            overlayColor:
                                const MaterialStatePropertyAll(Colors.blue),
                            backgroundColor: index == selectedSymbol
                                ? const MaterialStatePropertyAll(Colors.blue)
                                : const MaterialStatePropertyAll(Colors.white),
                            foregroundColor: index == selectedSymbol
                                ? const MaterialStatePropertyAll(Colors.white)
                                : const MaterialStatePropertyAll(Colors.black),
                            tapTargetSize: MaterialTapTargetSize.padded,
                          ),
                          child: Text(
                            symbolList[index],
                            style: index == 12
                                ? const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  )
                                : const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                isMatchStarted == true
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            height: 40,
                            width: 120,
                            child: ElevatedButton(
                              onPressed: () {
                                showAdaptiveDialog(
                                  context: context,
                                  builder: (builder) {
                                    return AlertDialog.adaptive(
                                      title: const Text("End Turn?"),
                                      content: const IntrinsicHeight(
                                        child: Text(
                                          "Please confirm end of turn",
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: const ButtonStyle(
                                            overlayColor:
                                                MaterialStatePropertyAll(
                                                    ColorConstants
                                                        .primaryOverlayColor),
                                          ),
                                          child: const Text(
                                            "No",
                                            style: TextStyle(
                                              color:
                                                  Color.fromRGBO(17, 27, 47, 1),
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            singleTurnData[turnCount
                                                .toString()] = allRunTimes;
                                            matchData.add(singleTurnData);
                                            setState(() {
                                              turnCount++;
                                              allRunTimes = [];
                                            });
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const ScoreSheet(),
                                              ),
                                            );
                                          },
                                          style: const ButtonStyle(
                                            overlayColor:
                                                MaterialStatePropertyAll(
                                                    ColorConstants
                                                        .primaryOverlayColor),
                                          ),
                                          child: const Text(
                                            "Confirm",
                                            style: TextStyle(
                                              color:
                                                  Color.fromRGBO(17, 27, 47, 1),
                                            ),
                                          ),
                                        ),
                                      ],
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(18),
                                        ),
                                      ),
                                      titlePadding: const EdgeInsets.only(
                                        top: 20,
                                        left: 20,
                                        right: 20,
                                      ),
                                      titleTextStyle: const TextStyle(
                                        color: Color.fromRGBO(17, 47, 27, 1),
                                        fontSize: 21,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      contentPadding: const EdgeInsets.only(
                                        top: 10,
                                        left: 20,
                                        right: 20,
                                        bottom: 24,
                                      ),
                                      backgroundColor: Colors.white,
                                      surfaceTintColor: Colors.white,
                                      actionsPadding: const EdgeInsets.only(
                                        bottom: 16,
                                        left: 20,
                                        right: 20,
                                        top: 10,
                                      ),
                                    );
                                  },
                                );
                              },
                              style: const ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                  Color.fromARGB(255, 246, 163, 157),
                                ),
                              ),
                              child: const Text(
                                'End Turn',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          isWicketAdded == true
                              ? SizedBox(
                                  height: 40,
                                  width: 120,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (isMatchStarted == true) {
                                        Map<String, String> singleRunTime = {
                                          "def_number":
                                              defenderFieldController.text,
                                          "atk_number": (selectedSymbol == 4 ||
                                                  selectedSymbol == 5 ||
                                                  selectedSymbol == 6 ||
                                                  selectedSymbol == 8 ||
                                                  selectedSymbol == 11 ||
                                                  selectedSymbol == 12)
                                              ? '-'
                                              : attackerFieldController.text,
                                          "run_time": wicketTime,
                                          "symbol":
                                              deriveSymbol(selectedSymbol),
                                        };
                                        allRunTimes.add(singleRunTime);
                                        setState(() {
                                          defenderFieldController.clear();
                                          attackerFieldController.clear();
                                          selectedSymbol = -1;
                                          wicketTime = '';
                                          isWicketAdded = false;
                                        });
                                      } else {
                                        null;
                                      }
                                    },
                                    child: const Text('Enter Data'),
                                  ),
                                )
                              : const SizedBox(
                                  height: 40,
                                  width: 120,
                                ),
                        ],
                      )
                    : SizedBox(
                        height: 40,
                        width: 120,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isMatchStarted = true;
                            });
                            _timer = Timer.periodic(
                              const Duration(seconds: 1),
                              (Timer timer) => _updateTimer(
                                timer,
                                Provider.of<MatchDetailsProvider>(context,
                                        listen: false)
                                    .ageGroup,
                              ),
                            );
                          },
                          child: const Text('Start Turn'),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
