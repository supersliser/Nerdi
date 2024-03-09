import 'package:flutter/material.dart';
import 'package:nerdi/UserData.dart';
import 'package:nerdi/UserIcon.dart';
import 'package:transparent_image/transparent_image.dart';

class UserCard extends StatelessWidget {
  UserCard({super.key, required this.User});

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
                  image: this.User.ProfilePictureURL,
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
                        UserIcon(ImageURL: User.ProfilePictureURL),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            this.User.Username,
                            style: TextStyle(color: Color(0xFFCCCCCC)),
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
                            this.User.Gender,
                            style: TextStyle(color: Color(0xFFCCCCCC)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            this.User.getAge().toString(),
                            style: TextStyle(color: Color(0xFFCCCCCC)),
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
