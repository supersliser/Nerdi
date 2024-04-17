import 'package:flutter/material.dart';
import 'package:nerdi/NavBar.dart';
import 'package:nerdi/StartPage.dart';
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
    List<UserData> PossibleUsers = List.empty(growable: true);
    var UserDataTemp = await Supabase.instance.client
        .from("UserInfo")
        .select()
        .eq("UserUID", Supabase.instance.client.auth.currentUser!.id);
    var User = UserData(
      UUID: UserDataTemp.first["UserUID"],
      Username: UserDataTemp.first["Username"],
      Description: UserDataTemp.first["Description"],
      Birthday: DateTime.parse(UserDataTemp.first["Birthday"]),
      ProfilePictureName: UserDataTemp.first["ProfilePictureName"],
      Gender: UserDataTemp.first["Gender"],
      ProfilePictureURL: Supabase.instance.client.storage
          .from("ProfilePictures")
          .getPublicUrl(UserDataTemp.first["ProfilePictureName"]),
    );
    await User.getGendersLookingFor();
    var PossibleUsersTemp = await Supabase.instance.client
        .from("UserInfo")
        .select()
        .neq(
            "UserUID",
            Supabase.instance.client.auth.currentUser == null
                ? const UuidV4().generate()
                : Supabase.instance.client.auth.currentUser!.id);
    for (var item in PossibleUsersTemp) {
      PossibleUsers.add(UserData(
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
    var iterableLoop = PossibleUsers;
    for (int i = 0; i < iterableLoop.length; i++) {
      if (!User.GendersLookingFor[iterableLoop[i].Gender-1]) {
        PossibleUsers.removeAt(i);
      }
    }
    var likes = await Supabase.instance.client
        .from("Likes")
        .select("LikedID")
        .eq("LikerID", Supabase.instance.client.auth.currentUser!.id);
    PossibleUsers.removeWhere((element) {
      return likes.where((elementee) {
        return elementee["LikedID"] == element.UUID;
      }).isNotEmpty;
    });
    List<Map<UserData, int>> SortingUsers = List.empty(growable: true);
    var UserInterests = await User.getInterests();
    for (int i = 0; i < PossibleUsers.length; i++) {
      SortingUsers.add({PossibleUsers[i]: 0});
      var tempUserInterests = await PossibleUsers[i].getInterests();
      for (int j = 0; j < tempUserInterests.length; j++) {
        for (int k = 0; k < UserInterests.length; k++) {
          if (UserInterests[k].ID == tempUserInterests[j].ID) {
            SortingUsers.last.update(PossibleUsers[i], (value) {
              return value++;
            });
          }
        }
      }
    }
    SortingUsers.sort((a, b) => a.values.first.compareTo(b.values.first) * -1);
    return List.generate(
        SortingUsers.length, (index) => SortingUsers[index].keys.first);
  }

  @override
  Widget build(BuildContext context) {
    if (Supabase.instance.client.auth.currentUser == null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const StartPage()));
    }
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
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            UserCard(
                              User: data[index],
                              parentSetState: setState,
                            ),
                          ],
                        );
                      },
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
