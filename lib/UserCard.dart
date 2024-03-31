import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:nerdi/UserData.dart';
import 'package:nerdi/UserDescPage.dart';
import 'package:nerdi/UserIcon.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserCard extends StatelessWidget {
  const UserCard({super.key, required this.User});

  final UserData User;

  Future<List<Widget>> getImages() async {
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
  }

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      color: const Color(0xFF080808),
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
                          enableInfiniteScroll: true,
                          showIndicator: true,
                          slideIndicator: CircularWaveSlideIndicator()),
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
                              builder: (context) => UserDescPage(User: User)));
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
