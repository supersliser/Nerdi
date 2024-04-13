import 'package:flutter/material.dart';
import 'package:nerdi/InterestData.dart';
import 'package:nerdi/InterestDiscoveryPage.dart';
import 'package:nerdi/InterestPage.dart';
import 'package:nerdi/LikedHistory.dart';
import 'package:nerdi/Login.dart';
import 'package:nerdi/UserListPage.dart';
import 'package:uuid/uuid.dart';

import 'MessagePage.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key, required this.CurrentIndex});
  final int? CurrentIndex;

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  var loginFailed = false;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(

      backgroundColor: const Color(0xFF040404),
      trailing: const LoginButton(),
      extended: MediaQuery.of(context).size.width >= 700,
      selectedIndex: widget.CurrentIndex,
      destinations: const [
        NavigationRailDestination(
            icon: Icon(Icons.home),
            label: Text(
              "Home",
              style: TextStyle(color: Color(0xFFCCCCCC)),
            )),
        NavigationRailDestination(
            icon: Icon(Icons.account_tree),
            label: Text("Interest Discovery",
                style: TextStyle(color: Color(0xFFCCCCCC)))),
        NavigationRailDestination(
            icon: Icon(Icons.add),
            label: Text("Create new interest",
                style: TextStyle(color: Color(0xFFCCCCCC)))),
        NavigationRailDestination(
            icon: Icon(Icons.mail),
            label:
                Text("Messages", style: TextStyle(color: Color(0xFFCCCCCC)))),
        NavigationRailDestination(icon: Icon(Icons.thumb_up), label: Text("Liked History", style: TextStyle(color: Color(0xFFCCCCCC))))
      ],
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            setState(() {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserListPage()));
            });
            break;
          case 1:
            setState(() {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const InterestDiscoveryPage()));
            });
            break;
          case 2:
            setState(() {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InterestPage(
                            interest: Interest(
                                ID: const Uuid().v4(),
                                Name: "New Interest",
                                Description: "Interest Description",
                                PrimaryColour:
                                    const Color.fromARGB(255, 199, 143, 255)),
                            editMode: true,
                            newInterest: true,
                          )));
            });
            break;
          case 3:
            setState(() {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MessagePage()));
            });
            break;
          case 4:
            setState(() {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LikedHistoryPage()));
            });
        }
      },
    );
  }
}
