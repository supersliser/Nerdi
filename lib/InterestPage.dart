import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nerdi/InterestData.dart';
import 'package:nerdi/UserCard.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:nerdi/UserData.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

class InterestPage extends StatelessWidget {
  const InterestPage({super.key, required this.interest});

  final Interest interest;
  final bool editMode = false;

  Future<List<Interest>> getChildrenInterests() async {
    List<Interest> output = List.empty(growable: true);

    final data = await Supabase.instance.client
        .from("InterestSubInterest")
        .select()
        .eq("InterestID", interest.ID);

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
        .eq("InterestID", interest.ID);

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
          ProfilePictureURL: await Supabase.instance.client.storage
              .from("ProfilePictures")
              .getPublicUrl(tempUser.first["ProfilePictureName"])));
    }
    return output;
  }

  @override
  Widget build(BuildContext context) {
    var appSize = MediaQuery.of(context).size;
    if (editMode) {
      return Scaffold(body: Form(child: Column()));
    } else {
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Back"),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            SizedBox(
              width: appSize.width,
              height: 100,
              child: FadeInImage.memoryNetwork(
                  fit: BoxFit.cover,
                  placeholder: kTransparentImage,
                  image: interest.ImageURL),
            ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Text(
                interest.Name,
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
                      Text(interest.Description,
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
                                      for (int i = 0; i < snapshop.data!.length; i++)
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        InterestPage(
                                                            interest: data[i])));
                                          },
                                          child: Card.outlined(
                                              color: Color(0xFFC78FFF),
                                              clipBehavior: Clip.antiAlias,
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 50,
                                                    child: FadeInImage.memoryNetwork(
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                        kTransparentImage,
                                                        image: data[i].ImageURL),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(
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
                    SizedBox(
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
                            return Center(child: CircularProgressIndicator());
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
      );
    }
  }
}
