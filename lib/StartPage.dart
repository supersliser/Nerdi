import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nerdi/Login.dart';
import 'package:nerdi/NewUser.dart';

class StartPage extends StatelessWidget {
  StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(50.0),
              child: Text(
                "Hi there\nWelcome to Nerdi",
                style: TextStyle(color: Colors.white, fontSize: 40),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: TextButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.purple),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => NewUser()));
                  },
                  child: Text(
                    "I'm new here",
                    style: TextStyle(color: Colors.white, fontSize: 40),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.black),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  child: Text(
                    "I'm not new here",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  )),
            )
          ],
        )),
    );
  }
}
