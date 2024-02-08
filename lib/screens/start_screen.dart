import 'package:flutter/material.dart';
import 'package:kho_kho_scoresheet/screens/score_sheet.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Kho-Kho Scoresheet'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Match Title',
              style: TextStyle(fontSize: 18),
            ),
            // TextFormField(
            //   key: _fullNameFieldKey,
            //   // inputFormatters: customNameInputFormatter,
            //   keyboardType: TextInputType.text,
            //   onChanged: (value) {
            //     onFullNameChange(value);
            //   },
            //   controller: Provider.of<SignUpUserDataProvider>(context)
            //       .fullNameController,
            //   textCapitalization: TextCapitalization.words,
            //   decoration: InputDecoration(
            //     suffixIcon: Padding(
            //       padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
            //       child: IconButton(
            //         onPressed: () {
            //           Provider.of<SignUpUserDataProvider>(context,
            //                   listen: false)
            //               .fullNameController
            //               .clear();
            //           setState(() {
            //             _fullNameFieldKey.currentState?.reassemble();
            //           });
            //         },
            //         icon: Icon(RemixIcon.close_outline),
            //       ),
            //     ),
            //     suffixIconColor: const Color.fromRGBO(171, 171, 171, 1),
            //     contentPadding: const EdgeInsets.only(
            //       left: 20,
            //       top: 16,
            //       bottom: 16,
            //     ),
            //     errorStyle: TextStyle(
            //       color: ColorConstants.error,
            //     ),
            //     counterText: '',
            //     label: const Text(
            //       'Enter your Full name',
            //       style: TextStyle(
            //         color: Color.fromRGBO(171, 171, 171, 1),
            //         fontWeight: FontWeight.w400,
            //       ),
            //     ),
            //     labelStyle: const TextStyle(fontSize: 14),
            //     floatingLabelStyle: const TextStyle(
            //       fontSize: 16,
            //       fontWeight: FontWeight.w400,
            //     ),
            //     enabledBorder: const OutlineInputBorder(
            //       borderRadius: BorderRadius.all(
            //         Radius.circular(40),
            //       ),
            //       borderSide: BorderSide(
            //         width: 2,
            //         color: Color.fromRGBO(220, 220, 220, 1),
            //       ),
            //     ),
            //     focusedBorder: const OutlineInputBorder(
            //       borderRadius: BorderRadius.all(
            //         Radius.circular(40),
            //       ),
            //       borderSide: BorderSide(
            //         width: 2,
            //         color: Color.fromRGBO(220, 220, 220, 1),
            //       ),
            //     ),
            //     errorBorder: OutlineInputBorder(
            //       borderRadius: const BorderRadius.all(
            //         Radius.circular(40),
            //       ),
            //       borderSide: BorderSide(
            //         width: 2,
            //         color: ColorConstants.error,
            //       ),
            //     ),
            //     focusedErrorBorder: OutlineInputBorder(
            //       borderRadius: const BorderRadius.all(
            //         Radius.circular(40),
            //       ),
            //       borderSide: BorderSide(
            //         width: 2,
            //         color: ColorConstants.error,
            //       ),
            //     ),
            //   ),
            //   autofocus: true,
            //   maxLength: 50,
            //   autocorrect: false,
            //   enableSuggestions: false,
            //   validator: (value) {
            //     if (value == null || value.isEmpty) {
            //       return 'Full name should be minimum 2 characters';
            //     }
            //     if (!value.contains(RegExp(r'^[A-Za-z]+$'))) {
            //       return 'Full name should be minimum 2 characters';
            //     }
            //     if (value.length > 50) {
            //       return 'Full name should be minimum 2 characters';
            //     }
            //     if (value.length < 2) {
            //       return 'Full name should be minimum 2 characters';
            //     }
            //     return null;
            //   },
            // ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ScoreSheet(),
                    ),
                  );
                },
                child: const Text('Create Match'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
