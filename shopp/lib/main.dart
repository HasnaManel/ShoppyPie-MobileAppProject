import 'package:flutter/material.dart';
import 'bookStore.dart';
import 'musicStore.dart';
import 'movieStore.dart';
import 'stationaryStore.dart';
import 'shoesStore.dart';
import 'signIn.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userIdProvider = StateProvider<int?>((ref) => null);

void main() {
  runApp(ProviderScope(
    child: MaterialApp(
      title: 'MyStore ',
      initialRoute: '/',
      routes: {
        '/': (context) => const SignInScreen(),
      },
    ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(
        title: ('Shoppinng ....'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 225, 203, 229),
        title: Text(widget.title),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SignInScreen(),
                ),
              );
            },
            child: Text("Login"),
          ),
          SizedBox(width: 30)
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 20),
        child: (GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          childAspectRatio: 2,
          padding: EdgeInsets.all(3),
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MusicStore()),
                );
              },
              child: Card(
                color: Colors.pink[200],
                //  child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Music Store", style: TextStyle(fontSize: 18)),
                    SizedBox(width: 10),
                    Icon(Icons.music_note),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BookStore()),
                );
              },
              child: Card(
                color: Colors.purple[200],
                //  child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Book Store", style: TextStyle(fontSize: 18)),
                    SizedBox(width: 10),
                    Icon(Icons.history_edu_sharp),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MovieStore()),
                );
              },
              child: Card(
                color: Colors.brown[200],
                //  child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Movie Store", style: TextStyle(fontSize: 18)),
                    SizedBox(width: 10),
                    Icon(Icons.video_camera_back_outlined),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StationaryStore()),
                );
              },
              child: Card(
                color: Colors.green[200],
                //  child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Stationary Store", style: TextStyle(fontSize: 18)),
                    SizedBox(width: 10),
                    Icon(Icons.school),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ShoesStore()),
                );
              },
              child: Card(
                color: Colors.blue[200],
                //  child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Shoes Store", style: TextStyle(fontSize: 18)),
                    SizedBox(width: 10),
                    Icon(Icons.sports_handball_sharp),
                  ],
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
