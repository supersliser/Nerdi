import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nerdi/UserData.dart';
import 'package:nerdi/UserDescPage.dart';
import 'package:nerdi/UserIcon.dart';
import 'package:transparent_image/transparent_image.dart';

class UserCard extends StatelessWidget {
  const UserCard({super.key, required this.User});

  final UserData User;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Card.outlined(
        color: const Color(0xFFC78FFF),
        child: Card.filled(
          color: const Color(0xFF151515),
          child: Column(
            children: [
              Card.outlined(
                color: const Color(0xFFC78FFF),
                clipBehavior: Clip.hardEdge,
                child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: User.ProfilePictureURL,
                  width: 300,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        CupertinoButton(
                          child: UserIcon(ImageURL: User.ProfilePictureURL),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        UserDescPage(User: User)));
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            User.Username,
                            style: const TextStyle(color: Color(0xFFCCCCCC)),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            GenderEnum.values[User.Gender].name,
                            style: const TextStyle(color: Color(0xFFCCCCCC)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            User.getAge().toString(),
                            style: const TextStyle(color: Color(0xFFCCCCCC)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
