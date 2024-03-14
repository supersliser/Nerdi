import 'dart:math';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:nerdi/UserData.dart';
import 'package:nerdi/UserData.dart';
import 'dart:math';

class NewUser extends StatefulWidget {
  const NewUser({super.key});

  @override
  State<NewUser> createState() => _NewUserState();
}

class _NewUserState extends State<NewUser> {
  final NameController = TextEditingController();
  final DescController = TextEditingController();
  var User = UserData(Birthday: DateTime.now());
  bool NameSet = false;
  bool BirthdaySet = false;
  bool GendersSet = false;
  bool DescriptionSet = false;
  @override
  void dispose() {
    NameController.dispose();
    DescController.dispose();
    super.dispose();
  }

  Widget getQuestion() {
    if (!NameSet) {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {
                      setState(() {
                        User.Username = NameController.text;
                        NameSet = true;
                      });
                    },
                    child: Text("Next",
                        style: TextStyle(color: Color(0xFF181818)))),
              )
            ],
          ),
        )
      ]);
    } else if (!BirthdaySet) {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text("Hi There ${User.Username}.\nWhen were you born?",
            style: const TextStyle(color: Color(0xFFCCCCCC))),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CalendarDatePicker2(
            config: CalendarDatePicker2Config(
              currentDate: User.Birthday,
                controlsTextStyle: TextStyle(
                  color: Color(0xFFCCCCCC),
                ),
                dayTextStyle: TextStyle(
                  color: Color(0xFFCCCCCC),
                ),
                weekdayLabelTextStyle: TextStyle(
                  color: Color(0xFFCCCCCC),
                ),
                yearTextStyle: TextStyle(
                  color: Color(0xFFCCCCCC),
                ),
                firstDate: DateTime(0000, 1, 1),
                lastDate: DateTime.now()),
            value: [DateTime.now()],
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
                    child: Text("Back",
                        style: TextStyle(color: Color(0xFF181818)))),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {
                      setState(() {
                        BirthdaySet = true;
                      });
                    },
                    child: Text("Next",
                        style: TextStyle(color: Color(0xFF181818)))),
              )
            ],
          ),
        )
      ]);
    } else if (!GendersSet) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("So ${User.Username}, you're ${User.getAge()} years old?",
              style: const TextStyle(color: Color(0xFFCCCCCC))),
          Text("Whats your gender",
              style: const TextStyle(color: Color(0xFFCCCCCC))),
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
          Text("And what genders are you looking for",
              style: const TextStyle(color: Color(0xFFCCCCCC))),
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
                          User.GendersLookingFor[GenderEnum.Female.index - 1] =
                              selected;
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
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        setState(() {
                          BirthdaySet = false;
                          GendersSet = false;
                        });
                      },
                      child: Text("Back",
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
                      child: Text("Next",
                          style: TextStyle(color: Color(0xFF181818)))),
                )
              ],
            ),
          )
        ],
      );
    } else if (!DescriptionSet) {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text("Hmm, sounds like fun.\nWhy dont you tell us some stuff about you?", style: const TextStyle(color: Color(0xFFCCCCCC))),
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
                    style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      setState(() {
                        GendersSet = false;
                        DescriptionSet = false;
                      });
                    },
                    child: Text("Back",
                        style: TextStyle(color: Color(0xFF181818)))),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {
                      setState(() {
                        User.Description = DescController.text;
                        DescriptionSet = true;
                      });
                    },
                    child: Text("Next",
                        style: TextStyle(color: Color(0xFF181818)))),
              )
            ],
          ),
        )
      ],);
    }

    return (const Text("Test"));
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
