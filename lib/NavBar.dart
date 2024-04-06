import 'package:flutter/material.dart';
import 'package:nerdi/InterestDiscoveryPage.dart';
import 'package:nerdi/Login.dart';
import 'package:nerdi/NewUser.dart';
import 'package:nerdi/UserListPage.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key, this.CurrentIndex = 0});

  final int CurrentIndex;

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
            icon: Icon(Icons.add),
            label: Text("Create New User",
                style: TextStyle(color: Color(0xFFCCCCCC)))),
        NavigationRailDestination(
            icon: Icon(Icons.account_tree),
            label: Text("Interest Discovery",
                style: TextStyle(color: Color(0xFFCCCCCC)))),
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const NewUser()));
            });
            break;
          case 2:
            setState(() {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InterestDiscoveryPage()));
            });
        }
      },
    );
  }
}
