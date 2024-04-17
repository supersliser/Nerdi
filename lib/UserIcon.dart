import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class UserIcon extends StatelessWidget {
  const UserIcon({
    super.key,
    required this.ImageURL,
    this.size = 50,
  });

  final String ImageURL;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      clipBehavior: Clip.hardEdge,
      color: const Color(0xFFC78FFF),
      child: FadeInImage.memoryNetwork(
        placeholder: kTransparentImage,
        image: ImageURL,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
