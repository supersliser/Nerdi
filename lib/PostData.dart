import 'dart:ui';

import 'package:nerdi/InterestData.dart';
import 'package:nerdi/UserData.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostData {
  PostData(
      {required this.ID,
      required this.PostedAt,
      required this.Message,
      required this.Author,
      required this.Interests,
      required this.ImageNames,
      required this.ImageURLs});

  String ID;
  DateTime PostedAt;
  String Message;
  UserData Author;
  List<Interest> Interests;
  List<String> ImageNames;
  List<String> ImageURLs;

  static Future<List<PostData>> getPostsForAuthor(UserData Author) async {
    var data = await Supabase.instance.client.from("Posts").select("*").eq("Author", Author.UUID).order("PostedAt", ascending: false);
    List<PostData> output = List<PostData>.empty(growable: true);

    for (var i in data) {
      var interests = List<Interest>.empty(growable: true);
      var images = List<String>.empty(growable: true);
      var urls = List<String>.empty(growable: true);

      var interestData = await Supabase.instance.client.from("PostInterest").select("*").eq("PostID", i["ID"]);
      for (var k in interestData) {
        var temp = await Supabase.instance.client.from("Interest").select("*").eq("ID", k["InterestID"]);
        for (var j in temp) {
          interests.add(Interest(
              ID: j["ID"],
              Name: j["Name"],
              ImageName: j["ImageName"],
              ImageURL: Supabase.instance.client.storage.from("PostImages").getPublicUrl(j["ImageName"]),
              Description: j["Description"],
              PrimaryColour: Color.fromARGB(255, j["PrimaryColourRed"], j["PrimaryColourGreen"], j["PrimaryColourBlue"])));
        }
      }

      var imageData = await Supabase.instance.client.from("PostImages").select("*").eq("PostID", i["ID"]);
      for (var j in imageData) {
        images.add(j["ImageName"]);
        urls.add(Supabase.instance.client.storage.from("PostImages").getPublicUrl(j["ImageName"]));
      }

      output.add(
          PostData(ID: i["ID"], PostedAt: DateTime.parse(i["PostedAt"]), Message: i["Message"], Author: Author, Interests: interests.toList(), ImageNames: images.toList(), ImageURLs: urls.toList()));
    }

    return output;
  }

  static Future<List<PostData>> getPostsForInterest(String InterestID) async {
    var postInterests = await Supabase.instance.client.from("PostInterest").select("*").eq("InterestID", InterestID);
    var output = List<PostData>.empty(growable: true);

    for (var i in postInterests) {
      var postData = await Supabase.instance.client.from("Posts").select("*").eq("ID", i["PostID"]);

      var interests = List<Interest>.empty(growable: true);
      var images = List<String>.empty(growable: true);
      var urls = List<String>.empty(growable: true);

      var interestData = await Supabase.instance.client.from("PostInterest").select("*").eq("PostID", postData.first["ID"]);
      for (var k in interestData) {
        var temp = await Supabase.instance.client.from("Interest").select("*").eq("ID", k["InterestID"]);
        interests.add(Interest(
            ID: temp.first["ID"],
            Name: temp.first["Name"],
            ImageName: temp.first["ImageName"],
            ImageURL: Supabase.instance.client.storage.from("PostImages").getPublicUrl(temp.first["ImageName"]),
            Description: temp.first["Description"],
            PrimaryColour: Color.fromARGB(255, temp.first["PrimaryColourRed"], temp.first["PrimaryColourGreen"], temp.first["PrimaryColourBlue"])));
      }

      var imageData = await Supabase.instance.client.from("PostImages").select("*").eq("PostID", postData.first["ID"]);
      for (var j in imageData) {
        images.add(j["ImageName"]);
        urls.add(Supabase.instance.client.storage.from("PostImages").getPublicUrl(j["ImageName"]));
      }

      var authorData = await Supabase.instance.client.from("UserInfo").select("*").eq("ID", postData.first["Author"]);

      var author = UserData(
          UUID: authorData.first["ID"],
          Username: authorData.first["Username"],
          Description: authorData.first["Description"],
          Birthday: authorData.first["Birthday"],
          Gender: authorData.first["Gender"],
          ProfilePictureName: authorData.first["ProfilePictureName"],
          ProfilePictureURL: Supabase.instance.client.storage.from("ProfilePictures").getPublicUrl(authorData.first["ProfilePictureName"]));

      output.add(PostData(
          ID: postData.first["ID"],
          PostedAt: postData.first["PostedAt"],
          Message: postData.first["Message"],
          Author: author,
          Interests: interests,
          ImageNames: images,
          ImageURLs: urls));
    }
    output.sort((a, b) => a.PostedAt.compareTo(b.PostedAt));
    return output;
  }
}
