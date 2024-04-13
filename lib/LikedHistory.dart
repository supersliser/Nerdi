import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nerdi/NavBar.dart';
import 'package:nerdi/UserCard.dart';
import 'package:nerdi/UserDescPage.dart';
import 'package:nerdi/UserIcon.dart';
import 'package:nerdi/UserData.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LikedHistoryPage extends StatefulWidget {
  LikedHistoryPage({super.key});

  @override
  State<LikedHistoryPage> createState() => _LikedHistoryPageState();
}

class _LikedHistoryPageState extends State<LikedHistoryPage> {
  Future<List<UserData>> getLiked() async {
    var liked = await Supabase.instance.client
        .from("Likes")
        .select()
        .eq("LikerID", Supabase.instance.client.auth.currentUser!.id)
        .neq("Liked", -1);

    var output = List<UserData>.empty(growable: true);
    for (var i in liked) {
      var userData = await Supabase.instance.client
          .from("UserInfo")
          .select()
          .eq("UserUID", i["LikedID"]);
      output.add(UserData(
          UUID: userData.first["UserUID"],
          Username: userData.first["Username"],
          Birthday: DateTime.parse(userData.first["Birthday"]),
          Description: userData.first["Description"],
          ProfilePictureName: userData.first["ProfilePictureName"],
          Gender: userData.first["Gender"],
          ProfilePictureURL: Supabase.instance.client.storage
              .from("ProfilePictures")
              .getPublicUrl(userData.first["ProfilePictureName"])));
    }
    return output;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NavBar(CurrentIndex: 4),
          Expanded(
              child: FutureBuilder(
                  future: getLiked(),
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return CircularProgressIndicator();
                    }
                    return StaggeredGrid.count(
                      crossAxisCount:
                          (MediaQuery.of(context).size.width / 300).floor(),
                      children: [
                        for (var i in snapshot.data!)
                          Column(
                            children: [
                              nonInteractiveUserCard(User: i),
                              TextButton(
                                style: TextButton.styleFrom(
                                    backgroundColor: Colors.red),
                                child: Text(
                                  "Unlike person",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () async {
                                  var quickCheck = await Supabase
                                      .instance.client
                                      .from("Likes")
                                      .delete()
                                      .eq("LikedID", i.UUID)
                                      .eq(
                                          "LikerID",
                                          Supabase.instance.client.auth
                                              .currentUser!.id)
                                      .select();
                                  if (quickCheck.first["Liked"] == 2) {
                                    await Supabase.instance.client
                                        .from("Likes")
                                        .update({"Liked": 1})
                                        .eq(
                                            "LikedID",
                                            Supabase.instance.client.auth
                                                .currentUser!.id)
                                        .eq("LikerID", i.UUID);
                                  }
                                  setState(() {

                                  });
                                },
                              )
                            ],
                          )
                      ],
                    );
                  }))
        ],
      ),
    );
  }
}
