import 'package:flutter/material.dart';
import 'package:kho_kho_scoresheet/helpers/url_handler.dart';
import 'package:remixicon/remixicon.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              "Credits",
              style: TextStyle(
                color: Color.fromARGB(255, 17, 27, 47),
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Remix.lightbulb_line),
            titleAlignment: ListTileTitleAlignment.center,
            title: Text(
              "Varun Pardeshi",
              style: TextStyle(
                color: Color.fromRGBO(17, 27, 47, 1),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text("Ideation"),
            trailing: Icon(
              Remix.linkedin_fill,
              color: Colors.blue,
            ),
            iconColor: Colors.blue,
            splashColor: Colors.blue[100],
            onTap: () => openLinkedInProfileVarun(),
          ),
          ListTile(
            leading: Icon(Remix.code_s_slash_line),
            titleAlignment: ListTileTitleAlignment.center,
            title: Text(
              "Parth Pujari",
              style: TextStyle(
                color: Color.fromRGBO(17, 27, 47, 1),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text("Development"),
            trailing: Icon(
              Remix.linkedin_fill,
              color: Colors.blue,
            ),
            iconColor: Colors.blue,
            splashColor: Colors.blue[100],
            onTap: () => openLinkedInProfileParth(),
          )
        ],
      ),
    );
  }
}
