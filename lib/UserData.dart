import 'package:nerdi/InterestData.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';

enum GenderEnum {
  Null,
  Male,
  Female,
  NonBinary,
}

class SecondaryPicture {
  SecondaryPicture(
      {required this.ID,
      required this.PictureName,
      required this.Order});
  String ID;
  String PictureName;
  int Order;
}

class UserData {
  UserData(
      {this.UUID = "",
      this.Username = "UNNAMED_USER",
      this.Birthday,
      this.Gender = 0,
      this.Description = "NONE",
      this.ProfilePictureURL =
          "https://t3.ftcdn.net/jpg/02/68/55/60/360_F_268556012_c1WBaKFN5rjRxR2eyV33znK4qnYeKZjm.jpg",
      this.ProfilePictureName = ""});

  String UUID;
  String Username;
  DateTime? Birthday;
  int Gender;
  String Description;
  String ProfilePictureURL;
  List<bool> GendersLookingFor = List.filled(3, false);
  String ProfilePictureName;

  Future<List<SecondaryPicture>> getSecondaryPictures() async {
    var temp = await Supabase.instance.client
        .from("SecondaryPictures")
        .select()
        .eq("UserID", UUID);
    List<SecondaryPicture> SecondaryPictures = List.empty(growable: true);
    for (int i = 0; i < temp.length; i++) {
      SecondaryPictures.add(SecondaryPicture(
          ID: temp[i]["PictureID"],
          PictureName: temp[i]["PictureName"],
          Order: temp[i]["Order"]));
    }
    return SecondaryPictures;
  }

  String getImageUUID() {
    var UUIDgen = const Uuid();
    return UUIDgen.v4();
  }

  Future<void> upload(String PPname, String? Email, String? Password) async {
    if (ProfilePictureURL.isEmpty) {
      PPname = ProfilePictureURL;
    }
    if (Email != Null && Password != Null) {
      var temp = await Supabase.instance.client.auth
          .signUp(email: Email!, password: Password!);
      UUID = temp.user!.id;
    }
    await Supabase.instance.client.from("UserInfo").upsert({
      "UserUID": UUID,
      "Username": Username,
      "Birthday": Birthday.toString(),
      "Description": Description,
      "ProfilePictureName": PPname,
      "Gender": Gender
    });
    for (int i = 0; i < GendersLookingFor.length; i++) {
      if (GendersLookingFor[i]) {
        await Supabase.instance.client
            .from("UserLookingForGender")
            .upsert({"User": UUID, "GenderLookingFor": i});
      }
    }
  }

  Future<String> uploadImage(XFile Image, String imageName) async {
    await Supabase.instance.client.storage
        .from('ProfilePictures')
        .upload('$imageName.${Image.path.split('.').last}', File(Image.path),
            fileOptions: FileOptions(
              contentType: 'image/${Image.path.split('.').last}',
              upsert: false,
            ));
    ProfilePictureURL = Supabase.instance.client.storage
        .from("ProfilePictures")
        .getPublicUrl('$imageName.${Image.path.split('.').last}');
    return '$imageName.${Image.path.split('.').last}';
  }

  Future<List<bool>> getGendersLookingFor() async {
    final Genders = await Supabase.instance.client
        .from("UserLookingForGender")
        .select()
        .eq("User", UUID);

    for (int i = 0; i < Genders.length; i++) {
      GendersLookingFor[Genders[i]["GenderLookingFor"]] = true;
    }

    return GendersLookingFor;
  }

  Future<List<Interest>> getInterests() async {
    List<Interest> output = List.empty(growable: true);
    final UserInterests = await Supabase.instance.client
        .from("UserInterest")
        .select("InterestID")
        .eq("UserID", UUID);

    final images = Supabase.instance.client.storage.from("Interests");

    for (int i = 0; i < UserInterests.length; i++) {
      var tempInterest = await Supabase.instance.client
          .from("Interest")
          .select()
          .eq("ID", UserInterests[i]["InterestID"]);
      output.add(Interest(
          ID: tempInterest.first["ID"],
          Name: tempInterest.first["Name"],
          Description: tempInterest.first["Description"],
          ImageName: tempInterest.first["ImageName"],
          ImageURL: images.getPublicUrl(tempInterest.first["ImageName"]),
          PrimaryColour: Color.fromARGB(
              0xFF,
              tempInterest.first["PrimaryColourRed"],
              tempInterest.first["PrimaryColourGreen"],
              tempInterest.first["PrimaryColourBlue"])));
    }
    return output;
  }

  int getAge() {
    return (DateTime.now().difference(Birthday!).inDays / 365).floor();
  }
}
