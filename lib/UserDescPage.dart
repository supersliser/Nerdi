import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nerdi/UserData.dart';

class UserDescPage extends StatelessWidget {
  UserDescPage({super.key, required this.User});
  final UserData User;

  @override
  Widget build(BuildContext context) {
    final Size appSize = MediaQuery.of(context).size;

    List<Widget> data = List.empty(growable: true);

    double width = appSize.width / (appSize.width / 300).floor();


    data.add(LargeUserIcon(ImageURL: User.ProfilePictureURL, Width: width));
    data.add(UserItem(Data: User.Gender, Width: width));
    data.add(UserItem(
        Data:
            "Age: ${User.getAge()}, Birthday in ${User.Birthday.difference(DateTime.now()).inDays} Days", Width: width));
    data.add(UserItem(Data: User.Description, Width: width));

    List<List<Widget>> Columns = List.empty(growable: true);

    for (int i = 0; i < (appSize.width / 300).floor(); i++) {
      Columns.add(List.empty(growable: true));
    }

    for (int i = 0; i < data.length; i++) {
      Columns[i % (appSize.width / 300).floor()].add(data[i]);
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text("Back"),
        backgroundColor: Color(0xEEC78FFF),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < Columns.length; i++)
                  SizedBox(
                    width: width,
                    child: Column(
                      children: Columns[i],
                    ),
                  ),
              ]),
        ),
      ),
    );
  }
}

class UserItem extends StatelessWidget {
  const UserItem({
    super.key,
    required this.Data,
    required this.Width,
  });

  final String Data;
  final double Width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Width,
      child: Card.filled(
        color: Color(0xFFC78FFF),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(child: Text(Data)),
        ),
      ),
    );
  }
}

class LargeUserIcon extends StatelessWidget {
  const LargeUserIcon({
    super.key,
    required this.ImageURL,
    required this.Width,
  });

  final String ImageURL;
  final double Width;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      clipBehavior: Clip.hardEdge,
      color: Color(0xFFC78FFF),
      child: FadeInImage.memoryNetwork(
        placeholder: kTransparentImage,
        image: ImageURL,
        width: Width,
        fit: BoxFit.cover,
      ),
    );
  }
}