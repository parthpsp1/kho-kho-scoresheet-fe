import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kho_kho_scoresheet/constants/color_constants.dart';
import 'package:kho_kho_scoresheet/constants/symbols.dart';
import 'package:kho_kho_scoresheet/helpers/excel_module.dart';
import 'package:kho_kho_scoresheet/helpers/permission_handler.dart';
import 'package:kho_kho_scoresheet/provider/match_details_provider.dart';
import 'package:kho_kho_scoresheet/screens/start_screen.dart';
import 'package:kho_kho_scoresheet/supabase/db_queries.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScoreSheet extends StatefulWidget {
  const ScoreSheet({super.key, required this.matchId});
  final int matchId;

  @override
  State<ScoreSheet> createState() => _ScoreSheetState();
}

int? defenderNumber;
int? attackerNumber;
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

List<int> teamATurn1Score = [];
List<int> teamATurn2Score = [];
List<int> teamATurn3Score = [];
List<int> teamATurn4Score = [];

List<int> teamBTurn1Score = [];
List<int> teamBTurn2Score = [];
List<int> teamBTurn3Score = [];
List<int> teamBTurn4Score = [];

class _ScoreSheetState extends State<ScoreSheet> {
  int _secondsPassed = 0;
  late Timer _timer;

  void _updateTimer(Timer timer, String ageGroup) {
    if (ageGroup == "U-14") {
      if (_secondsPassed < 7 * 60) {
        setState(() {
          _secondsPassed++;
        });
      } else {
        setState(() {
          isTurnTimEnded = true;
        });
      }
    } else {
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
    showSelectAttackerDefenderDialog();
    super.initState();
  }

  void showSelectAttackerDefenderDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      turnCount == 2
          ? showDialog(
              context: context,
              builder: (BuildContext context) {
                final matchDetails =
                    Provider.of<MatchDetailsProvider>(context, listen: false);
                return PopScope(
                  canPop: false,
                  child: AlertDialog.adaptive(
                    title: const Text('Choose Attacker'),
                    content: const Text('Choose attacker for next turn'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            matchDetails.defAttackerMap = {
                              "DEF": "B",
                              "ATK": "A"
                            };
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text('Team A'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            matchDetails.defAttackerMap = {
                              "DEF": "A",
                              "ATK": "B"
                            };
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text('Team B'),
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
                  ),
                );
              },
            )
          : Container();
    });
  }

  Future<void> runRequestPermissions() async {
    await requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final matchDetails =
        Provider.of<MatchDetailsProvider>(context, listen: false);
    int minutes = _secondsPassed ~/ 60;
    int seconds = _secondsPassed % 60;

    List<String> defenderAndAttacker = [""];
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: isMatchStarted == true && isWicketAdded == false
          ? FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  wicketTime = '$minutes:${seconds < 10 ? '0' : ''}$seconds';
                  isWicketAdded = true;
                });
              },
              label: Text(
                'Add Wicket',
                style: TextStyle(color: Colors.white),
              ),
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              elevation: 4,
              backgroundColor: Colors.green,
            )
          : isMatchStarted == true && isWicketAdded == true
              ? FloatingActionButton.extended(
                  onPressed: () {
                    setState(() {
                      isWicketAdded = false;
                      wicketTime = '';
                      defenderNumber = null;
                      attackerNumber = null;
                    });
                  },
                  label: Text(
                    'Cancel Wicket',
                    style: TextStyle(color: Colors.white),
                  ),
                  icon: Icon(
                    Icons.cancel_outlined,
                    color: Colors.white,
                  ),
                  elevation: 4,
                  backgroundColor: Colors.red,
                )
              : const SizedBox(),
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
            child: TextButton.icon(
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
                            overlayColor: WidgetStatePropertyAll(
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
                            createExcel(
                              context,
                              matchData,
                              defenderAndAttacker,
                              teamATurn1Score,
                              teamATurn2Score,
                              teamATurn3Score,
                              teamATurn4Score,
                              teamBTurn1Score,
                              teamBTurn2Score,
                              teamBTurn3Score,
                              teamBTurn4Score,
                            );
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const StartScreen(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                            setState(() {
                              matchData = [];
                              turnCount = 0;
                              isMatchStarted = false;
                              clearAllScores();
                            });
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog.adaptive(
                                  title: const Text('Exported Successfully'),
                                  content: const Text(
                                    'Excel exported to Downloads folder',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Okay'),
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
                            overlayColor: WidgetStatePropertyAll(
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
                backgroundColor: WidgetStatePropertyAll(Colors.red),
                foregroundColor: WidgetStatePropertyAll(Colors.white),
              ),
              label: const Text('End Match'),
              icon: const Icon(
                Icons.dangerous_outlined,
              ),
            ),
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
        child: isMatchStarted == false
            ? Center(
                child: SizedBox(
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () async {
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
                    label: Text('Start Turn No. ${turnCount + 1}'),
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Turn ${turnCount + 1} will end in ${Provider.of<MatchDetailsProvider>(context, listen: false).ageGroup == "U-14" ? "7:00" : "9:00"} minutes',
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
                      indent: 20,
                      endIndent: 20,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'DEF (${matchDetails.defAttackerMap['DEF']}) Number',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: DropdownButton<int>(
                              items: List.generate(15, (index) => index + 1)
                                  .map((number) => DropdownMenuItem(
                                        value: number,
                                        child: Text(number.toString()),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  defenderNumber = value;
                                });
                              },
                              hint: Text(
                                "Player No.",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              value: defenderNumber,
                              isExpanded: true,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(
                            matchDetails.defAttackerMap['DEF'] == "A"
                                ? Provider.of<MatchDetailsProvider>(context,
                                        listen: false)
                                    .teamAName
                                : Provider.of<MatchDetailsProvider>(context,
                                        listen: false)
                                    .teamBName,
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (selectedSymbol != 4 &&
                        selectedSymbol != 5 &&
                        selectedSymbol != 6 &&
                        selectedSymbol != 8 &&
                        selectedSymbol != 11 &&
                        selectedSymbol != 12)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ATK (${matchDetails.defAttackerMap['ATK']}) Number',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: DropdownButton<int>(
                                  items: List.generate(15, (index) => index + 1)
                                      .map((number) => DropdownMenuItem(
                                            value: number,
                                            child: Text(number.toString()),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      attackerNumber = value;
                                    });
                                  },
                                  hint: Text(
                                    "Player No.",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  value: attackerNumber,
                                  isExpanded: true,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                          ],
                        ),
                      )
                    else
                      const SizedBox(height: 40),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(
                            matchDetails.defAttackerMap['ATK'] == "A"
                                ? Provider.of<MatchDetailsProvider>(context,
                                        listen: false)
                                    .teamAName
                                : Provider.of<MatchDetailsProvider>(context,
                                        listen: false)
                                    .teamBName,
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
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
                          Text(
                            wicketTime,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.start,
                          //   children: [
                          //     // const SizedBox(
                          //     //   width: 10,
                          //     // ),
                          //     // IconButton(
                          //     //   onPressed: () {
                          //     //     setState(() {
                          //     //       wicketTime = '';
                          //     //     });
                          //     //   },
                          //     //   icon: const Icon(
                          //     //     RemixIcon.close_outline,
                          //     //     color: Colors.red,
                          //     //   ),
                          //     //   style: const ButtonStyle(
                          //     //     backgroundColor: WidgetStatePropertyAll(
                          //     //       Colors.white,
                          //     //     ),
                          //     //   ),
                          //     // )
                          //   ],
                          // ),
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
                        height: 100,
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
                                      const WidgetStatePropertyAll(
                                          Colors.black),
                                  shape: const WidgetStatePropertyAll(
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
                                  padding: const WidgetStatePropertyAll(
                                    EdgeInsets.all(0),
                                  ),
                                  overlayColor:
                                      const WidgetStatePropertyAll(Colors.blue),
                                  backgroundColor: index == selectedSymbol
                                      ? const WidgetStatePropertyAll(
                                          Colors.blue)
                                      : const WidgetStatePropertyAll(
                                          Colors.white),
                                  foregroundColor: index == selectedSymbol
                                      ? const WidgetStatePropertyAll(
                                          Colors.white)
                                      : const WidgetStatePropertyAll(
                                          Colors.black),
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
                    const SizedBox(
                      height: 10,
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
                                                    WidgetStatePropertyAll(
                                                  ColorConstants
                                                      .primaryOverlayColor,
                                                ),
                                              ),
                                              child: const Text(
                                                "No",
                                                style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      17, 27, 47, 1),
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                matchDetails.defAttackerMap = {
                                                  "DEF": matchDetails
                                                      .defAttackerMap["ATK"]!,
                                                  "ATK": matchDetails
                                                      .defAttackerMap["DEF"]!
                                                };
                                                Navigator.of(context).pop();
                                                setState(() {
                                                  singleTurnData[turnCount
                                                          .toString()] =
                                                      allRunTimes;
                                                  matchData.add(singleTurnData);
                                                  turnCount++;
                                                  allRunTimes = [];
                                                  isMatchStarted = false;
                                                  defenderNumber = null;
                                                  attackerNumber = null;
                                                });
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ScoreSheet(
                                                      matchId: -1,
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: const ButtonStyle(
                                                overlayColor:
                                                    WidgetStatePropertyAll(
                                                        ColorConstants
                                                            .primaryOverlayColor),
                                              ),
                                              child: const Text(
                                                "Confirm",
                                                style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      17, 27, 47, 1),
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
                                            color:
                                                Color.fromRGBO(17, 47, 27, 1),
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
                                    backgroundColor: WidgetStatePropertyAll(
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
                                        onPressed: () async {
                                          if (isMatchStarted == true &&
                                              selectedSymbol != -1 &&
                                              wicketTime != '' &&
                                              defenderNumber != null &&
                                              attackerNumber != null) {
                                            // Map<String, String> singleRunTime =
                                            //     {
                                            //   "def_number": defenderNumber,
                                            //   "atk_number": (selectedSymbol ==
                                            //               4 ||
                                            //           selectedSymbol == 5 ||
                                            //           selectedSymbol == 6 ||
                                            //           selectedSymbol == 8 ||
                                            //           selectedSymbol == 11 ||
                                            //           selectedSymbol == 12)
                                            //       ? '-'
                                            //       : attackerNumber,
                                            //   "run_time": wicketTime,
                                            //   "symbol":
                                            //       deriveSymbol(selectedSymbol),
                                            // };
                                            // allRunTimes.add(singleRunTime);
                                            String attackerTeam = matchDetails
                                                .defAttackerMap["ATK"]!;
                                            writeScoreOnUI(attackerTeam);
                                            await SupabaseDBQuery()
                                                .insertIntoRoundDetails(
                                                    turnCount + 1,
                                                    widget.matchId,
                                                    toInt(defenderNumber)!,
                                                    toInt(attackerNumber)!,
                                                    wicketTime,
                                                    "0:00",
                                                    selectedSymbol.toString());
                                            setState(() {
                                              defenderNumber = null;
                                              attackerNumber = null;
                                              selectedSymbol = -1;
                                              wicketTime = '';
                                              isWicketAdded = false;
                                            });
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                behavior:
                                                    SnackBarBehavior.floating,
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
                                                behavior:
                                                    SnackBarBehavior.floating,
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
                            height: 60,
                            child: ElevatedButton.icon(
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
                              label: const Text('Start Turn'),
                              icon: const Icon(
                                Icons.sports_score_outlined,
                              ),
                            ),
                          ),
                    const SizedBox(
                      height: 16,
                    ),
                    const Text(
                      'Match Score Sheet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Table(
                            defaultColumnWidth: const FixedColumnWidth(60),
                            border: TableBorder.all(color: Colors.black),
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              const TableRow(
                                children: [
                                  Center(child: Text('Team')),
                                  Center(child: Text('I')),
                                  Center(child: Text('II')),
                                  Center(child: Text('III')),
                                  Center(child: Text('IV')),
                                  Center(
                                    child: Text(
                                      'Total',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  const Center(
                                    child: Text('A'),
                                  ),
                                  Center(
                                    child: Text(
                                      teamATurn1Score.isNotEmpty
                                          ? teamATurn1Score.length.toString()
                                          : '',
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      teamATurn2Score.isNotEmpty
                                          ? teamATurn2Score.length.toString()
                                          : '',
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      teamATurn3Score.isNotEmpty
                                          ? teamATurn3Score.length.toString()
                                          : '',
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      teamATurn4Score.isNotEmpty
                                          ? teamATurn4Score.length.toString()
                                          : '',
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      (teamATurn1Score.length +
                                              teamATurn2Score.length +
                                              teamATurn3Score.length +
                                              teamATurn4Score.length)
                                          .toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  const Center(
                                    child: Text('B'),
                                  ),
                                  Center(
                                    child: Text(
                                      teamBTurn1Score.isNotEmpty
                                          ? teamBTurn1Score.length.toString()
                                          : '',
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      teamBTurn2Score.isNotEmpty
                                          ? teamBTurn2Score.length.toString()
                                          : '',
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      teamBTurn3Score.isNotEmpty
                                          ? teamBTurn3Score.length.toString()
                                          : '',
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      teamBTurn4Score.isNotEmpty
                                          ? teamBTurn4Score.length.toString()
                                          : '',
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      (teamBTurn1Score.length +
                                              teamBTurn2Score.length +
                                              teamBTurn3Score.length +
                                              teamBTurn4Score.length)
                                          .toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void writeScoreOnUI(attacker) {
    if (selectedSymbol != 11 && selectedSymbol != 12) {
      if (turnCount == 0) {
        if (attacker == 'A') {
          teamATurn1Score.add(allRunTimes.length);
          return;
        }
        teamBTurn1Score.add(allRunTimes.length);
        return;
      }
      if (turnCount == 1) {
        if (attacker == 'A') {
          teamATurn1Score.add(allRunTimes.length);
          return;
        }
        teamBTurn1Score.add(allRunTimes.length);
        return;
      }
      if (turnCount == 2) {
        if (attacker == 'A') {
          teamATurn2Score.add(allRunTimes.length);
          return;
        }
        teamBTurn2Score.add(allRunTimes.length);
        return;
      }
      if (turnCount == 3) {
        if (attacker == 'A') {
          teamATurn2Score.add(allRunTimes.length);
          return;
        }
        teamBTurn2Score.add(allRunTimes.length);
        return;
      }
      if (turnCount == 4) {
        if (attacker == 'A') {
          teamATurn3Score.add(allRunTimes.length);
          return;
        }
        teamBTurn3Score.add(allRunTimes.length);
        return;
      }
      if (turnCount == 5) {
        if (attacker == 'A') {
          teamATurn3Score.add(allRunTimes.length);
          return;
        }
        teamBTurn3Score.add(allRunTimes.length);
        return;
      }
      if (turnCount == 6) {
        if (attacker == 'A') {
          teamATurn4Score.add(allRunTimes.length);
          return;
        }
        teamBTurn4Score.add(allRunTimes.length);
        return;
      }
      if (turnCount == 7) {
        if (attacker == 'A') {
          teamATurn4Score.add(allRunTimes.length);
          return;
        }
        teamBTurn4Score.add(allRunTimes.length);
        return;
      }
    }
  }

  void clearAllScores() {
    teamATurn1Score.clear();
    teamATurn2Score.clear();
    teamATurn3Score.clear();
    teamATurn4Score.clear();

    teamBTurn1Score.clear();
    teamBTurn2Score.clear();
    teamBTurn3Score.clear();
    teamBTurn4Score.clear();
  }
}
