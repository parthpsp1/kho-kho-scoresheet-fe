// import 'package:flutter/material.dart';

// class ResultScreen extends StatefulWidget {
//   const ResultScreen(
//       {super.key,
//       required this.turnData,
//       required this.defenderAndAttacker,
//       required this.turnCount});

//   final List turnData;
//   final List defenderAndAttacker;
//   final int turnCount;
//   @override
//   State<ResultScreen> createState() => _ResultScreenState();
// }

// class _ResultScreenState extends State<ResultScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Result'),
//       ),
//       body: Center(
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   color: Colors.white,
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: Table(
//                     defaultColumnWidth: const FixedColumnWidth(60),
//                     border: TableBorder.all(color: Colors.black),
//                     defaultVerticalAlignment: TableCellVerticalAlignment.middle,
//                     textBaseline: TextBaseline.alphabetic,
//                     children: [
//                       const TableRow(
//                         children: [
//                           Center(child: Text('Team')),
//                           Center(child: Text('I')),
//                           Center(child: Text('II')),
//                           Center(child: Text('III')),
//                           Center(child: Text('IV')),
//                           Center(
//                             child: Text(
//                               'Total',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       TableRow(
//                         children: [
//                           const Center(child: Text('A')),
//                           Center(
//                             child: Text(
//                               (widget.defenderAndAttacker[1] == 'A' &&
//                                       widget.turnCount == 0)
//                                   ? 'YourTextWhenConditionIsTrue'
//                                   : 'YourTextWhenConditionIsFalse',
//                             ),
//                           ),
//                           const Center(
//                             child: Text(
//                               '10',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       TableRow(
//                         children: [
//                           const Center(child: Text('B')),
//                           Center(
//                             child: Text(
//                               deriveMatchScoreForTeamB(allTurnScore),
//                             ),
//                           ),
//                           const Center(
//                               child: Text(
//                             '10',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                             ),
//                           )),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
