import 'package:flutter/material.dart';
import 'package:nerdi/UserData.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nerdi/UserCard.dart';

class UserListPage extends StatefulWidget {
  UserListPage({super.key, required this.title});

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
  final _users = Supabase.instance.client.from('UserInfo').select();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return FutureBuilder<List<Map<String, dynamic>>>(
        future: _users,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          final images =
              Supabase.instance.client.storage.from("ProfilePictures");
          return Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return UserCard(
                      User: new UserData(
                          data[index]["UserUID"],
                          data[index]["Username"],
                          DateTime.parse(data[index]["Birthday"]),
                          data[index]["Gender"],
                          data[index]["Description"],
                          images.getPublicUrl(
                            data[index]["ProfilePictureName"],
                          )),
                    );
                  },
                ),
              ),
            ),
          );
        });
  }
}
