import 'package:flutter/material.dart';
import 'package:nerdi/NavBar.dart';
import 'package:nerdi/UserIcon.dart';
import 'package:nerdi/UserData.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  UserData? Recipient;

  Future<List<UserData>> getMatchedUsers() async {
    List<UserData> output = List.empty(growable: true);

    var UserLiked = await Supabase.instance.client
        .from("Likes")
        .select()
        .eq("LikerID", Supabase.instance.client.auth.currentUser!.id);
    var images = Supabase.instance.client.storage.from("ProfilePictures");
    for (var i in UserLiked) {
      if (i["Liked"] == 2) {
        var tempUser = await Supabase.instance.client
            .from("UserInfo")
            .select()
            .eq("UserUID", i["LikedID"]);
        output.add(UserData(
            UUID: tempUser.first["UserUID"],
            Username: tempUser.first["Username"],
            Description: tempUser.first["Description"],
            Birthday: DateTime.parse(tempUser.first["Birthday"]),
            Gender: tempUser.first["Gender"],
            ProfilePictureName: tempUser.first["ProfilePictureName"],
            ProfilePictureURL:
                images.getPublicUrl(tempUser.first["ProfilePictureName"])));
      }
    }
    return output;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (Recipient == null) {
              setState(() {
                Navigator.pop(context);
              });
            } else {
              setState(() {
                Recipient = null;
              });
            }
          },
          backgroundColor: const Color(0xEEC78FFF),
          child: const Text("Back"),
        ),
        body: Row(children: [
          const NavBar(
            CurrentIndex: 4,
          ),
          Recipient == null ? MatchedUserList() : MesagingInterface()
        ]));
  }

  Widget MesagingInterface() {
    var appSize = MediaQuery.of(context).size;
    final stream = Supabase.instance.client
        .from("Messages")
        .stream(primaryKey: ["MessageUID"]).inFilter("Sender", [
      Supabase.instance.client.auth.currentUser!.id,
      Recipient!.UUID
    ]).order("Sent");
    var MessageController = TextEditingController();

    return Expanded(
      child: SizedBox(
        height: appSize.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card.filled(
              color: Colors.black,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    UserIcon(ImageURL: Recipient!.ProfilePictureURL),
                    Text(
                      Recipient!.Username,
                      style: const TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: appSize.height - 138,
              child: StreamBuilder(
                  stream: stream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var data = snapshot.data!.where((element) {
                      return element["Recipient"] == Recipient!.UUID ||
                          element["Recipient"] ==
                              Supabase.instance.client.auth.currentUser!.id;
                    });
                    return SingleChildScrollView(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            for (var i in data)
                              Row(
                                mainAxisAlignment:
                                    i["Sender"] == Recipient!.UUID
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.end,
                                children: [
                                  Card.filled(
                                    color: i["Sender"] == Recipient!.UUID
                                        ? Colors.white
                                        : const Color(0xEEC78FFF),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        i["Content"],
                                        textAlign:
                                            i["Sender"] == Recipient!.UUID
                                                ? TextAlign.start
                                                : TextAlign.end,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ]),
                    );
                  }),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: appSize.width >= 700
                      ? appSize.width - 400
                      : appSize.width - 250,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextField(
                      onSubmitted: (data) async {
                        await Supabase.instance.client.from("Messages").insert({
                          "Content": MessageController.text,
                          "Sender": Supabase.instance.client.auth.currentUser!.id,
                          "Recipient": Recipient!.UUID,
                        });
                        setState(() {
                          MessageController.text = "";
                        });
                      },
                      controller: MessageController,
                      style: const TextStyle(color: Colors.white),
                      maxLength: 512,
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () async {
                      await Supabase.instance.client.from("Messages").insert({
                        "Content": MessageController.text,
                        "Sender": Supabase.instance.client.auth.currentUser!.id,
                        "Recipient": Recipient!.UUID,
                      });
                      setState(() {
                        MessageController.text = "";
                      });
                    },
                    icon: const Icon(Icons.send))
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget MatchedUserList() {
    return Expanded(
      child: FutureBuilder(
          future: getMatchedUsers(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              children: [
                for (var i in snapshot.data!)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        Recipient = i;
                      });
                    },
                    child: Row(
                      children: [
                        UserIcon(ImageURL: i.ProfilePictureURL),
                        Text(
                          i.Username,
                          style: const TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  )
              ],
            );
          }),
    );
  }
}
