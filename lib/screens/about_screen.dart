import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kho_kho_scoresheet/helpers/url_handler.dart';
import 'package:remix_icon_icons/remix_icon_icons.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: const TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Thanks for using!',
                        style: TextStyle(
                          color: Color.fromARGB(255, 17, 27, 47),
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            GestureDetector(
              onTap: () async {
                openLinkedInProfileVarun();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Idea by ',
                          style: TextStyle(
                            color: Color.fromRGBO(17, 27, 47, 1),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: 'Varun Pardeshi',
                          style: TextStyle(
                            color: Colors.transparent,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(
                                color: Colors.blue,
                                offset: Offset(0, -2),
                              ),
                            ],
                            decoration: TextDecoration.underline,
                            decorationStyle: TextDecorationStyle.dashed,
                            decorationThickness: 1,
                            decorationColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  const Icon(
                    RemixIcon.linkedin_box,
                    color: Colors.blue,
                    size: 28,
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () async {
                openLinkedInProfileParth();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Developed by ',
                          style: TextStyle(
                            color: Color.fromRGBO(17, 27, 47, 1),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: 'Parth Pujari',
                          style: TextStyle(
                            color: Colors.transparent,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(
                                color: Colors.blue,
                                offset: Offset(0, -2),
                              ),
                            ],
                            decoration: TextDecoration.underline,
                            decorationStyle: TextDecorationStyle.dashed,
                            decorationThickness: 1,
                            decorationColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  const Icon(
                    RemixIcon.linkedin_box,
                    color: Colors.blue,
                    size: 28,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
