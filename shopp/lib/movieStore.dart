import 'package:flutter/material.dart';

import 'movie_data.dart';
import 'cart.dart';
import 'movieDetail.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'filterMovies.dart';

Future<void> updateLikeInDatabase(int id, bool isLiked) async {
String phpurl = "http://192.168.43.73/projetmobdev/updateLikeMovies.php";

//  const String phpurl = "http://192.168.1.10/projetmobdev/updateLikeMovies.php";

  await http.post(
    Uri.parse(phpurl),
    body: {
      'id': id.toString(),
      'isLiked': isLiked ? "1" : "0",
    },
  );
}

Future<List<Movie>> searching(String search) async {
  String phpurl = "http://192.168.43.73/projetmobdev/searchMovies.php";
  final response = await http.post(
    Uri.parse(phpurl),
    body: {
      "search": search,
    },
  );
  if (response.statusCode == 200) {
    List searchResult = jsonDecode(response.body);

    return searchResult
        .where((movie) =>
            movie['title'].toLowerCase().contains(search.toLowerCase()) ||
            movie['director'].toLowerCase().contains(search.toLowerCase()))
        .map<Movie>((json) => Movie.fromJson(json))
        .toList();
  } else {
    return [];
  }
}

class MovieStore extends StatefulWidget {
  MovieStore({super.key});

  @override
  MovieStoreState createState() => MovieStoreState();
}

class MovieStoreState extends State<MovieStore> {
  int likeCounter = 0;
  bool isClicked = false;
  List<Movie> searchResults = [];
  final TextEditingController searchController = TextEditingController();

  List<String> genres = [
    'Animation',
    'Science Fiction',
    'Drama',
    'Thriller',
    'Biography',
    'Dystopy'
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lime[100],
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
                    List<Movie> result = await searching(value.trim());

                    if (result.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Not found')),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MovieDetailPage(movie: result[0]),
                        ),
                      );
                    }

                    searchController.clear();
                  },
                )
              : const Text('Movie Store'),
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
              Tab(icon: Icon(Icons.video_settings_outlined), text: "Favorites"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAlbumFuture(),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumFuture() {
    return FutureBuilder<List<Movie>>(
      future: fetchMovies(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading movies'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No movies found '));
        } else {
          return _buildAlbumGrid(context, snapshot.data!);
        }
      },
    );
  }

  Widget _buildAlbumGrid(BuildContext context, List<Movie> movies) {
    final List<Color> cardColors = [
      Colors.blue.shade100,
      Colors.green.shade100,
      Colors.pink.shade100,
      Colors.amber.shade100,
      Colors.purple.shade100,
      Colors.teal.shade100,
    ];

    return Column(children: [
      SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: genres.length,
          itemBuilder: (context, index) {
            String genre = genres[index];
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[100],
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FilterMovies(genre: genre),
                  ),
                );
              },
              child: Text(genre),
            );
          },
        ),
      ),
      Expanded(
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
          ),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return StatefulBuilder(builder: (context, setState) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieDetailPage(movie: movie),
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
                            movie.image,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          movie.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          movie.director,
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
                              Text("${movie.numberOfLikes}"),
                              const SizedBox(width: 4),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  movie.isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      movie.isLiked ? Colors.red : Colors.grey,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  setState(() {
                                    movie.isLiked = !movie.isLiked;
                                    movie.isLiked
                                        ? movie.numberOfLikes++
                                        : movie.numberOfLikes--;
                                  });

                                  await updateLikeInDatabase(
                                      movie.id, movie.isLiked);
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
