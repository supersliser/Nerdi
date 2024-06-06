import 'package:nerdi/UserData.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:nerdi/InterestPage.dart';

class SmallInterestViewer extends StatelessWidget {
  const SmallInterestViewer({super.key, required this.interest});
  final Interest interest;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 50,
      child: TextButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => InterestPage(
                        interest: interest,
                      )));
        },
        child: Card.filled(
          color: interest.PrimaryColour,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Card.outlined(
                clipBehavior: Clip.hardEdge,
                child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: interest.ImageURL,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    interest.Name,
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InterestViewer extends StatelessWidget {
  const InterestViewer({super.key, required this.interest, this.title, required this.Width});
  final Interest interest;
  final String? title;
  final double Width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => InterestPage(interest: interest)));
      },
      child: SizedBox(
        width: Width,
        child: Card.filled(
          clipBehavior: Clip.antiAlias,
          color: interest.PrimaryColour,
          child: Column(
            children: [
              interest.ImageName == "Placeholder.svg"
                  ? const Padding(
                      padding: EdgeInsets.all(0),
                    )
                  : FadeInImage.memoryNetwork(placeholder: kTransparentImage, image: interest.ImageURL, width: Width, fit: BoxFit.cover),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                    child: Column(
                  children: [
                    Text(
                      title == null ? interest.Name : title!,
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text(interest.Description)
                  ],
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Interest {
  Interest(
      {required this.ID,
      this.Name = "UNNAMED_INTEREST",
      this.Description = "NULL_DESCRIPTION",
      this.ImageName = "Placeholder",
      this.ImageURL = "https://t3.ftcdn.net/jpg/02/68/55/60/360_F_268556012_c1WBaKFN5rjRxR2eyV33znK4qnYeKZjm.jpg",
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
    await Supabase.instance.client.storage.from('Interests').upload('$imageName.${Image.path.split('.').last}', File(Image.path),
        fileOptions: FileOptions(
          contentType: 'image/${Image.path.split('.').last}',
          upsert: false,
        ));
    ImageName = '$imageName.${Image.path.split('.').last}';
    ImageURL = Supabase.instance.client.storage.from("Interests").getPublicUrl('$imageName.${Image.path.split('.').last}');
    return ImageURL;
  }

  Future<void> upload(List<Interest> parentInterests, List<Interest> childInterests, UserData currentUser) async {
    await Supabase.instance.client.from("Interest").upsert({
      "ID": ID,
      "Name": Name,
      "Description": Description,
      "ImageName": ImageName,
      "PrimaryColourRed": PrimaryColour.red,
      "PrimaryColourGreen": PrimaryColour.green,
      "PrimaryColourBlue": PrimaryColour.blue
    });
    await Supabase.instance.client.from("InterestSubInterest").delete().eq("InterestID", ID);
    await Supabase.instance.client.from("InterestSubInterest").delete().eq("SubInterestID", ID);
    for (var i in parentInterests) {
      await Supabase.instance.client.from("InterestSubInterest").upsert({"InterestID": i.ID, "SubInterestID": ID});
    }
    for (var i in childInterests) {
      await Supabase.instance.client.from("InterestSubInterest").upsert({"InterestID": ID, "SubInterestID": i.ID});
    }
  }
}
