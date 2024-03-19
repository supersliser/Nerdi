import 'package:flutter/material.dart';
import 'package:nerdi/InterestData.dart';
import 'package:nerdi/Login.dart';
import 'package:nerdi/NavBar.dart';
import 'package:nerdi/UserCard.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:nerdi/UserData.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class InterestPage extends StatefulWidget {
  const InterestPage({super.key, required this.interest});

  final Interest interest;

  @override
  State<InterestPage> createState() => _InterestPageState();
}

class _InterestPageState extends State<InterestPage> {
  final bool editMode = false;
  final _formKey = GlobalKey<FormState>();

  final _NameController = TextEditingController();
  final _DescController = TextEditingController();

  Future<List<Interest>> getChildrenInterests() async {
    List<Interest> output = List.empty(growable: true);

    final data = await Supabase.instance.client
        .from("InterestSubInterest")
        .select()
        .eq("InterestID", widget.interest.ID);

    for (int i = 0; i < data.length; i++) {
      final interestItem = await Supabase.instance.client
          .from("Interest")
          .select()
          .eq("ID", data[i]["SubInterestID"]);
      output.add(Interest(
          ID: interestItem.first["ID"],
          Name: interestItem.first["Name"],
          Description: interestItem.first["Description"],
          ImageName: interestItem.first["ImageName"],
          ImageURL: Supabase.instance.client.storage
              .from("Interests")
              .getPublicUrl(interestItem.first["ImageName"])));
    }
    return output;
  }

  Future<List<UserData>> getUsersWithInterest() async {
    List<UserData> output = List.empty(growable: true);

    final data = await Supabase.instance.client
        .from("UserInterest")
        .select()
        .eq("InterestID", widget.interest.ID);

    for (int i = 0; i < data.length; i++) {
      final tempUser = await Supabase.instance.client
          .from("UserInfo")
          .select()
          .eq("UserUID", data[i]["UserID"]);
      output.add(UserData(
          UUID: tempUser.first["UserUID"],
          Username: tempUser.first["Username"],
          Birthday: DateTime.parse(tempUser.first["Birthday"]),
          Description: tempUser.first["Description"],
          Gender: tempUser.first["Gender"],
          ProfilePictureURL: Supabase.instance.client.storage
              .from("ProfilePictures")
              .getPublicUrl(tempUser.first["ProfilePictureName"])));
    }
    return output;
  }

  Future<List<Interest>> getAllInterests() async {
    var temp = await Supabase.instance.client.from("Interest").select();
    List<Interest> output = List.empty(growable: true);
    for (int i = 0; i < temp.length; i++) {
      output.add(Interest(
          ID: temp[i]["ID"],
          Name: temp[i]["Name"],
          Description: temp[i]["Description"],
          ImageName: temp[i]["ImageName"],
          ImageURL: Supabase.instance.client.storage
              .from("Interests")
              .getPublicUrl(temp[i]["ImageName"])));
    }

    var parentInterestGetter = await Supabase.instance.client
        .from("InterestSubInterest")
        .select()
        .eq("SubInterestID", widget.interest.ID);
    for (int i = 0; i < parentInterestGetter.length; i++) {
      var tempInterest = await Supabase.instance.client
          .from("Interest")
          .select()
          .eq("ID", parentInterestGetter[i]["InterestID"]);
      parentInterests.add(Interest(
          ID: tempInterest.first["ID"],
          Name: tempInterest.first["Name"],
          Description: tempInterest.first["Description"],
          ImageName: tempInterest.first["ImageName"],
          ImageURL: Supabase.instance.client.storage
              .from("Interests")
              .getPublicUrl(tempInterest.first["ImageName"])));
    }

    var childInterestGetter = await Supabase.instance.client
        .from("InterestSubInterest")
        .select()
        .eq("InterestID", widget.interest.ID);
    for (int i = 0; i < childInterestGetter.length; i++) {
      var tempInterest = await Supabase.instance.client
          .from("Interest")
          .select()
          .eq("ID", parentInterestGetter[i]["SubInterestID"]);
      childInterests.add(Interest(
          ID: tempInterest.first["ID"],
          Name: tempInterest.first["Name"],
          Description: tempInterest.first["Description"],
          ImageName: tempInterest.first["ImageName"],
          ImageURL: Supabase.instance.client.storage
              .from("Interests")
              .getPublicUrl(tempInterest.first["ImageName"])));
    }

    return output;
  }

  @override
  Widget build(BuildContext context) {
    var appSize = MediaQuery.of(context).size;
    if (editMode) {
      return InterestEditor();
    } else {
      return Row(
        children: [
          const NavBar(),
          Expanded(
            child: Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Back"),
              ),
              body: SingleChildScrollView(
                child: Column(children: [
                  SizedBox(
                    width: appSize.width,
                    height: 100,
                    child: FadeInImage.memoryNetwork(
                        fit: BoxFit.cover,
                        placeholder: kTransparentImage,
                        image: widget.interest.ImageURL),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(25),
                    child: Text(
                      widget.interest.Name,
                      style: const TextStyle(
                        color: Color(0xFFCCCCCC),
                        fontSize: 80,
                      ),
                    ),
                  ),
                  Wrap(
                    children: [
                      SizedBox(
                        width: appSize.width <= 624 ? 324 : appSize.width - 324,
                        child: Column(
                          children: [
                            Text(widget.interest.Description,
                                style: const TextStyle(
                                  color: Color(0xFFCCCCCC),
                                  fontSize: 20,
                                )),
                            Padding(
                              padding: const EdgeInsets.only(top: 30, bottom: 30),
                              child: Column(
                                children: [
                                  const Text("Related interests",
                                      style: TextStyle(
                                        color: Color(0xFFCCCCCC),
                                      )),
                                  FutureBuilder(
                                      future: getChildrenInterests(),
                                      builder: (context, snapshop) {
                                        if (!snapshop.hasData) {
                                          return const Center(
                                              child: CircularProgressIndicator());
                                        }
                                        var data = snapshop.data!;
                                        return Column(
                                          children: [
                                            for (int i = 0;
                                                i < snapshop.data!.length;
                                                i++)
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              InterestPage(
                                                                  interest:
                                                                      data[i])));
                                                },
                                                child: Card.outlined(
                                                    color: const Color(0xFFC78FFF),
                                                    clipBehavior: Clip.antiAlias,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.center,
                                                      children: [
                                                        SizedBox(
                                                          width: 50,
                                                          child: FadeInImage
                                                              .memoryNetwork(
                                                                  fit: BoxFit.cover,
                                                                  placeholder:
                                                                      kTransparentImage,
                                                                  image: data[i]
                                                                      .ImageURL),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                  left: 8.0),
                                                          child: Text(data[i].Name),
                                                        )
                                                      ],
                                                    )),
                                              ),
                                          ],
                                        );
                                      }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          const SizedBox(
                            width: 300,
                            child: Text(
                              "Others interested in this",
                              style:
                                  TextStyle(color: Color(0xFFCCCCCC), fontSize: 20),
                            ),
                          ),
                          FutureBuilder(
                              future: getUsersWithInterest(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                return Column(
                                  children: [
                                    for (int i = 0; i < snapshot.data!.length; i++)
                                      UserCard(User: snapshot.data![i])
                                  ],
                                );
                              })
                        ],
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ),
        ],
      );
    }
  }

  List<Interest> parentInterests = List.empty(growable: true);
  List<Interest> childInterests = List.empty(growable: true);
  Widget InterestEditor() {
    return Scaffold(
        body: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _NameController,
                  initialValue: widget.interest.Name,
                  decoration: const InputDecoration(
                    labelText: "Interest Title",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "You have to put like some actual text here you can't just leave it blank";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _DescController,
                  expands: true,
                  maxLength: 20000,
                  initialValue: widget.interest.Description,
                  decoration: const InputDecoration(
                    labelText: "Description",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Tell us something about this c'mon.";
                    }
                    return null;
                  },
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Card.outlined(
                      clipBehavior: Clip.hardEdge,
                      color: const Color(0xFFC78FFF),
                      child: FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: widget.interest.ImageURL,
                        width: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              pickImage();
                            });
                          },
                          child: const Text("Select Image")),
                    )
                  ],
                ),
                FutureBuilder(
                    future: getAllInterests(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      var data = snapshot.data!;
                      return Row(children: [
                        Column(children: [
                          const Text("Parents"),
                          Wrap(
                            children: [
                              for (int i = 0; i < data.length; i++)
                                ChoiceChip(
                                  label: Text(data[i].Name),
                                  selected: parentInterests.contains(data[i]),
                                  onSelected: (context) {
                                    setState(() {
                                      if (parentInterests.contains(data[i])) {
                                        parentInterests.remove(data[i]);
                                      } else {
                                        parentInterests.add(data[i]);
                                      }
                                    });
                                  },
                                )
                            ],
                          )
                        ]),
                        Column(children: [
                          const Text("Children"),
                          Wrap(
                            children: [
                              for (int i = 0; i < data.length; i++)
                                ChoiceChip(
                                  label: Text(data[i].Name),
                                  selected: childInterests.contains(data[i]),
                                  onSelected: (context) {
                                    setState(() {
                                      if (childInterests.contains(data[i])) {
                                        childInterests.remove(data[i]);
                                      } else {
                                        childInterests.add(data[i]);
                                      }
                                    });
                                  },
                                )
                            ],
                          )
                        ]),
                      ]);
                    }),
                FutureBuilder(
                  future: getUserData(Supabase.instance.client.auth.currentSession!),
                  builder: (context, snapshot) {
                    return ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            widget.interest.upload(parentInterests, childInterests, snapshot.data!);
                          }
                        },
                        child: const Text("Publish Changes"));
                  }
                )
              ],
            )));
  }

  Future<void> pickImage() async {
    String imageName = widget.interest.getImageUUID();
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      var temp = await widget.interest.uploadImage(image, imageName);
      setState(() {
        widget.interest.ImageURL = temp;
      });
    }
  }
}
