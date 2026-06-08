import 'package:flutter/material.dart';
import 'album_data.dart';
import 'cart.dart';
import 'albumDetail.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> updateLikeInDatabase(int id, bool isLiked) async {
  const String phpurl =
      "http://192.168.43.73/projetmobdev/updateLikeAlbums.php";

  //String phpurl = "http://192.168.1.10/projetmobdev/updateLikeAlbums.php";

  await http.post(
    Uri.parse(phpurl),
    body: {
      'id': id.toString(),
      'isLiked': isLiked ? "1" : "0",
    },
  );
}

Future<List<Album>> searching(String search) async {
  String phpurl = "http://192.168.43.73/projetmobdev/searchAlbums.php";

  //String phpurl = "http://192.168.1.10/projetmobdev/searchAlbums.php";

  final response = await http.post(
    Uri.parse(phpurl),
    body: {
      "search": search,
    },
  );
  if (response.statusCode == 200) {
    List searchResult = jsonDecode(response.body);

    return searchResult
        .where((album) =>
            album['title'].toLowerCase().contains(search.toLowerCase()) ||
            album['artist'].toLowerCase().contains(search.toLowerCase()))
        .map<Album>((json) => Album.fromJson(json))
        .toList();
  } else {
    return [];
  }
}

class MusicStore extends StatefulWidget {
  MusicStore({super.key});
  @override
  MusicStoreState createState() => MusicStoreState();
}

class MusicStoreState extends State<MusicStore> {
  int likeCounter = 0;
  bool isClicked = false;
  List<Album> searchResults = [];
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: isClicked
              ? TextField(
                  controller: searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "Search",
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          isClicked = false;
                          searchController.clear();
                        });
                      },
                    ),
                  ),
                  onSubmitted: (value) async {
                    List<Album> result = await searching(value.trim());

                    if (result.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Not found')),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AlbumDetailPage(album: result[0]),
                        ),
                      );
                    }

                    searchController.clear();
                  },
                )
              : const Text('Music Store'),
          actions: [
            //  SizedBox(width: 20),
            IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    isClicked = true;
                  });
                }),
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartScreen(),
                    ));
              },
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.mic_external_on), text: "Pop"),
              Tab(icon: Icon(Icons.electric_bolt), text: "Rock&Roll"),
              Tab(icon: Icon(Icons.mic), text: "Rap"),
              Tab(icon: Icon(Icons.groups), text: "Kpop"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAlbumFuture("Pop"),
            _buildAlbumFuture("Rock"),
            _buildAlbumFuture("Rap"),
            _buildAlbumFuture("KPop"),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumFuture(String genre) {
    return FutureBuilder<List<Album>>(
      future: fetchAlbumsByGenre(genre),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading $genre albums'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No albums found in $genre'));
        } else {
          return _buildAlbumGrid(context, snapshot.data!);
        }
      },
    );
  }

  Widget _buildAlbumGrid(BuildContext context, List<Album> albums) {
    final List<Color> cardColors = [
      Colors.blue.shade100,
      Colors.green.shade100,
      Colors.pink.shade100,
      Colors.amber.shade100,
      Colors.purple.shade100,
      Colors.teal.shade100,
    ];

    return Column(children: [
      Expanded(
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
          ),
          itemCount: albums.length,
          itemBuilder: (context, index) {
            final album = albums[index];
            return StatefulBuilder(builder: (context, setState) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AlbumDetailPage(album: album),
                    ),
                  );
                },
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color: cardColors[index % cardColors.length],
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Image.asset(
                            album.image!,
                            //  height: 180,
                            // width: 180,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          album.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          album.artist,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("${album.numberOfLikes}"),
                              const SizedBox(width: 4),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  album.isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      album.isLiked ? Colors.red : Colors.grey,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  setState(() {
                                    album.isLiked = !album.isLiked;
                                    album.isLiked
                                        ? album.numberOfLikes++
                                        : album.numberOfLikes--;
                                  });
                                  await updateLikeInDatabase(
                                      album.id!, album.isLiked);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
          },
        ),
      ),
    ]);
  }
}
