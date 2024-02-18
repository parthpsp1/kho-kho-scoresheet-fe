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
import 'package:provider/provider.dart';
import 'package:remix_icon_icons/remix_icon_icons.dart';
import 'package:wheel_chooser/wheel_chooser.dart';

class ScoreSheet extends StatefulWidget {
  const ScoreSheet({
    super.key,
  });

  @override
  State<ScoreSheet> createState() => _ScoreSheetState();
}

String defenderFieldValue = "";
String attackerFieldValue = "";
int selectedSymbol = -1;
String wicketTime = '';
bool isTurnTimEnded = false;
bool isWicketAdded = false;
int turnCount = 0;
int selectedPlayerNumberIndex = 0;
bool isMatchStarted = false;
Map<String, dynamic> singleTurnData = {};
List<Map<String, dynamic>> allRunTimes = [];
List<Map<String, dynamic>> matchData = [];
List teamAScore = [];
List teamBScore = [];

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

  @override
  void initState() {
    _timer = Timer(Duration.zero, () {});
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
        title: const Text(
          'Kho-Kho Scoresheet',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        titleSpacing: 20,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: TextButton(
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
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const StartScreen(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                            if (defenderAndAttacker[0] == 'A') {
                              teamAScore.add(allRunTimes.length - 1);
                            }
                            if (defenderAndAttacker[0] == 'B') {
                              teamAScore.add(allRunTimes.length - 1);
                            }
                            setState(() {
                              matchData = [];
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
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.red),
                foregroundColor: MaterialStatePropertyAll(Colors.white),
              ),
              child: const Text('End Match'),
            ),
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 16,
              ),
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
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
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
                      ),
                    )
                  : const SizedBox(
                      height: 40,
                    ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'DEF (${turnCount.isEven ? defenderAndAttacker[0] : defenderAndAttacker[1]}) Number',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                      height: 40,
                      width: 160,
                      child: WheelChooser(
                        onValueChanged: (s) {
                          setState(() {
                            defenderFieldValue = s.toString();
                          });
                        },
                        datas: List.generate(15, (index) => index + 1),
                        horizontal: true,
                        isInfinite: false,
                        squeeze: 1,
                        magnification: 1,
                        selectTextStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        unSelectTextStyle: const TextStyle(
                          fontWeight: FontWeight.w100,
                        ),
                        startPosition: selectedPlayerNumberIndex,
                        physics: const ClampingScrollPhysics(),
                      ),
                    ),
                  ],
                ),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'ATK (${turnCount.isEven ? defenderAndAttacker[1] : defenderAndAttacker[0]}) Number',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        height: 40,
                        width: 160,
                        child: WheelChooser(
                          onValueChanged: (s) {
                            setState(() {
                              attackerFieldValue = s.toString();
                            });
                          },
                          datas: List.generate(15, (index) => index + 1),
                          horizontal: true,
                          isInfinite: false,
                          squeeze: 1,
                          magnification: 1,
                          selectTextStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          unSelectTextStyle: const TextStyle(
                            fontWeight: FontWeight.w100,
                          ),
                          startPosition: selectedPlayerNumberIndex,
                          physics: const ClampingScrollPhysics(),
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(height: 48),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Wicket Time',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          wicketTime,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
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
                  ],
                ),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 140,
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
                                          setState(() {
                                            singleTurnData[turnCount
                                                .toString()] = allRunTimes;
                                            matchData.add(singleTurnData);
                                            turnCount++;
                                            allRunTimes = [];
                                            isMatchStarted = false;
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
                                Color.fromRGBO(177, 50, 50, 1),
                              ),
                            ),
                            child: const Text(
                              'End Turn',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        isWicketAdded == true
                            ? SizedBox(
                                height: 40,
                                width: 120,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (isMatchStarted == true &&
                                        selectedSymbol != -1 &&
                                        wicketTime != '') {
                                      Map<String, String> singleRunTime = {
                                        "def_number": defenderFieldValue == ''
                                            ? "1"
                                            : defenderFieldValue,
                                        "atk_number": (selectedSymbol == 4 ||
                                                selectedSymbol == 5 ||
                                                selectedSymbol == 6 ||
                                                selectedSymbol == 8 ||
                                                selectedSymbol == 11 ||
                                                selectedSymbol == 12)
                                            ? '-'
                                            : attackerFieldValue == ''
                                                ? "1"
                                                : attackerFieldValue,
                                        "run_time": wicketTime,
                                        "symbol": deriveSymbol(selectedSymbol),
                                      };
                                      allRunTimes.add(singleRunTime);
                                      // if (defenderAndAttacker[0] == 'A') {
                                      //   teamAScore.add((allRunTimes.length - 1)
                                      //       .toString());
                                      // }
                                      // if (defenderAndAttacker[0] == 'B') {
                                      //   teamBScore.add((allRunTimes.length - 1)
                                      //       .toString());
                                      // }
                                      setState(() {
                                        selectedPlayerNumberIndex = 0;
                                        selectedSymbol = -1;
                                        wicketTime = '';
                                        isWicketAdded = false;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          duration: Duration(seconds: 1),
                                          content: Text(
                                            'Data Entered',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          backgroundColor: Colors.green,
                                          dismissDirection:
                                              DismissDirection.horizontal,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          duration: Duration(seconds: 1),
                                          content: Text(
                                            'Please select all the fields',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          backgroundColor: Colors.red,
                                          dismissDirection:
                                              DismissDirection.horizontal,
                                        ),
                                      );
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
              const SizedBox(
                height: 16,
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Container(
              //       color: Colors.white,
              //       padding: const EdgeInsets.symmetric(horizontal: 10),
              //       child: Table(
              //         defaultColumnWidth: const FixedColumnWidth(60),
              //         border: TableBorder.all(color: Colors.black),
              //         defaultVerticalAlignment:
              //             TableCellVerticalAlignment.middle,
              //         textBaseline: TextBaseline.alphabetic,
              //         children: [
              //           const TableRow(
              //             children: [
              //               Center(child: Text('Team')),
              //               Center(child: Text('I')),
              //               Center(child: Text('II')),
              //               Center(child: Text('III')),
              //               Center(child: Text('IV')),
              //               Center(
              //                 child: Text(
              //                   'Total',
              //                   style: TextStyle(
              //                     fontWeight: FontWeight.bold,
              //                   ),
              //                 ),
              //               ),
              //             ],
              //           ),
              //           TableRow(
              //             children: [
              //               const Center(child: Text('A')),
              //               Center(
              //                 child: Text(
              //                   teamAScore.isNotEmpty
              //                       ? teamAScore.elementAt(0)?.toString() ?? ''
              //                       : '',
              //                 ),
              //               ),
              //               Center(
              //                 child: Text(
              //                   teamAScore.length > 1
              //                       ? teamAScore.elementAt(1)?.toString() ?? ''
              //                       : '',
              //                 ),
              //               ),
              //               Center(
              //                 child: Text(
              //                   teamAScore.length > 2
              //                       ? teamAScore.elementAt(2)?.toString() ?? ''
              //                       : '',
              //                 ),
              //               ),
              //               Center(
              //                 child: Text(
              //                   teamAScore.length > 3
              //                       ? teamAScore.elementAt(3)?.toString() ?? ''
              //                       : '',
              //                 ),
              //               ),
              //               const Center(
              //                 child: Text(
              //                   '10',
              //                   style: TextStyle(
              //                     fontWeight: FontWeight.bold,
              //                   ),
              //                 ),
              //               ),
              //             ],
              //           ),
              //           TableRow(
              //             children: [
              //               const Center(child: Text('B')),
              //               Center(
              //                 child: Text(
              //                   teamBScore.isNotEmpty
              //                       ? teamBScore.elementAt(1)?.toString() ?? ''
              //                       : '',
              //                 ),
              //               ),
              //               Center(
              //                 child: Text(
              //                   teamBScore.length == 1
              //                       ? teamBScore.elementAt(1)?.toString() ?? ''
              //                       : '',
              //                 ),
              //               ),
              //               Center(
              //                 child: Text(
              //                   teamBScore.length == 2
              //                       ? teamBScore.elementAt(1)?.toString() ?? ''
              //                       : '',
              //                 ),
              //               ),
              //               Center(
              //                 child: Text(
              //                   teamBScore.length == 3
              //                       ? teamBScore.elementAt(1)?.toString() ?? ''
              //                       : '',
              //                 ),
              //               ),
              //               const Center(
              //                 child: Text(
              //                   '10',
              //                   style: TextStyle(
              //                     fontWeight: FontWeight.bold,
              //                   ),
              //                 ),
              //               ),
              //             ],
              //           )
              //         ],
              //       ),
              //     ),
              //   ],
              // )
            ],
          ),
        ),
      ),
    );
  }
}
