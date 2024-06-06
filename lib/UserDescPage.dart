import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:nerdi/InterestData.dart';
import 'package:nerdi/NavBar.dart';
import 'package:nerdi/PostData.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:nerdi/UserData.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

class UserDescPage extends StatelessWidget {
  const UserDescPage({super.key, required this.User});
  final UserData User;

  Future<List<Widget>> generateTiles(UserData User, double width) async {
    final List<Widget> Output = List.empty(growable: true);

    final List<Interest> Interests = await User.getInterests();

    final List<PostData> Posts = await PostData.getPostsForAuthor(User);

    final List<SecondaryPicture> Images = await User.getSecondaryPictures();

    for (int i = 0; i < Images.length; i++) {
      Output.add(LargeUserIcon(ImageURL: Supabase.instance.client.storage.from("ProfilePictures").getPublicUrl(Images[i].PictureName), Width: width));
    }

    Output.add(LargeUserIcon(ImageURL: User.ProfilePictureURL, Width: width));
    Output.add(UserItem(Data: GenderEnum.values[User.Gender].name, Width: width));
    Output.add(UserItem(
        Data:
            "Age: ${User.getAge()}, Birthday in ${User.Birthday!.copyWith(year: User.Birthday!.copyWith(year: DateTime.now().year).difference(DateTime.now()).inDays >= 0 ? DateTime.now().year : DateTime.now().year + 1).difference(DateTime.now()).inDays} Days",
        Width: width));
    Output.add(UserItem(Data: User.Description, Width: width));
    for (int i = 0; i < Posts.length; i++) {
      Output.add(PostItem(Post: Posts[i], Width: width));
    }
    for (int i = 0; i < Interests.length; i++) {
      Output.add(InterestViewer(interest: Interests[i], title: "${User.Username} has an interest in ${Interests[i].Name}", Width: width));
    }
    Output.shuffle(Random(DateTime.now().hour));
    return Output;
  }

  @override
  Widget build(BuildContext context) {
    final Size appSize = MediaQuery.of(context).size;

    double width = appSize.width / (appSize.width / 300).floor();

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context);
          },
          backgroundColor: const Color(0xEEC78FFF),
          child: const Text("Back"),
        ),
        body: Row(children: [
          const NavBar(
            CurrentIndex: 0,
          ),
          Expanded(
            child: ListView(children: [
              FutureBuilder<List<Widget>>(
                  future: generateTiles(User, width),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final data = snapshot.data!;
                    return (StaggeredGrid.count(crossAxisCount: (appSize.width / 300).floor(), children: data));
                  })
            ]),
          ),
        ]));
  }
}

class PostItem extends StatelessWidget {
  const PostItem({
    super.key,
    required this.Post,
    required this.Width,
});

  final PostData Post;
  final double Width;

  @override
  Widget build(BuildContext context) {

    List<Widget> Images = List.empty(growable: true);

    for (var i in Post.ImageURLs) {
      Images.add( FadeInImage.memoryNetwork(
          placeholder: kTransparentImage,
          image: i,
          width: Width,
          fit: BoxFit.fitWidth,
        ),
      );
    }

    return SizedBox(
      width: Width,
      child: Card.filled(
        color: Colors.lightBlueAccent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(child: Text(Post.Message)),
            ),
            Post.ImageNames.isNotEmpty ? Card.outlined(clipBehavior: Clip.hardEdge, color: Colors.white, child: SizedBox(width: Width, child: ExpandableCarousel(items: Images, options: CarouselOptions(enableInfiniteScroll: false, showIndicator: true, slideIndicator: const CircularSlideIndicator())))): const Padding(padding: EdgeInsets.zero),
            Text("${Post.PostedAt.day}/${Post.PostedAt.month}/${Post.PostedAt.year} ${Post.PostedAt.hour}:${Post.PostedAt.minute}", style: const TextStyle(fontSize: 10,color: Color.fromARGB(64, 0, 0, 0)),),
          ],
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
        color: const Color(0xFFC78FFF),
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
      color: const Color(0xFFC78FFF),
      child: FadeInImage.memoryNetwork(
        placeholder: kTransparentImage,
        image: ImageURL,
        width: Width - 10,
        fit: BoxFit.cover,
      ),
    );
  }
}
