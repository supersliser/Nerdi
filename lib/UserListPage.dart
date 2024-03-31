import 'package:flutter/material.dart';
import 'package:nerdi/NavBar.dart';
import 'package:nerdi/UserData.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nerdi/UserCard.dart';
import 'package:uuid/v4.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  Future<List<UserData>> getUsers() async {
    var temp = await Supabase.instance.client
        .from("UserInfo")
        .select()
        .neq("UserUID", Supabase.instance.client.auth.currentUser == null ? const UuidV4().generate() : Supabase.instance.client.auth.currentUser!.id);

    var likes = await Supabase.instance.client.from("Likes").select("LikedID").eq("LikerID", Supabase.instance.client.auth.currentUser!.id);

    temp.removeWhere((element) {
      return likes.where((elementee) {
        return elementee["LikedID"] == element["UserUID"];
      }).isNotEmpty;
    });
    List<UserData> output = List.empty(growable: true);
    for (var item in temp) {
      output.add(UserData(
          UUID: item["UserUID"],
          Username: item["Username"],
          Birthday: DateTime.parse(item["Birthday"]),
          Gender: item["Gender"],
          Description: item["Description"],
          ProfilePictureName: item["ProfilePictureName"],
          ProfilePictureURL: Supabase.instance.client.storage
              .from("ProfilePictures")
              .getPublicUrl(item["ProfilePictureName"])));
    }
    return output;
  }

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
                setState(() {});
              },
              child: FutureBuilder(
                  future: getUsers(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final data = snapshot.data!;
                    return Center(
                      child: SizedBox(
                        width: 400,
                        child: ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return UserCard(User: data[index], parentSetState: setState,);
                          },
                        ),
                      ),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
