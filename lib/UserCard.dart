import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:nerdi/UserData.dart';
import 'package:nerdi/UserDescPage.dart';
import 'package:nerdi/UserIcon.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserCard extends StatefulWidget {
  const UserCard({super.key, required this.User});

  final UserData User;

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  Future<List<Widget>> getImages() async {
    var temp = await widget.User.getSecondaryPictures();
    List<Widget> output = List.empty(growable: true);
    var images = Supabase.instance.client.storage.from("SecondaryPictures");
    output.add(Card.outlined(
        color: const Color(0xFFC78FFF),
        clipBehavior: Clip.hardEdge,
        child: FadeInImage.memoryNetwork(
          placeholder: kTransparentImage,
          image: widget.User.ProfilePictureURL,
          width: 300,
          fit: BoxFit.cover,
        )));
    for (int i = 0; i < temp.length; i++) {
      output.add(Card.outlined(
          color: const Color(0xFFC78FFF),
          clipBehavior: Clip.hardEdge,
          child: FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            image: images.getPublicUrl(temp[i].PictureName),
            width: 300,
            fit: BoxFit.cover,
          )));
    }
    return output;
  }

  bool liked = false;
  bool disliked = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (details) {
        if (details.localPosition.dx >= 200) {
          Supabase.instance.client.from("Likes").insert({
            "LikerID" : Supabase.instance.client.auth.currentUser!.id,
            "LikedID" : widget.User.UUID,
            "Liked" : 1
          });
          setState(() {
            liked = !liked;
          });
        } else {
          Supabase.instance.client.from("Likes").insert({
            "LikerID" : Supabase.instance.client.auth.currentUser!.id,
            "LikedID" : widget.User.UUID,
            "Liked" : -1
          });
          setState(() {
            disliked = !disliked;
          });
        }
      },
      child: Card.filled(
        color: liked
            ? Colors.green
            : disliked
                ? Colors.red
                : Color(0xFF080808),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              FutureBuilder(
                  future: getImages(),
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return const CircularProgressIndicator();
                    }
                    return ExpandableCarousel(
                        options: CarouselOptions(
                            enableInfiniteScroll: false,
                            showIndicator: true,
                            slideIndicator: CircularSlideIndicator()),
                        items: snapshot.data);
                  }),
              const Padding(
                padding: EdgeInsets.all(8.0),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    UserDescPage(User: widget.User)));
                      },
                      icon: UserIcon(ImageURL: widget.User.ProfilePictureURL)),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      widget.User.Username,
                      style: const TextStyle(color: Color(0xFFCCCCCC)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Card.filled(
                      color: widget.User.Gender == 1
                          ? Colors.lightBlue
                          : widget.User.Gender == 2
                              ? Colors.yellow
                              : Colors.pinkAccent,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          GenderEnum.values[widget.User.Gender].name,
                          style: const TextStyle(color: Color(0xFF161616)),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      widget.User.getAge().toString(),
                      style: const TextStyle(color: Color(0xFFCCCCCC)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
