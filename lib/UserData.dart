import 'package:nerdi/InterestData.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserData {
  UserData(
      {required this.UUID,
      this.Username = "UNNAMED_USER",
      required this.Birthday,
      this.Gender = "UNKNOWN",
      this.Description = "NONE",
      this.ProfilePictureURL =
          "https://www.svgrepo.com/show/508699/landscape-placeholder.svg",
      this.InterestCount = 0});

  final String UUID;
  final String Username;
  final DateTime Birthday;
  final String Gender;
  final String Description;
  final String ProfilePictureURL;
  final int InterestCount;

  Future<List<Interest>> getInterests() async {
    List<Interest> Interests = List.empty(growable: true);
    final UserInterests = await Supabase.instance.client
        .from("UserInterest")
        .select("InterestID")
        .eq("UserID", UUID);

    final images = Supabase.instance.client.storage.from("Interests");

    for (int i = 0; i < UserInterests.length; i++) {
      final tempInterest = await Supabase.instance.client
          .from("Interest")
          .select()
          .eq("ID", UserInterests[i]["InterestID"]);
      if (!tempInterest.first["ImageName"].toString().isEmpty) {
        Interests.add(Interest(
            ID: tempInterest.first["ID"],
            Name: tempInterest.first["Name"],
            Description: tempInterest.first["Description"],
            ImageURL: images.getPublicUrl(tempInterest.first["ImageName"])));
      } else {
        Interests.add(Interest(
          ID: tempInterest.first["ID"],
          Name: tempInterest.first["Name"],
          Description: tempInterest.first["Description"],
        ));
      }
    }
    return Interests;
  }

  Future<Interest> getInterest(int index) async {
    var userInterests = await Supabase.instance.client
        .from('UserInterest')
        .select()
        .eq("UserID", UUID)
        .range(index, index);

    var images = Supabase.instance.client.storage.from("Interests");

    var tempInterest = await Supabase.instance.client
        .from("Interest")
        .select("ID, Name, Description, ImageName")
        .eq("ID", userInterests.first["InterestID"]);
    return Interest(
      ID: tempInterest.first["ID"],
      Name: tempInterest.first["Name"],
      Description: tempInterest.first["Description"],
      // ImageURL: images.getPublicUrl(tempInterest.first["ImageName"]),
    );
  }

  int getAge() {
    return (DateTime.now().difference(this.Birthday).inDays / 365).floor();
  }
}
