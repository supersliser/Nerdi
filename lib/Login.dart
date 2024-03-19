import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nerdi/UserIcon.dart';
import 'package:nerdi/UserData.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<UserData> getUserData(Session session) async {
  final temp = await Supabase.instance.client
      .from("UserInfo")
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
  const LoginButton({super.key});

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  final _EmailController = TextEditingController();
  final _PasswordController = TextEditingController();
  var loginFailed = false;

  @override
  Widget build(BuildContext context) {
    if (Supabase.instance.client.auth.currentSession == null) {
      return CupertinoButton(
          child: const Text("Login"),
          onPressed: () => showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                insetPadding: const EdgeInsets.all(10),
                title: const Text("Login"),
                content: Column(
                  children: [
                    loginFailed
                        ? const Text("Login failed, try again, or don't, idm")
                        : const Padding(
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
                      obscureText: true,
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
                      child: const Text("Cancel")),
                  TextButton(
                      onPressed: () {
                        setState(() async {
                          var temp = await Supabase.instance.client.auth
                              .signInWithPassword(
                              password: _PasswordController.text,
                              email: _EmailController.text);
                          if (temp.session == null) {
                            loginFailed = true;
                          } else {
                            Navigator.pop(context, "Submit");
                          }
                        });
                      },
                      child: const Text("Login"))
                ],
              );
            }
          ));
    } else {
      return FutureBuilder(
          future: getUserData(Supabase.instance.client.auth.currentSession!),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            final data = snapshot.data!;
            return Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: UserIcon(
                    ImageURL: data.ProfilePictureURL,
                  ),
                ),
                MediaQuery.of(context).size.width >= 700 ? Text(data.Username, style: const TextStyle(color: Color(0xFFCCCCCC)),):const Padding(padding: EdgeInsets.all(0),),
              ],
            );
          });
    }
  }
}
