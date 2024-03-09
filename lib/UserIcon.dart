import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nerdi/UserData.dart';


class UserIcon extends StatelessWidget {
  const UserIcon({
    super.key,
    required this.ImageURL,
  });

  final String ImageURL;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      clipBehavior: Clip.hardEdge,
      color: Color(0xFFC78FFF),
      child: FadeInImage.memoryNetwork(
        placeholder: kTransparentImage,
        image: ImageURL,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      ),
    );
  }
}