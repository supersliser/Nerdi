import 'package:flutter/material.dart';
import 'package:nerdi/InterestData.dart';
import 'package:nerdi/NavBar.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InterestDiscoveryPage extends StatelessWidget {
  const InterestDiscoveryPage({super.key});

  Future<List<Interest>> getInterests() async {
    var tempInterestIDs = await Supabase.instance.client.from("UserInterest").select().eq("UserID", Supabase.instance.client.auth.currentUser!.id);
    var Interests = await Supabase.instance.client.from("Interest").select();

    Interests.removeWhere((element) {
      for (var i in tempInterestIDs) {
        if (i["InterestID"] == element["ID"]) {
          return true;
        }
      }
      return false;
    });

    var images = Supabase.instance.client.storage.from("Interests");

    return List.generate(Interests.length, (index) {
      return Interest(
          ID: Interests[index]["ID"],
          Name: Interests[index]["Name"],
          Description: Interests[index]["Description"],
          ImageName: Interests[index]["ImageName"],
          ImageURL: images.getPublicUrl(Interests[index]["ImageName"]),
          PrimaryColour: Color.fromARGB(0xFF, Interests[index]["PrimaryColourRed"], Interests[index]["PrimaryColourGreen"], Interests[index]["PrimaryColourBlue"]));
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size appSize = MediaQuery.of(context).size;
    double width = appSize.width / (appSize.width / 300).floor();

    return Scaffold(
        body: Row(children: [
      const NavBar(
        CurrentIndex: 1,
      ),
      Expanded(
        child: ListView(children: [
          FutureBuilder(
              future: getInterests(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snapshot.data!;
                return (StaggeredGrid.count(crossAxisCount: (appSize.width / 300).floor(), children: [for (int i = 0; i < data.length; i++) InterestViewer(interest: data[i], Width: width)]));
              })
        ]),
      )
    ]));
  }
}
