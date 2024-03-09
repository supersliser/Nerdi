import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nerdi/UserData.dart';

class UserDescPage extends StatelessWidget {
  UserDescPage({super.key, required this.User});
  final UserData User;

  @override
  Widget build(BuildContext context) {
    final Size appSize = MediaQuery.of(context).size;
    return GridView.count(
      crossAxisCount: (appSize.width / 600).floor(),
      children: [

      ]
    );
  }
}