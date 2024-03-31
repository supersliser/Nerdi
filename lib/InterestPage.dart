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
  bool editMode = false;
  final _formKey = GlobalKey<FormState>();

  final _NameController = TextEditingController();
  final _DescController = TextEditingController();

  Future<List<Interest>> getChildrenInterests() async {
    List<Interest> output = List.empty(growable: true);

    final data = await Supabase.instance.client
        .from("InterestSubInterest")
        .select("SubInterestID")
        .eq("InterestID", widget.interest.ID);

    final images = Supabase.instance.client.storage.from("Interests");

    for (int i = 0; i < data.length; i++) {
      var interestItem = await Supabase.instance.client
          .from("Interest")
          .select()
          .eq("ID", data[i]["SubInterestID"]);
      print("test");
      output.add(Interest(
          ID: interestItem.first["ID"],
          Name: interestItem.first["Name"],
          Description: interestItem.first["Description"],
          ImageName: interestItem.first["ImageName"],
          ImageURL: images.getPublicUrl(interestItem.first["ImageName"]),
          PrimaryColour: Color.fromARGB(
              0xFF,
              interestItem.first["PrimaryColourRed"],
              interestItem.first["PrimaryColourGreen"],
              interestItem.first["PrimaryColourBlue"])));
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
    var temp = await Supabase.instance.client
        .from("Interest")
        .select()
        .neq("ID", widget.interest.ID);
    List<Interest> output = List.empty(growable: true);
    for (int i = 0; i < temp.length; i++) {
      output.add(Interest(
          ID: temp[i]["ID"],
          Name: temp[i]["Name"],
          Description: temp[i]["Description"],
          ImageName: temp[i]["ImageName"],
          ImageURL: Supabase.instance.client.storage
              .from("Interests")
              .getPublicUrl(temp[i]["ImageName"]),
          PrimaryColour: Color.fromARGB(0xFF, temp[i]["PrimaryColourRed"],
              temp[i]["PrimaryColourGreen"], temp[i]["PrimaryColourBlue"])));
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
              .getPublicUrl(tempInterest.first["ImageName"]),
          PrimaryColour: Color.fromARGB(
              0xFF,
              tempInterest.first["PrimaryColourRed"],
              tempInterest.first["PrimaryColourGreen"],
              tempInterest.first["PrimaryColourBlue"])));
    }
    var childInterestGetter = await Supabase.instance.client
        .from("InterestSubInterest")
        .select()
        .eq("InterestID", widget.interest.ID);
    for (int i = 0; i < childInterestGetter.length; i++) {
      var tempInterest = await Supabase.instance.client
          .from("Interest")
          .select()
          .eq("ID", childInterestGetter[i]["SubInterestID"]);
      childInterests.add(Interest(
          ID: tempInterest.first["ID"],
          Name: tempInterest.first["Name"],
          Description: tempInterest.first["Description"],
          ImageName: tempInterest.first["ImageName"],
          ImageURL: Supabase.instance.client.storage
              .from("Interests")
              .getPublicUrl(tempInterest.first["ImageName"]),
          PrimaryColour: Color.fromARGB(
              0xFF,
              tempInterest.first["PrimaryColourRed"],
              tempInterest.first["PrimaryColourGreen"],
              tempInterest.first["PrimaryColourBlue"])));
    }

    return output;
  }

  @override
  Widget build(BuildContext context) {
    var appSize = MediaQuery.of(context).size;
    if (editMode) {
      return InterestEditor();
    } else {
      return InterestViewer(context, appSize);
    }
  }

  Row InterestViewer(BuildContext context, Size appSize) {
    return Row(
      children: [
        const NavBar(),
        Expanded(
          child: Scaffold(
            floatingActionButton: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Back"),
              ),
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
                      fontSize: 50,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(widget.interest.Description,
                          style: const TextStyle(
                            color: Color(0xFFCCCCCC),
                            fontSize: 20,
                          )),
                      Padding(
                        padding: const EdgeInsets.only(top: 30, bottom: 30),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.start,
                          alignment: WrapAlignment.start,
                          children: [
                            SizedBox(
                              width: appSize.width >= 324
                                  ? 324
                                  : appSize.width - 324,
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
                                              child:
                                                  CircularProgressIndicator());
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
                                                                      data[
                                                                          i])));
                                                },
                                                child: Card.outlined(
                                                    color:
                                                        data[i].PrimaryColour,
                                                    clipBehavior:
                                                        Clip.antiAlias,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        SizedBox(
                                                          width: 50,
                                                          child: FadeInImage
                                                              .memoryNetwork(
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  placeholder:
                                                                      kTransparentImage,
                                                                  image: data[i]
                                                                      .ImageURL),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 8.0),
                                                          child: Text(
                                                              data[i].Name),
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
                            Column(
                              children: [
                                const Text(
                                  "Others interested in this",
                                  style: TextStyle(
                                      color: Color(0xFFCCCCCC), fontSize: 20),
                                ),
                                FutureBuilder(
                                    future: getUsersWithInterest(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }
                                      return Column(
                                        children: [
                                          for (int i = 0;
                                              i < snapshot.data!.length;
                                              i++)
                                            UserCard(User: snapshot.data![i], parentSetState: null,)
                                        ],
                                      );
                                    })
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ),
      ],
    );
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
                  style: const TextStyle(
                    color: Colors.white,
                  ),
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
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  controller: _DescController,
                  maxLength: 20000,
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
                        Expanded(
                          child: Column(children: [
                            const Text(
                              "Parents",
                              style: TextStyle(color: Colors.white),
                            ),
                            Wrap(
                              children: [
                                for (int i = 0; i < data.length; i++)
                                  InterestChip(data[i], parentInterests)
                              ],
                            )
                          ]),
                        ),
                        Expanded(
                          child: Column(children: [
                            const Text("Children",
                                style: TextStyle(color: Colors.white)),
                            Wrap(
                              children: [
                                for (int i = 0; i < data.length; i++)
                                  InterestChip(data[i], childInterests)
                              ],
                            )
                          ]),
                        ),
                      ]);
                    }),
                FutureBuilder(
                    future: getUserData(
                        Supabase.instance.client.auth.currentSession!),
                    builder: (context, snapshot) {
                      return ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              widget.interest.upload(parentInterests,
                                  childInterests, snapshot.data!);
                              setState(() {
                                editMode = !editMode;
                              });
                            }
                          },
                          child: const Text("Publish Changes"));
                    })
              ],
            )));
  }

  ChoiceChip InterestChip(Interest data, List<Interest> interests) {
    return ChoiceChip(
      label: Text(data.Name),
      selected: interests.where((element) {
        return element.ID == data.ID;
      }).isNotEmpty,
      onSelected: (context) {
        if (interests.where((element) {
          return element.ID == data.ID;
        }).isNotEmpty) {
          setState(() {
            interests.removeWhere((item) {
              return item.ID == data.ID;
            });
          });
        } else {
          setState(() {
            interests.add(data);
          });
        }
      },
    );
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
