import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kho_kho_scoresheet/constants/color_constants.dart';
import 'package:kho_kho_scoresheet/helpers/input_formatters.dart';
import 'package:kho_kho_scoresheet/helpers/time_diff.dart';
import 'package:kho_kho_scoresheet/provider/match_details_provider.dart';
import 'package:kho_kho_scoresheet/screens/about_screen.dart';
import 'package:kho_kho_scoresheet/screens/score_sheet.dart';
import 'package:kho_kho_scoresheet/supabase/db_queries.dart';
import 'package:provider/provider.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

TextEditingController teamANameController = TextEditingController();
TextEditingController teamBNameController = TextEditingController();
bool teamANameError = false;
bool teamBNameError = false;

class _StartScreenState extends State<StartScreen> {
  Set<String> ageGroupSelection = {"U-14"}; // Default selection
  Set<String> tossWinnerSelection = {"A"}; // Default selection
  Set<String> sideChoiceSelection = {"DEF"}; // Default selection

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
        elevation: 0,
        forceMaterialTransparency: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 10,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AboutScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.info_outline),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Enter Match Details',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  autofillHints: ['Pune', 'Mumbai'],
                  controller: teamANameController,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    label: const Text('Team A Name'),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    errorText: teamANameError ? 'Enter Team A Name' : null,
                  ),
                  maxLength: 99,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  onChanged: (value) {
                    Provider.of<MatchDetailsProvider>(context, listen: false)
                        .updateTeamAName(value.trim());
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  autofillHints: ['Pune', 'Mumbai'],
                  controller: teamBNameController,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    customInputFormatters(),
                  ],
                  decoration: InputDecoration(
                    label: const Text('Team B Name'),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    errorText: teamBNameError ? 'Enter Team B Name' : null,
                  ),
                  maxLength: 99,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  onChanged: (value) {
                    Provider.of<MatchDetailsProvider>(context, listen: false)
                        .updateTeamBName(value.trim());
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
                    SegmentedButton(
                      segments: [
                        ButtonSegment(
                          value: "U-14",
                          label: Text("U-14"),
                        ),
                        ButtonSegment(
                          value: "U-18/Open",
                          label: Text("U-18/Open"),
                        )
                      ],
                      selected: ageGroupSelection,
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          ageGroupSelection = newSelection.cast<String>();
                        });
                        Provider.of<MatchDetailsProvider>(context,
                                listen: false)
                            .ageGroup = ageGroupSelection.join(', ');
                      },
                      showSelectedIcon: false,
                      style: ButtonStyle(
                        surfaceTintColor: WidgetStatePropertyAll(Colors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
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
                    SegmentedButton(
                      segments: [
                        ButtonSegment(
                          value: "A",
                          label: Text("A"),
                        ),
                        ButtonSegment(
                          value: "B",
                          label: Text("B"),
                        )
                      ],
                      selected: tossWinnerSelection,
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          tossWinnerSelection = newSelection.cast<String>();
                        });
                        Provider.of<MatchDetailsProvider>(context,
                                listen: false)
                            .tossWinner = tossWinnerSelection.join(', ');
                      },
                      showSelectedIcon: false,
                      style: ButtonStyle(
                        surfaceTintColor: WidgetStatePropertyAll(Colors.black),
                      ),
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
                    SegmentedButton(
                      segments: [
                        ButtonSegment(
                          value: "DEF",
                          label: Text("DEF"),
                        ),
                        ButtonSegment(
                          value: "ATK",
                          label: Text("ATK"),
                        )
                      ],
                      selected: sideChoiceSelection,
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          sideChoiceSelection = newSelection.cast<String>();
                        });
                        Provider.of<MatchDetailsProvider>(context,
                                listen: false)
                            .sideChoice = sideChoiceSelection.join(', ');
                      },
                      showSelectedIcon: false,
                      style: ButtonStyle(
                        surfaceTintColor: WidgetStatePropertyAll(Colors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              if (teamANameController.text.isNotEmpty &&
                                  teamBNameController.text.isNotEmpty) {
                                setState(() {
                                  teamANameError = false;
                                  teamBNameError = false;
                                });
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                          "U-14"
                                                      ? 'Under 14'
                                                      : 'Under 18 / Open',
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  'Toss Winner:',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    Provider.of<MatchDetailsProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .tossWinner ==
                                                            "A"
                                                        ? 'Team A (${Provider.of<MatchDetailsProvider>(context, listen: false).teamAName})'
                                                        : 'Team B (${Provider.of<MatchDetailsProvider>(context, listen: false).teamBName})',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    softWrap: true,
                                                    textWidthBasis:
                                                        TextWidthBasis.parent,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  'Side Chosen:',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Text(
                                                  Provider.of<MatchDetailsProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .sideChoice ==
                                                          "DEF"
                                                      ? 'Defense'
                                                      : 'Attack',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
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
                                            overlayColor:
                                                WidgetStatePropertyAll(
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
                                          onPressed: () async {
                                            CircularProgressIndicator();
                                            final dbQuery = SupabaseDBQuery();
                                            final int matchId =
                                                await dbQuery.insertIntoMatches(
                                                    Provider.of<MatchDetailsProvider>(
                                                            context,
                                                            listen: false)
                                                        .ageGroup,
                                                    Provider.of<MatchDetailsProvider>(
                                                            context,
                                                            listen: false)
                                                        .teamAName,
                                                    Provider.of<MatchDetailsProvider>(
                                                            context,
                                                            listen: false)
                                                        .teamBName);
                                            await dbQuery.insertIntoTossDetails(
                                                matchId,
                                                Provider.of<MatchDetailsProvider>(
                                                        context,
                                                        listen: false)
                                                    .teamAName,
                                                Provider.of<MatchDetailsProvider>(
                                                        context,
                                                        listen: false)
                                                    .sideChoice);
                                            if (context.mounted) {
                                              Navigator.of(context).pop();
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const ScoreSheet(),
                                                ),
                                              );
                                            }
                                          },
                                          style: const ButtonStyle(
                                            overlayColor:
                                                WidgetStatePropertyAll(
                                                    ColorConstants
                                                        .primaryOverlayColor),
                                            backgroundColor:
                                                WidgetStatePropertyAll(
                                              Colors.blue,
                                            ),
                                          ),
                                          child: const Text(
                                            "Confirm",
                                            style: TextStyle(
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 1),
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
                              } else {
                                if (teamANameController.text.isEmpty) {
                                  setState(() {
                                    teamANameError = true;
                                  });
                                }
                                if (teamBNameController.text.isEmpty) {
                                  setState(() {
                                    teamBNameError = true;
                                  });
                                }
                              }
                            },
                            child: const Text('Create Match'),
                          ),
                        ),
                      ),
                    ],
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
