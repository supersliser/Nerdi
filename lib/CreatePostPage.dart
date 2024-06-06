import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nerdi/NavBar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:nerdi/InterestData.dart';
import 'package:uuid/uuid.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  List<String> ImageNames = List.empty(growable: true);
  final MessageController = TextEditingController();
  List<String> PostInterest = List.empty(growable: true);

  String getImageUUID() {
    var UUIDgen = const Uuid();
    return UUIDgen.v4();
  }

  Future<String> uploadImage(XFile Image, String imageName, String type) async {
    if (kIsWeb) {
      var imageB = await Image.readAsBytes();
      await Supabase.instance.client.storage.from('PostImages').uploadBinary(imageName, imageB, fileOptions: FileOptions(contentType: "image/$type"));
    } else {
      await Supabase.instance.client.storage
          .from('PostImages')
          .upload(imageName, File(Image.path), fileOptions: FileOptions(contentType: "image/${Image.path.split(".").last}"));
    }
    return imageName;
  }

  Future<void> addImage() async {
    String imageName = getImageUUID();
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      var temp = await uploadImage(image, imageName, image.name.split(".")[1]);
      setState(() {
        ImageNames.add(temp);
      });
    }
  }

  Future<List<Interest>> getUserInterests() async {
    List<Interest> Output = List.empty(growable: true);

    var userinterests = await Supabase.instance.client.from("UserInterest").select("*").eq("UserID", Supabase.instance.client.auth.currentUser!.id);

    for (int i = 0; i < userinterests.length; i++) {
      var j = await Supabase.instance.client.from("Interest").select("*").eq("ID", userinterests[i]["InterestID"]);

      Output.add(Interest(
          ID: j.first["ID"],
          Name: j.first["Name"],
          Description: j.first["Description"],
          ImageName: j.first["ImageName"],
          PrimaryColour: Color.fromARGB(255, j.first["PrimaryColourRed"], j.first["PrimaryColourGreen"], j.first["PrimaryColourBlue"])));
    }

    return Output;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(children: [
      const NavBar(
        CurrentIndex: null,
      ), Expanded(
            child: SingleChildScrollView(
        child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: MessageController,
                        style: const TextStyle(color: Color(0xFFCCCCCC)),
                        decoration: const InputDecoration(labelText: "Message"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Images:", style: TextStyle(color: Colors.white),),
                          Wrap(
                            children: [
                              for (var i in ImageNames)
                                Card.outlined(
                                  color: Colors.white,
                                  clipBehavior: Clip.hardEdge,
                                  child: SizedBox(
                                    width: 400,
                                    height: 400,
                                    child: FadeInImage.memoryNetwork(
                                      placeholder: kTransparentImage,
                                      image: Supabase.instance.client.storage.from("PostImages").getPublicUrl(i),
                                      width: 300,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              Card.filled(
                                color: Colors.white,
                                clipBehavior: Clip.hardEdge,
                                child: SizedBox(
                                  width: 100,
                                  height: 150,
                                  child: Center(
                                    child: TextButton(
                                      onPressed: addImage,
                                      child: const Row(
                                        children: [
                                          Icon(Icons.add_a_photo),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text("Add"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    FutureBuilder(
                        future: getUserInterests(),
                        builder: (context, snapshot) {
                          if (snapshot.data == null) {
                            return const CircularProgressIndicator();
                          }
                          return Wrap(
                            children: [
                              for (var item in snapshot.data!)
                                ChoiceChip(
                                  backgroundColor: item.PrimaryColour,
                                  label: Text(item.Name),
                                  selected: PostInterest.where((element) {
                                    return element == item.ID;
                                  }).isNotEmpty,
                                  onSelected: (selected) {
                                    if (PostInterest.where((element) {
                                      return element == item.ID;
                                    }).isNotEmpty) {
                                      setState(() {
                                        PostInterest.removeWhere((element) {
                                          return element == item.ID;
                                        });
                                      });
                                    } else {
                                      setState(() {
                                        PostInterest.add(item.ID);
                                      });
                                    }
                                  },
                                )
                            ],
                          );
                        }),
                    Padding(
                      padding: const EdgeInsets.all(50),
                      child: TextButton(
                          onPressed: () async {
                            var post = await Supabase.instance.client.from("Posts").insert({
                              "PostedAt": DateTime.now().toString(),
                              "Message": MessageController.text,
                              "Author": Supabase.instance.client.auth.currentUser!.id
                            }).select("ID");
                            for (var i in ImageNames) {
                              await Supabase.instance.client.from("PostImages").insert({"PostID": post.first["ID"], "ImageName": i});
                            }
                            for (var i in PostInterest) {
                              await Supabase.instance.client.from("PostInterest").insert({"PostID": post.first["ID"], "InterestID": i});
                            }

                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Post",
                            style: TextStyle(color: Colors.green),
                          )),
                    ),
                  ],
                ),
        ),
      ),

    ]));
  }
}
