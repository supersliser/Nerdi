import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:nerdi/UserData.dart';
import 'package:nerdi/UserDescPage.dart';
import 'package:nerdi/UserIcon.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class nonInteractiveUserCard extends StatelessWidget {
  nonInteractiveUserCard({super.key, required this.User, required this.hasSecondaryPictures, this.liked});

  bool? liked;

  final UserData User;
  final bool hasSecondaryPictures;

  Future<List<Widget>> getImages() async {
    if (hasSecondaryPictures) {
      var temp = await User.getSecondaryPictures();
      List<Widget> output = List.empty(growable: true);
      var images = Supabase.instance.client.storage.from("SecondaryPictures");
      output.add(Card.outlined(
          color: const Color(0xFFC78FFF),
          clipBehavior: Clip.hardEdge,
          child: FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            image: User.ProfilePictureURL,
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
    } else {
      List<Widget> output = List.empty(growable: true);
      output.add(Card.outlined(
          color: const Color(0xFFC78FFF),
          clipBehavior: Clip.hardEdge,
          child: FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            image: User.ProfilePictureURL,
            width: 300,
            fit: BoxFit.cover,
          )));
      return output;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      color: liked == null
          ? const Color(0xFF080808)
          : liked == true
              ? Colors.green
              : Colors.red,
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
                  return CarouselSlider(options: CarouselOptions(enableInfiniteScroll: false), items: snapshot.data);
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => UserDescPage(User: User)));
                    },
                    icon: UserIcon(ImageURL: User.ProfilePictureURL)),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    User.Username,
                    style: const TextStyle(color: Color(0xFFCCCCCC)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Card.filled(
                    color: User.Gender == 1
                        ? Colors.lightBlue
                        : User.Gender == 2
                            ? Colors.yellow
                            : Colors.pinkAccent,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(
                        GenderEnum.values[User.Gender].name,
                        style: const TextStyle(color: Color(0xFF161616)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
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
    );
  }
}

class SmallUserCard extends StatelessWidget {
  const SmallUserCard({super.key, required this.User});

  final UserData User;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 50,
      child: TextButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => UserDescPage(User: User)));
        },
        child: Card.filled(
          color: Colors.black,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              UserIcon(ImageURL: User.ProfilePictureURL),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  User.Username,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserCard extends StatefulWidget {
  const UserCard({super.key, required this.User, required this.parentSetState});

  final UserData User;
  final parentSetState;

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

  Widget dislikeButton() {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        icon: const Icon(
          Icons.thumb_down,
          color: Colors.red,
        ),
        style: TextButton.styleFrom(backgroundColor: Colors.black),
        onPressed: () async {
          await Supabase.instance.client.from("Likes").insert({"LikerID": Supabase.instance.client.auth.currentUser!.id, "LikedID": widget.User.UUID, "Liked": -1});
          setState(() {
            disliked = !disliked;
          });
          widget.parentSetState(() {});
        },
      ),
    );
  }

  Widget likeButton() {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        icon: const Icon(
          Icons.thumb_up,
          color: Colors.green,
        ),
        style: TextButton.styleFrom(backgroundColor: Colors.black),
        onPressed: () async {
          if ((await Supabase.instance.client.from("Likes").select().eq("LikerID", widget.User.UUID).eq("LikedID", Supabase.instance.client.auth.currentUser!.id).eq("Liked", 1)).isEmpty) {
            await Supabase.instance.client.from("Likes").insert({"LikerID": Supabase.instance.client.auth.currentUser!.id, "LikedID": widget.User.UUID, "Liked": 1});
          } else {
            await Supabase.instance.client.from("Likes").update({
              "Liked": 2,
            }).match({
              "LikedID": Supabase.instance.client.auth.currentUser!.id,
              "LikerID": widget.User.UUID,
            });
            await Supabase.instance.client.from("Likes").insert({"LikerID": Supabase.instance.client.auth.currentUser!.id, "LikedID": widget.User.UUID, "Liked": 2});
          }
          setState(() {
            liked = !liked;
          });
          widget.parentSetState(() {});
        },
      ),
    );
  }

  bool liked = false;
  bool disliked = false;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Row(
          children: [
            const Padding(padding: EdgeInsets.only(left: 10)),
            SizedBox(
              width: width <= 500 ? width - 170 : 300,
              height: 450,
              child: Card.filled(
                color: const Color(0xFF080808),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FutureBuilder(
                          future: getImages(),
                          builder: (context, snapshot) {
                            if (snapshot.data == null) {
                              return const CircularProgressIndicator();
                            }
                            return CarouselSlider(options: CarouselOptions(enableInfiniteScroll: false), items: snapshot.data);
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
                                Navigator.push(context, MaterialPageRoute(builder: (context) => UserDescPage(User: widget.User)));
                              },
                              icon: UserIcon(
                                ImageURL: widget.User.ProfilePictureURL,
                                size: MediaQuery.of(context).size.width <= 300 ? 30 : 50,
                              )),
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
            ),
          ],
        ),
        Row(
          children: [
            dislikeButton(),
            Padding(padding: EdgeInsets.only(left: width <= 500 ? width - 230 : 240, top: 450)),
            likeButton(),
          ],
        )
      ],
    );
  }
}
