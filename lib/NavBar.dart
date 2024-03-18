import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nerdi/Login.dart';
import 'package:nerdi/NewUser.dart';
import 'package:nerdi/UserData.dart';
import 'package:nerdi/UserIcon.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nerdi/UserCard.dart';

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
      trailing: LoginButton(session: Supabase.instance.client.auth.currentSession,),
      extended: MediaQuery.of(context).size.width >= 700,
      selectedIndex: widget.CurrentIndex,
      destinations: [
        NavigationRailDestination(icon: Icon(Icons.home), label: Text("Home")),
        NavigationRailDestination(icon: Icon(Icons.abc), label: Text("Blank for now"))
      ],
    );
  }
}
