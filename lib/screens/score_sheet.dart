import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  const ScoreSheet({super.key});

  @override
  State<ScoreSheet> createState() => _ScoreSheetState();
}

num defNumber = 1;
num atkNumber = 1;
String defenderFieldValue = "";
String attackerFieldValue = "";
String wicketTime = '';
int selectedSymbol = -1;
int turnCount = 0;
bool isTurnTimEnded = false;
bool isWicketAdded = false;
bool isMatchStarted = false;

Map<String, dynamic> singleTurnData = {};

List<Map<String, dynamic>> allRunTimes = [];
List<Map<String, dynamic>> matchData = [];

List teamATurn1Score = [];
List teamATurn2Score = [];
List teamATurn3Score = [];
List teamATurn4Score = [];

List teamBTurn1Score = [];
List teamBTurn2Score = [];
List teamBTurn3Score = [];
List teamBTurn4Score = [];

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
    showSelectAttackerDefenderDialog();
    super.initState();
  }

  void showSelectAttackerDefenderDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      turnCount == 2
          ? showDialog(
              context: context,
              builder: (BuildContext context) {
                return PopScope(
                  canPop: false,
                  child: AlertDialog.adaptive(
                    title: const Text('Choose Attacker'),
                    content: const Text('Choose attacker for next turn'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            attackerFieldValue = 'A';
                            defenderFieldValue = 'B';
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text('Team A'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            attackerFieldValue = 'B';
                            defenderFieldValue = 'A';
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
                    label: Text('Start Turn ${turnCount + 1}'),
                    icon: const Icon(
                      Icons.sports_score_outlined,
                    ),
                  ),
                ),
              )
            : SingleChildScrollView(
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
                      indent: 20,
                      endIndent: 20,
                    ),
                    isMatchStarted == true
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          wicketTime =
                                              '$minutes:${seconds < 10 ? '0' : ''}$seconds';
                                          isWicketAdded = true;
                                        });
                                      },
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: turnCount > 1
                                ? Text(
                                    'DEF ($defenderFieldValue) Number',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                : Text(
                                    'DEF (${turnCount.isEven ? defenderAndAttacker[0] : defenderAndAttacker[1]}) Number',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 6,
                            child: SizedBox(
                              height: 40,
                              width: 400,
                              child: WheelChooser(
                                onValueChanged: (s) {
                                  setState(() {
                                    defNumber = s;
                                  });
                                },
                                datas: List.generate(15, (index) => index + 1),
                                horizontal: true,
                                isInfinite: false,
                                magnification: 1,
                                selectTextStyle: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                unSelectTextStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromRGBO(180, 180, 180, 1),
                                ),
                                startPosition: 1,
                                physics: const ClampingScrollPhysics(),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: turnCount > 1
                                  ? Text(
                                      'ATK ($attackerFieldValue) Number',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  : Text(
                                      'ATK (${turnCount.isEven ? defenderAndAttacker[1] : defenderAndAttacker[0]}) Number',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              flex: 6,
                              child: SizedBox(
                                height: 40,
                                width: 400,
                                child: WheelChooser(
                                  onValueChanged: (s) {
                                    setState(() {
                                      atkNumber = s;
                                    });
                                  },
                                  datas:
                                      List.generate(15, (index) => index + 1),
                                  horizontal: true,
                                  isInfinite: false,
                                  magnification: 1,
                                  selectTextStyle: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  unSelectTextStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromRGBO(180, 180, 180, 1),
                                  ),
                                  startPosition: 1,
                                  physics: const ClampingScrollPhysics(),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    else
                      const SizedBox(height: 40),
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
                                  fontSize: 18,
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
                                      const MaterialStatePropertyAll(
                                          Colors.black),
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
                                  overlayColor: const MaterialStatePropertyAll(
                                      Colors.blue),
                                  backgroundColor: index == selectedSymbol
                                      ? const MaterialStatePropertyAll(
                                          Colors.blue)
                                      : const MaterialStatePropertyAll(
                                          Colors.white),
                                  foregroundColor: index == selectedSymbol
                                      ? const MaterialStatePropertyAll(
                                          Colors.white)
                                      : const MaterialStatePropertyAll(
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
                                                    MaterialStatePropertyAll(
                                                        ColorConstants
                                                            .primaryOverlayColor),
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
                                                Navigator.of(context).pop();
                                                setState(() {
                                                  singleTurnData[turnCount
                                                          .toString()] =
                                                      allRunTimes;
                                                  matchData.add(singleTurnData);
                                                  turnCount++;
                                                  allRunTimes = [];
                                                  isMatchStarted = false;
                                                  String temp =
                                                      attackerFieldValue;
                                                  attackerFieldValue =
                                                      defenderFieldValue;
                                                  defenderFieldValue = temp;
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
                                            Map<String, String> singleRunTime =
                                                {
                                              "def_number":
                                                  defNumber.toString(),
                                              "atk_number": (selectedSymbol ==
                                                          4 ||
                                                      selectedSymbol == 5 ||
                                                      selectedSymbol == 6 ||
                                                      selectedSymbol == 8 ||
                                                      selectedSymbol == 11 ||
                                                      selectedSymbol == 12)
                                                  ? '-'
                                                  : atkNumber.toString(),
                                              "run_time": wicketTime,
                                              "symbol":
                                                  deriveSymbol(selectedSymbol),
                                            };
                                            allRunTimes.add(singleRunTime);
                                            String attacker = turnCount.isEven
                                                ? defenderAndAttacker[1]
                                                : defenderAndAttacker[0];
                                            writeScoreOnUI(attacker);
                                            setState(() {
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
                        Table(
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
                      ],
                    )
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
