import 'package:nerdi/InterestData.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum GenderEnum {
  Null,
  Male,
  Female,
  NonBinary,
}

class UserData {
  UserData(
      {this.UUID = "",
      this.Username = "UNNAMED_USER",
      required this.Birthday,
      this.Gender = 0,
      this.Description = "NONE",
      this.ProfilePictureURL =
          "https://www.svgrepo.com/show/508699/landscape-placeholder.svg",});

  String UUID;
  String Username;
  DateTime Birthday;
  int Gender;
  String Description;
  String ProfilePictureURL;
  List<bool> GendersLookingFor = List.filled(3, false);

  Future<List<bool>> getGendersLookingFor() async {
    final Genders = await Supabase.instance.client.from("UserLookingForGender").select().eq("User", UUID);

    for (int i = 0; i < Genders.length; i++) {
      GendersLookingFor[Genders[i]["GenderLookingFor"]] = true;
    }

    return GendersLookingFor;
  }

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
      if (tempInterest.first["ImageName"].toString().isNotEmpty) {
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
    return (DateTime.now().difference(Birthday).inDays / 365)
        .floor();
  }
}
