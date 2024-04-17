import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nerdi/AccountPage.dart';
import 'package:nerdi/UserIcon.dart';
import 'package:nerdi/UserData.dart';
import 'package:nerdi/UserListPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<UserData> getUserData(Session session) async {
  final temp = await Supabase.instance.client.from("UserInfo").select().eq("UserUID", session.user.id);
  return UserData(
      UUID: temp.first["UserUID"],
      Username: temp.first["Username"],
      Birthday: DateTime.parse(temp.first["Birthday"]),
      Gender: temp.first["Gender"],
      Description: temp.first["Description"],
      ProfilePictureURL: Supabase.instance.client.storage.from("ProfilePictures").getPublicUrl(temp.first["ProfilePictureName"]),
      ProfilePictureName: temp.first["ProfilePictureName"]);
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _EmailController = TextEditingController();

  final _PasswordController = TextEditingController();

  var loginFailed = false;

  Future<void> attemptLogin() async {
    if (_EmailController.text.isEmpty || _PasswordController.text.isEmpty) {
      return;
    }
    AuthResponse? temp;
    try {
      temp = await Supabase.instance.client.auth.signInWithPassword(password: _PasswordController.text, email: _EmailController.text);
    } catch (ex) {
      temp = null;
    }
    if (temp == null) {
      setState(() {
        loginFailed = true;
      });
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const UserListPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          height: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              loginFailed
                  ? const Text(
                      "Login failed, try again, or don't, idm",
                      style: TextStyle(color: Colors.red),
                    )
                  : const Padding(
                      padding: EdgeInsets.zero,
                    ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onSubmitted: (data) {
                    attemptLogin();
                  },
                  controller: _EmailController,
                  style: const TextStyle(color: Color(0xFFCCCCCC)),
                  decoration: InputDecoration(labelText: "Email", errorText: loginFailed ? "Invalid Email, maybe, idk" : null),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onSubmitted: (data) {
                    attemptLogin();
                  },
                  obscureText: true,
                  controller: _PasswordController,
                  style: const TextStyle(color: Color(0xFFCCCCCC)),
                  decoration: InputDecoration(labelText: "Password", errorText: loginFailed ? "Invalid Password, maybe, idk" : null),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context, "Cancel");
                          });
                        },
                        child: const Text("Cancel")),
                    TextButton(
                        onPressed: () {
                          attemptLogin();
                        },
                        child: const Text("Login"))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class LoginButton extends StatefulWidget {
  const LoginButton({super.key});

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  @override
  Widget build(BuildContext context) {
    if (Supabase.instance.client.auth.currentSession == null) {
      return CupertinoButton(
          child: const Text("Login"),
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const LoginPage();
            }));
            if (!context.mounted) return;
            setState(() {});
          });
    } else {
      return FutureBuilder(
          future: getUserData(Supabase.instance.client.auth.currentSession!),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            final data = snapshot.data!;
            return CupertinoButton(
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return AccountPage(User: data, ProfilePictureName: data.ProfilePictureName);
                }));
                if (!context.mounted) return;
                setState(() {});
              },
              child: Row(
                children: [
                  UserIcon(ImageURL: data.ProfilePictureURL, size: MediaQuery.of(context).size.width <= 300 ? 30 : 50),
                  MediaQuery.of(context).size.width >= 700
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            data.Username,
                            style: const TextStyle(color: Color(0xFFCCCCCC)),
                          ),
                        )
                      : const Padding(
                          padding: EdgeInsets.all(0),
                        ),
                ],
              ),
            );
          });
    }
  }
}
