import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nerdi/InterestData.dart';
import 'package:nerdi/UserCard.dart';
import 'package:nerdi/UserIcon.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:nerdi/UserData.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

Future<UserData> getUserData(Session session) async {
  final temp = await Supabase.instance.client
      .from("UserData")
      .select()
      .eq("UserUID", session.user.id);
  return UserData(
      UUID: temp.first["UserUID"],
      Username: temp.first["Username"],
      Birthday: DateTime.parse(temp.first["Birthday"]),
      Gender: temp.first["Gender"],
      Description: temp.first["Description"],
      ProfilePictureURL: Supabase.instance.client.storage
          .from("ProfilePictures")
          .getPublicUrl(temp.first["ProfilePictureName"]));
}

class LoginButton extends StatefulWidget {
  const LoginButton({super.key, required this.session});

  final Session? session;

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  final _EmailController = TextEditingController();
  final _PasswordController = TextEditingController();
  var loginFailed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.session == null) {
      return CupertinoButton(
          child: Text("Login"),
          onPressed: () => AlertDialog(
                title: Text("Login"),
                content: Column(
                  children: [
                    loginFailed
                        ? Text("Login failed, try again, or don't, idm")
                        : Padding(
                            padding: EdgeInsets.zero,
                          ),
                    TextField(
                      controller: _EmailController,
                      decoration: InputDecoration(
                          labelText: "Email",
                          errorText:
                              loginFailed ? "Invalid Email, maybe, idk" : null),
                    ),
                    TextField(
                      controller: _PasswordController,
                      decoration: InputDecoration(
                          labelText: "Password",
                          errorText: loginFailed
                              ? "Invalid Password, maybe, idk"
                              : null),
                    )
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        setState(() {
                          Navigator.pop(context, "Cancel");
                        });
                      },
                      child: Text("Cancel")),
                  TextButton(
                      onPressed: () {
                        setState(() => Supabase.instance.client.auth
                            .signInWithPassword(
                                password: _PasswordController.text,
                                email: _EmailController.text));
                      },
                      child: Text("Login"))
                ],
              ));
    } else {
      return FutureBuilder(
          future: getUserData(widget.session!),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text("Login");
            }
            final data = snapshot.data!;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: UserIcon(
                    ImageURL: data.ProfilePictureURL,
                  ),
                ),
                Text(data.Username),
              ],
            );
          });
    }
  }
}
