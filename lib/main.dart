import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: Color(0xFF151515),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  Future<void> main() async {
    await Supabase.initialize(
      url: 'https://xyzcompany.supabase.co',
      anonKey: 'public-anon-key',
    );

    runApp(MyApp());
  }

// Get a reference your Supabase client
  final supabase = Supabase.instance.client;
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          return UserCard();
        },
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 500,
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
                  image:
                      "https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png",
                  width: 400,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Row(
                    children: [
                      Card.outlined(
                        clipBehavior: Clip.hardEdge,
                        color: Color(0xFFC78FFF),
                        child: FadeInImage.memoryNetwork(
                          placeholder: kTransparentImage,
                          image:
                              "https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png",
                          width: 50,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Username",
                          style: TextStyle(color: Color(0xFFCCCCCC)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
