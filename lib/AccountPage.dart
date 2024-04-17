import 'package:flutter/material.dart';
import 'package:nerdi/NavBar.dart';
import 'package:nerdi/StartPage.dart';
import 'package:nerdi/UserData.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:nerdi/InterestData.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(labelText: "New Password", labelStyle: TextStyle(color: Colors.white)),
            onSubmitted: (value) {
              Supabase.instance.client.auth.updateUser(UserAttributes(password: passwordController.text));
              Navigator.pop(context);
            },
          ),
          TextButton(
              onPressed: () {
                Supabase.instance.client.auth.updateUser(UserAttributes(password: passwordController.text));
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                "Submit",
                style: TextStyle(color: Colors.white),
              )),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
    );
  }
}

class AccountPage extends StatefulWidget {
  const AccountPage({super.key, required this.User, required this.ProfilePictureName});

  final UserData User;
  final String ProfilePictureName;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  var UsernameController = TextEditingController();
  var DescriptionController = TextEditingController();
  bool initialSetup = false;
  List<Interest> UserInterest = List.empty(growable: true);
  bool userInterestSet = false;

  Future<void> pickImage() async {
    String imageName = widget.User.getImageUUID();
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      var temp = await widget.User.uploadImage(image, imageName, image.name.split(".")[1]);
      setState(() {
        widget.User.ProfilePictureName = temp;
      });
    }
  }

  Future<List<Interest>> getAllInterests() async {
    var temp = await Supabase.instance.client.from("Interest").select();
    var images = Supabase.instance.client.storage.from("Interests");

    if (!userInterestSet) {
      var userTemp = await Supabase.instance.client.from("UserInterest").select().eq("UserID", Supabase.instance.client.auth.currentUser!.id);
      for (var item in userTemp) {
        var tempInterest = temp.where((element) {
          return element["ID"] == item["InterestID"];
        }).first;
        UserInterest.add(Interest(
            ID: tempInterest["ID"],
            Name: tempInterest["Name"],
            Description: tempInterest["Description"],
            ImageName: tempInterest["ImageName"],
            ImageURL: images.getPublicUrl(tempInterest["ImageName"]),
            PrimaryColour: Color.fromARGB(0xFF, tempInterest["PrimaryColourRed"], tempInterest["PrimaryColourGreen"], tempInterest["PrimaryColourBlue"])));
        userInterestSet = true;
      }
    }
    return List.generate(temp.length, (index) {
      return Interest(
          ID: temp[index]["ID"],
          Name: temp[index]["Name"],
          Description: temp[index]["Description"],
          ImageName: temp[index]["ImageName"],
          ImageURL: images.getPublicUrl(temp[index]["ImageName"]),
          PrimaryColour: Color.fromARGB(0xFF, temp[index]["PrimaryColourRed"], temp[index]["PrimaryColourGreen"], temp[index]["PrimaryColourBlue"]));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!initialSetup) {
      UsernameController.text = widget.User.Username;
      DescriptionController.text = widget.User.Description;
      initialSetup = true;
    }
    return Scaffold(
      body: Row(
        children: [
          const NavBar(
            CurrentIndex: null,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  PrimaryImageContainer(),
                  UsernameInput(),
                  DescriptionInput(),
                  GenderSelector(),
                  InterestSelector(),
                  Column(
                    children: [SaveButton(), ChangePasswordButton(context), SignOutButton(context), DeleteAccountButton(context)],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding DeleteAccountButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButton(
          onPressed: () {
            Navigator.pop(context);
            setState(
              () {
                Supabase.instance.client.from("UserData").delete().eq("UserUID", Supabase.instance.client.auth.currentUser!.id);
                Supabase.instance.client.auth.signOut(scope: SignOutScope.global);
                Navigator.pop(context);
              },
            );
          },
          style: TextButton.styleFrom(backgroundColor: Colors.black),
          child: const Text(
            "Delete Account",
            style: TextStyle(color: Colors.white),
          )),
    );
  }

  Padding ChangePasswordButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButton(
          onPressed: () {
            Navigator.pop(context);
            setState(
              () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordPage()));
              },
            );
          },
          style: TextButton.styleFrom(backgroundColor: Colors.yellow),
          child: const Text(
            "Change Password",
            style: TextStyle(color: Colors.black),
          )),
    );
  }

  Padding SignOutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButton(
          onPressed: () {
            Supabase.instance.client.auth.signOut();
            Navigator.push(context, MaterialPageRoute(builder: (context) => const StartPage()));
          },
          style: TextButton.styleFrom(backgroundColor: Colors.red),
          child: const Text(
            "Sign Out",
            style: TextStyle(color: Colors.black),
          )),
    );
  }

  Padding SaveButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButton(
          onPressed: () async {
            await Supabase.instance.client.from("UserInterest").delete().eq("UserID", Supabase.instance.client.auth.currentUser!.id);
            for (var item in UserInterest) {
              await Supabase.instance.client.from("UserInterest").insert({"UserID": Supabase.instance.client.auth.currentUser!.id, "InterestID": item.ID});
            }
            widget.User.Username = UsernameController.text;
            widget.User.Description = DescriptionController.text;
            await widget.User.upload(widget.User.ProfilePictureName, null, null);
            setState(() {});
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(backgroundColor: Colors.green),
          child: const Text(
            "Save",
            style: TextStyle(color: Colors.black),
          )),
    );
  }

  Padding InterestSelector() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(children: [
          const Text(
            "Interests",
            style: TextStyle(
              color: Color(0xFFCCCCCC),
            ),
            textAlign: TextAlign.center,
          ),
          FutureBuilder(
              future: getAllInterests(),
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
                        selected: UserInterest.where((element) {
                          return element.ID == item.ID;
                        }).isNotEmpty,
                        onSelected: (selected) {
                          if (UserInterest.where((element) {
                            return element.ID == item.ID;
                          }).isNotEmpty) {
                            setState(() {
                              UserInterest.removeWhere((element) {
                                return element.ID == item.ID;
                              });
                            });
                          } else {
                            setState(() {
                              UserInterest.add(item);
                            });
                          }
                        },
                      )
                  ],
                );
              }),
        ]),
      ),
    );
  }

  Widget GenderSelector() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text("Gender", style: TextStyle(color: Color(0xFFCCCCCC))),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChoiceChip(
              backgroundColor: const Color(0xFFFF82FF),
              selectedColor: const Color(0xFFFF82FF),
              label: Text(GenderEnum.Female.name),
              selected: widget.User.Gender == 2,
              onSelected: (bool selected) {
                setState(() {
                  widget.User.Gender = selected ? 2 : 0;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChoiceChip(
              backgroundColor: const Color(0xFFFFEF63),
              selectedColor: const Color(0xFFFFEF63),
              label: Text(GenderEnum.NonBinary.name),
              selected: widget.User.Gender == 3,
              onSelected: (bool selected) {
                setState(() {
                  widget.User.Gender = selected ? 3 : 0;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChoiceChip(
              backgroundColor: const Color(0xFF63EDFF),
              selectedColor: const Color(0xFF63EDFF),
              label: Text(GenderEnum.Male.name),
              selected: widget.User.Gender == 1,
              onSelected: (bool selected) {
                setState(() {
                  widget.User.Gender = selected ? 1 : 0;
                });
              },
            ),
          )
        ]),
      ),
    ]);
  }

  Widget DescriptionInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        enableSuggestions: false,
        maxLength: 5000,
        maxLines: null,
        onSubmitted: (text) {
          setState(() {
            if (DescriptionController.text.isEmpty) {
            } else {
              widget.User.Description = DescriptionController.text;
            }
          });
        },
        onChanged: (text) {
          setState(() {});
        },
        controller: DescriptionController,
        style: const TextStyle(color: Color(0xFFCCCCCC)),
        decoration: InputDecoration(
          error: DescriptionController.text.isEmpty ? const Text("Bro I promise you're not that boring", style: TextStyle(color: Color(0xFFCCCCCC))) : null,
          label: const Text("Description", style: TextStyle(color: Color(0xFFCCCCCC))),
        ),
      ),
    );
  }

  Widget UsernameInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onSubmitted: (text) {
          setState(() {
            if (UsernameController.text.isNotEmpty) {
              widget.User.Username = UsernameController.text;
            }
          });
        },
        onChanged: (text) {
          setState(() {});
        },
        controller: UsernameController,
        style: const TextStyle(color: Color(0xFFCCCCCC)),
        decoration: InputDecoration(
          error: UsernameController.text.isEmpty ? const Text("like at least give us something plz", style: TextStyle(color: Color(0xFFCCCCCC))) : null,
          label: const Text("Username", style: TextStyle(color: Color(0xFFCCCCCC))),
        ),
      ),
    );
  }

  Widget PrimaryImageContainer() {
    return Column(
      children: [
        Card.outlined(
          clipBehavior: Clip.hardEdge,
          color: const Color(0xFFC78FFF),
          child: FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            image: widget.User.ProfilePictureURL,
            width: 300,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
              onPressed: () async {
                await pickImage();
                setState(() {});
              },
              child: const Text("Select Image")),
        )
      ],
    );
  }
}
