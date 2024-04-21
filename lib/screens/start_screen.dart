import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:kho_kho_scoresheet/constants/color_constants.dart';
import 'package:kho_kho_scoresheet/helpers/input_formatters.dart';
import 'package:kho_kho_scoresheet/helpers/time_diff.dart';
import 'package:kho_kho_scoresheet/provider/match_details_provider.dart';
import 'package:kho_kho_scoresheet/screens/about_screen.dart';
import 'package:kho_kho_scoresheet/screens/score_sheet.dart';
import 'package:provider/provider.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

TextEditingController teamANameController = TextEditingController();
TextEditingController teamBNameController = TextEditingController();

class _StartScreenState extends State<StartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kho-Kho Scoresheet',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        titleSpacing: 20,
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 10,
            ),
            child: TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AboutScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.help_outline_outlined),
              label: const Text('About'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Enter Match Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: teamANameController,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    customInputFormatters(),
                  ],
                  decoration: const InputDecoration(
                    label: Text('Team A Name'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    counterText: '',
                  ),
                  maxLength: 50,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  onChanged: (value) {
                    Provider.of<MatchDetailsProvider>(context, listen: false)
                        .updateTeamAName(value);
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: teamBNameController,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    customInputFormatters(),
                  ],
                  decoration: const InputDecoration(
                    label: Text('Team B Name'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    counterText: '',
                  ),
                  maxLength: 50,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  onChanged: (value) {
                    Provider.of<MatchDetailsProvider>(context, listen: false)
                        .updateTeamBName(value);
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Date:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                      width: 40,
                    ),
                    Text(
                      getDate(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
                      'Age Group:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    FlutterToggleTab(
                      width: 60,
                      borderRadius: 12,
                      selectedBackgroundColors: const [Colors.blue],
                      selectedTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                      unSelectedTextStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w400),
                      labels: const ['U-14', 'U-18/Open'],
                      selectedIndex: Provider.of<MatchDetailsProvider>(context,
                              listen: false)
                          .ageGroup,
                      selectedLabelIndex: (index) {
                        setState(() {
                          Provider.of<MatchDetailsProvider>(context,
                                  listen: false)
                              .ageGroup = index;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Toss won by:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    FlutterToggleTab(
                      width: 40,
                      borderRadius: 12,
                      selectedBackgroundColors: const [Colors.blue],
                      selectedTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                      unSelectedTextStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w400),
                      labels: const ['A', 'B'],
                      selectedIndex: Provider.of<MatchDetailsProvider>(context,
                              listen: false)
                          .tossWinner,
                      selectedLabelIndex: (index) {
                        setState(() {
                          Provider.of<MatchDetailsProvider>(context,
                                  listen: false)
                              .tossWinner = index;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Chose to:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    FlutterToggleTab(
                      width: 50,
                      borderRadius: 12,
                      selectedBackgroundColors: const [Colors.blue],
                      selectedTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                      unSelectedTextStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w400),
                      labels: const ['DEF', 'ATK'],
                      selectedIndex: Provider.of<MatchDetailsProvider>(context,
                              listen: false)
                          .defAtkChoice,
                      selectedLabelIndex: (index) {
                        setState(() {
                          Provider.of<MatchDetailsProvider>(context,
                                  listen: false)
                              .defAtkChoice = index;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            showAdaptiveDialog(
                              context: context,
                              builder: (builder) {
                                return AlertDialog.adaptive(
                                  title: const Text("Create Match?"),
                                  content: IntrinsicHeight(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Please confirm match details",
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Age group:',
                                              style: TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                            Text(
                                              Provider.of<MatchDetailsProvider>(
                                                              context,
                                                              listen: false)
                                                          .ageGroup ==
                                                      0
                                                  ? 'Under 14'
                                                  : 'Under 18 / Open',
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Toss Winner:',
                                              style: TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                            Text(
                                              Provider.of<MatchDetailsProvider>(
                                                              context,
                                                              listen: false)
                                                          .tossWinner ==
                                                      0
                                                  ? 'Team A'
                                                  : 'Team B',
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Choice:',
                                              style: TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                            Text(
                                              Provider.of<MatchDetailsProvider>(
                                                              context,
                                                              listen: false)
                                                          .defAtkChoice ==
                                                      0
                                                  ? 'Defense'
                                                  : 'Attack',
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
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
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ScoreSheet(),
                                          ),
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
                          child: const Text('Create Match'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
