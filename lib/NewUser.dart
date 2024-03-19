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
    String imageName = User.getImageUUID();
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      var temp = await User.uploadImage(image, imageName);
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
            scribbleEnabled: false,
            onSubmitted: (text) {
              setState(() {
                if (NameController.text.isEmpty) {
                  NameSet = false;
                } else {
                  User.Username = NameController.text;
                  NameSet = true;
                }
              });
            },
            onChanged: (text) {
              setState(() {});
            },
            controller: NameController,
            style: const TextStyle(color: Color(0xFFCCCCCC)),
            decoration: InputDecoration(
              focusColor: Colors.green,
              error: NameController.text.isEmpty
                  ? const Text("Cmon, you gotta give me something",
                      style: TextStyle(color: Color(0xFFCCCCCC)))
                  : null,
              label: const Text("Enter your name",
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
                          if (NameController.text.isEmpty) {
                            NameSet = false;
                          } else {
                            User.Username = NameController.text;
                            NameSet = true;
                          }
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
                lastMonthIcon: const Icon(Icons.arrow_circle_left_outlined, color: Colors.white),
                  nextMonthIcon: const Icon(Icons.arrow_circle_right_outlined, color: Colors.white),

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
                        backgroundColor: const Color(0xFFFF82FF),
                        selectedColor: const Color(0xFFFF82FF),
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
                        backgroundColor: const Color(0xFFFFEF63),
                        selectedColor: const Color(0xFFFFEF63),
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
                        backgroundColor: const Color(0xFF63EDFF),
                        selectedColor: const Color(0xFF63EDFF),
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
                        backgroundColor: const Color(0xFFFF82FF),
                        selectedColor: const Color(0xFFFF82FF),
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
                        backgroundColor: const Color(0xFFFFEF63),
                        selectedColor: const Color(0xFFFFEF63),
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
                        backgroundColor: const Color(0xFF63EDFF),
                        selectedColor: const Color(0xFF63EDFF),
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
                            if (User.Gender != 0 &&
                                User.GendersLookingFor.contains(true)) {
                              GendersSet = true;
                            }
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
                  if (DescController.text.isEmpty) {
                    DescriptionSet = false;
                  } else {
                    User.Description = DescController.text;
                    DescriptionSet = true;
                  }
                });
              },
              onChanged: (text) {
                setState(() {});
              },
              controller: DescController,
              style: const TextStyle(color: Color(0xFFCCCCCC)),
              decoration: InputDecoration(
                error: DescController.text.isEmpty ? const Text("Bro I promise you're not that boring",
                    style: TextStyle(color: Color(0xFFCCCCCC))) : null,
                label: const Text("Enter some stuff about you",
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
                            if (DescController.text.isEmpty) {
                              DescriptionSet = false;
                            } else {
                              User.Description = DescController.text;
                              DescriptionSet = true;
                            }
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
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
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
                    if (EmailController.text.isNotEmpty) {
                      Email = EmailController.text;
                    }
                  });
                },
                onChanged: (text) {
                  setState(() {});
                },
                controller: EmailController,
                style: const TextStyle(color: Color(0xFFCCCCCC)),
                decoration: InputDecoration(
                  error: EmailController.text.isEmpty ? const Text("like at least give us something plz",
                      style: TextStyle(color: Color(0xFFCCCCCC))) : null,
                  label: const Text("Enter your email",
                      style: TextStyle(color: Color(0xFFCCCCCC))),
                ),
              ),
              TextField(
                obscureText: true,
                onSubmitted: (text) {
                  setState(() {
                    if (PassController.text.isNotEmpty) {
                      Password = PassController.text;
                    }
                  });
                },
                onChanged: (text) {
                  setState(() {});
                },
                controller: PassController,
                style: const TextStyle(color: Color(0xFFCCCCCC)),
                decoration: InputDecoration(
                  error: PassController.text.isEmpty ? const Text("*closes eyes* i promise im not peeking",
                      style: TextStyle(color: Color(0xFFCCCCCC))) : null,
                  label: const Text("Enter your password",
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
                              if (EmailController.text.isEmpty || PassController.text.isEmpty) {
                                EmailSet = false;
                              } else {
                                Email = EmailController.text;
                                Password = PassController.text;
                                EmailSet = true;
                              }
                            });
                          },
                          child: const Text("Next",
                              style: TextStyle(color: Color(0xFF181818)))),
                    )
                  ],
                ),
              )
            ],
          ));
    } else if (NameSet &&
        BirthdaySet &&
        GendersSet &&
        DescriptionSet &&
        ProfilePictureSet &&
        EmailSet) {
      return Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            UserCard(User: User),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                    style: TextStyle(color: Color(0xFFCCCCCC)),
                    "This is you now, hope you're happy\nClick below to let others see you"),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () {
                        User.upload(ImageName, Email, Password);
                        Navigator.pop(context);
                      },
                      child: const Text("below",
                          style: TextStyle(color: Color(0xFFCCCCCC)))),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
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
                ),
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
