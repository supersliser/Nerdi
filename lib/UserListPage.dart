import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nerdi/Login.dart';
import 'package:nerdi/NavBar.dart';
import 'package:nerdi/NewUser.dart';
import 'package:nerdi/UserData.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nerdi/UserCard.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  var _users = Supabase.instance.client.from('UserInfo').select("*");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const NewUser()));
          },
          backgroundColor: const Color(0xEEC78FFF),
          label: const Text("Create new user"),
        ),
        body: Row(
          children: [
            NavBar(
              CurrentIndex: 0,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _users =
                        Supabase.instance.client.from('UserInfo').select("*");
                  });
                },
                child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _users,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final data = snapshot.data!;
                      final images = Supabase.instance.client.storage
                          .from("ProfilePictures");
                      return Center(
                        child: SizedBox(
                          width: 400,
                          child: ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              return UserCard(
                                User: UserData(
                                  UUID: data[index]["UserUID"],
                                  Username: data[index]["Username"],
                                  Birthday:
                                      DateTime.parse(data[index]["Birthday"]),
                                  Gender: data[index]["Gender"],
                                  Description: data[index]["Description"],
                                  ProfilePictureURL: images.getPublicUrl(
                                    data[index]["ProfilePictureName"],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }),
              ),
            ),
          ],
        ));
  }
}
