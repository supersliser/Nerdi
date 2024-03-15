import 'dart:math';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nerdi/UserCard.dart';
import 'package:nerdi/UserData.dart';
import 'package:transparent_image/transparent_image.dart';

class NewUser extends StatefulWidget {
  const NewUser({super.key});

  @override
  State<NewUser> createState() => _NewUserState();
}

class _NewUserState extends State<NewUser> {
  final NameController = TextEditingController();
  final DescController = TextEditingController();
  final EmailController = TextEditingController();
  final PassController = TextEditingController();

  var User = UserData(Birthday: DateTime.now());
  String Email = "";
  String Password = "";
  bool NameSet = false;
  bool BirthdaySet = false;
  bool GendersSet = false;
  bool DescriptionSet = false;
  bool ProfilePictureSet = false;
  bool EmailSet = false;
  String ImageName = "";

  @override
  void dispose() {
    NameController.dispose();
    DescController.dispose();
    EmailController.dispose();
    PassController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    User.getImageUUID();
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      var temp = await User.uploadImage(image);
      setState(() {
        ImageName = temp;
      });
    }
  }

  Widget getQuestion() {
    if (!NameSet) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(getHello(), style: const TextStyle(color: Color(0xFFCCCCCC))),
          TextField(
            onSubmitted: (text) {
              setState(() {
                User.Username = NameController.text;
                NameSet = true;
              });
            },
            controller: NameController,
            style: const TextStyle(color: Color(0xFFCCCCCC)),
            decoration: const InputDecoration(
              label: Text("Enter your name",
                  style: TextStyle(color: Color(0xFFCCCCCC))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      onPressed: () {
                        setState(() {
                          User.Username = NameController.text;
                          NameSet = true;
                        });
                      },
                      child: const Text("Next",
                          style: TextStyle(color: Color(0xFF181818)))),
                )
              ],
            ),
          )
        ]),
      );
    } else if (!BirthdaySet) {
      List<DateTime> TempDate = List.empty(growable: true);
      if (User.Birthday == null) {
        TempDate.add(DateTime.now());
      } else {
        TempDate.add(User.Birthday!);
      }
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text("Hi There ${User.Username}.\nWhen were you born?",
              style: const TextStyle(color: Color(0xFFCCCCCC))),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CalendarDatePicker2(
              config: CalendarDatePicker2Config(
                  currentDate: User.Birthday,
                  controlsTextStyle: const TextStyle(
                    color: Color(0xFFCCCCCC),
                  ),
                  dayTextStyle: const TextStyle(
                    color: Color(0xFFCCCCCC),
                  ),
                  weekdayLabelTextStyle: const TextStyle(
                    color: Color(0xFFCCCCCC),
                  ),
                  yearTextStyle: const TextStyle(
                    color: Color(0xFFCCCCCC),
                  ),
                  firstDate: DateTime(0000, 1, 1),
                  lastDate: DateTime.now()),
              value: TempDate,
              onValueChanged: (value) {
                setState(() {
                  User.Birthday = DateTime.parse(value.last.toString());
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        setState(() {
                          BirthdaySet = false;
                          NameSet = false;
                        });
                      },
                      child: const Text("Back",
                          style: TextStyle(color: Color(0xFF181818)))),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      onPressed: () {
                        setState(() {
                          BirthdaySet = true;
                        });
                      },
                      child: const Text("Next",
                          style: TextStyle(color: Color(0xFF181818)))),
                )
              ],
            ),
          )
        ]),
      );
    } else if (!GendersSet) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("So ${User.Username}, you're ${User.getAge()} years old?",
                style: const TextStyle(color: Color(0xFFCCCCCC))),
            const Text("Whats your gender",
                style: TextStyle(color: Color(0xFFCCCCCC))),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ChoiceChip(
                        label: Text(GenderEnum.Female.name),
                        selected: User.Gender == 2,
                        onSelected: (bool selected) {
                          setState(() {
                            User.Gender = selected ? 2 : 0;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ChoiceChip(
                        label: Text(GenderEnum.NonBinary.name),
                        selected: User.Gender == 3,
                        onSelected: (bool selected) {
                          setState(() {
                            User.Gender = selected ? 3 : 0;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ChoiceChip(
                        label: Text(GenderEnum.Male.name),
                        selected: User.Gender == 1,
                        onSelected: (bool selected) {
                          setState(() {
                            User.Gender = selected ? 1 : 0;
                          });
                        },
                      ),
                    )
                  ]),
            ),
            const Text("And what genders are you looking for",
                style: TextStyle(color: Color(0xFFCCCCCC))),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ChoiceChip(
                        label: Text(GenderEnum.Female.name),
                        selected:
                            User.GendersLookingFor[GenderEnum.Female.index - 1],
                        onSelected: (bool selected) {
                          setState(() {
                            User.GendersLookingFor[
                                GenderEnum.Female.index - 1] = selected;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ChoiceChip(
                        label: Text(GenderEnum.NonBinary.name),
                        selected: User
                            .GendersLookingFor[GenderEnum.NonBinary.index - 1],
                        onSelected: (bool selected) {
                          setState(() {
                            User.GendersLookingFor[
                                GenderEnum.NonBinary.index - 1] = selected;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ChoiceChip(
                        label: Text(GenderEnum.Male.name),
                        selected:
                            User.GendersLookingFor[GenderEnum.Male.index - 1],
                        onSelected: (bool selected) {
                          setState(() {
                            User.GendersLookingFor[GenderEnum.Male.index - 1] =
                                selected;
                          });
                        },
                      ),
                    )
                  ]),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        onPressed: () {
                          setState(() {
                            BirthdaySet = false;
                            GendersSet = false;
                          });
                        },
                        child: const Text("Back",
                            style: TextStyle(color: Color(0xFF181818)))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        onPressed: () {
                          setState(() {
                            GendersSet = true;
                          });
                        },
                        child: const Text("Next",
                            style: TextStyle(color: Color(0xFF181818)))),
                  )
                ],
              ),
            )
          ],
        ),
      );
    } else if (!DescriptionSet) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
                "Hmm, sounds like fun.\nWhy dont you tell us some stuff about you?",
                style: TextStyle(color: Color(0xFFCCCCCC))),
            TextField(
              enableSuggestions: false,
              maxLength: 5000,
              maxLines: null,
              onSubmitted: (text) {
                setState(() {
                  User.Description = DescController.text;
                  DescriptionSet = true;
                });
              },
              controller: DescController,
              style: const TextStyle(color: Color(0xFFCCCCCC)),
              decoration: const InputDecoration(
                label: Text("Enter some stuff about you",
                    style: TextStyle(color: Color(0xFFCCCCCC))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        onPressed: () {
                          setState(() {
                            GendersSet = false;
                            DescriptionSet = false;
                          });
                        },
                        child: const Text("Back",
                            style: TextStyle(color: Color(0xFF181818)))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        onPressed: () {
                          setState(() {
                            User.Description = DescController.text;
                            DescriptionSet = true;
                          });
                        },
                        child: const Text("Next",
                            style: TextStyle(color: Color(0xFF181818)))),
                  )
                ],
              ),
            )
          ],
        ),
      );
    } else if (!ProfilePictureSet) {
      return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text(
                "We sound like we would be great friends.\nFinally, why dont you show us your beautiful face?",
                style: TextStyle(color: Color(0xFFCCCCCC))),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card.outlined(
                  clipBehavior: Clip.hardEdge,
                  color: const Color(0xFFC78FFF),
                  child: FadeInImage.memoryNetwork(
                    placeholder: kTransparentImage,
                    image: User.ProfilePictureURL,
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        onPressed: () {
                          setState(() {
                            DescriptionSet = false;
                            ProfilePictureSet = false;
                          });
                        },
                        child: const Text("Back",
                            style: TextStyle(color: Color(0xFF181818)))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        onPressed: () {
                          setState(() {
                            ProfilePictureSet = true;
                          });
                        },
                        child: const Text("Next",
                            style: TextStyle(color: Color(0xFF181818)))),
                  )
                ],
              ),
            )
          ]));
    } else if (!EmailSet) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
                textAlign: TextAlign.center,
                "OK OK last thing I promise\nPlease enter your email and password \n(were not gonna send you any emails its literally just so supabase agrees w me)",
                style: TextStyle(color: Color(0xFFCCCCCC))),
            TextField(
              onSubmitted: (text) {
                setState(() {
                  Email = EmailController.text;
                });
              },
              controller: EmailController,
              style: const TextStyle(color: Color(0xFFCCCCCC)),
              decoration: const InputDecoration(
                label: Text("Enter your email",
                    style: TextStyle(color: Color(0xFFCCCCCC))),
              ),
            ),
            TextField(
              obscureText: true,
              onSubmitted: (text) {
                setState(() {
                  Password = PassController.text;
                });
              },
              controller: PassController,
              style: const TextStyle(color: Color(0xFFCCCCCC)),
              decoration: const InputDecoration(
                label: Text("Enter your password",
                    style: TextStyle(color: Color(0xFFCCCCCC))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        onPressed: () {
                          setState(() {
                            ProfilePictureSet = false;
                            EmailSet = false;
                          });
                        },
                        child: const Text("Back",
                            style: TextStyle(color: Color(0xFF181818)))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        onPressed: () {
                          setState(() {
                            Email = EmailController.text;
                            Password = PassController.text;
                            EmailSet = true;
                          });
                        },
                        child: const Text("Next",
                            style: TextStyle(color: Color(0xFF181818)))),
                  )
                ],
              ),
            )
          ],
        )
      );
    } else if (NameSet &&
        BirthdaySet &&
        GendersSet &&
        DescriptionSet &&
        ProfilePictureSet && EmailSet) {
      return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UserCard(User: User),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                    style: TextStyle(color: Color(0xFFCCCCCC)),
                    "This is you now, hope you're happy\nClick below to let others see you"),
                ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {
                      User.upload(ImageName, Email, Password);
                      Navigator.pop(context);
                    },
                    child: const Text("below",
                        style: TextStyle(color: Color(0xFFCCCCCC)))),
                ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      setState(() {
                        ProfilePictureSet = false;
                      });
                    },
                    child: const Text(
                        style: TextStyle(color: Color(0xFFCCCCCC)),
                        textAlign: TextAlign.center,
                        "WAIT NONONO THIS IS WRONG I HAVE\n VERY IMPORTANT CHANGES I MUST MAKE IMMEDIATELY OR ELSE\n THE WORLD SHALL END IN A FIREY PIT OF HELL")),
              ],
            ),
          ],
        ),
      );
    }


    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
            style: const TextStyle(color: Color(0xFFCCCCCC)),
            "Username set: ${NameSet.toString()}"),
        Text(
            style: const TextStyle(color: Color(0xFFCCCCCC)),
            "Birthday set: ${BirthdaySet.toString()}"),
        Text(
            style: const TextStyle(color: Color(0xFFCCCCCC)),
            "Genders set: ${GendersSet.toString()}"),
        Text(
            style: const TextStyle(color: Color(0xFFCCCCCC)),
            "Description set: ${DescriptionSet.toString()}"),
        Text(
            style: const TextStyle(color: Color(0xFFCCCCCC)),
            "Profile Picture set: ${ProfilePictureSet.toString()}"),
        Text(
            style: const TextStyle(color: Color(0xFFCCCCCC)),
            "Email set: ${EmailSet.toString()}"),
      ],
    ));
  }

  String getHello() {
    List<String> Hellos = List.empty(growable: true);
    Hellos.add("Ahh, youre finally awake");
    Hellos.add("print('Hello User')");
    Hellos.add("Obi-Wan: Hello There \nGeneral Grevious: Ahh General Kenobi");
    Hellos.add("Hey there stranger, what you doin round these parts?");
    Hellos.add("Whatcha doin?");
    Hellos.shuffle(Random(DateTime.now().weekday));
    return Hellos.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 800,
          child: getQuestion(),
        ),
      ),
    );
  }
}
