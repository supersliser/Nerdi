import 'dart:ui';

import 'package:nerdi/UserData.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class Interest {
  Interest(
      {required this.ID,
      this.Name = "UNNAMED_INTEREST",
      this.Description = "NULL_DESCRIPTION",
      this.ImageName = "Placeholder",
      this.ImageURL =
          "https://t3.ftcdn.net/jpg/02/68/55/60/360_F_268556012_c1WBaKFN5rjRxR2eyV33znK4qnYeKZjm.jpg",
      required this.PrimaryColour});
  String ID;
  String Name;
  String Description;
  String ImageURL;
  String ImageName;
  Color PrimaryColour;

  String getImageUUID() {
    var UUIDgen = const Uuid();
    return UUIDgen.v4();
  }

  Future<String> uploadImage(XFile Image, String imageName) async {
    await Supabase.instance.client.storage
        .from('Interests')
        .upload('$imageName.${Image.path.split('.').last}', File(Image.path),
            fileOptions: FileOptions(
              contentType: 'image/${Image.path.split('.').last}',
              upsert: false,
            ));
    ImageURL = Supabase.instance.client.storage
        .from("Interests")
        .getPublicUrl('$imageName.${Image.path.split('.').last}');
    return '$imageName.${Image.path.split('.').last}';
  }

  Future<void> upload(List<Interest> parentInterests,
      List<Interest> childInterests, UserData currentUser) async {
    await Supabase.instance.client.from("Interest").upsert({
      "ID": ID,
      "Name": Name,
      "Description": Description,
      "ImageName": ImageName
    });
    await Supabase.instance.client
        .from("InterestSubInterest")
        .delete()
        .eq("InterestID", ID);
    await Supabase.instance.client
        .from("InterestSubInterest")
        .delete()
        .eq("SubInterestID", ID);
    for (var i in parentInterests) {
      await Supabase.instance.client
          .from("InterestSubInterest")
          .upsert({"InterestID": i.ID, "SubInterestID": ID});
    }
    for (var i in childInterests) {
      await Supabase.instance.client
          .from("InterestSubInterest")
          .upsert({"InterestID": ID, "SubInterestID": i.ID});
    }
    try {
      await Supabase.instance.client.from("UserInterest").upsert(
          {"UserID": currentUser.UUID, "InterestID": ID});
    } catch (temp) {}
  }
}
