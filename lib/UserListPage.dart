import 'package:flutter/material.dart';
import 'package:nerdi/NavBar.dart';
import 'package:nerdi/UserData.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nerdi/UserCard.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  var _users = Supabase.instance.client.from('UserInfo').select("*");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
          children: [
            const NavBar(
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
