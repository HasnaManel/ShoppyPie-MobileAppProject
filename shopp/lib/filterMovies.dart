import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'movie_data.dart';
import 'movieDetail.dart';

Future<List<Movie>> filterByGenre(String genre) async {
  String phpurl = "http://192.168.43.73/projetmobdev/filterMovie.php";

  //String phpurl = "http://192.168.1.10/projetmobdev/filterMovie.php";

  final response = await http.post(
    Uri.parse(phpurl),
    body: {
      "genre": genre,
    },
  );

  if (response.statusCode == 200) {
    List searchResult = jsonDecode(response.body);
    return searchResult.map<Movie>((json) => Movie.fromJson(json)).toList();
  } else {
    return [];
  }
}

class FilterMovies extends StatefulWidget {
  const FilterMovies({super.key, required this.genre});
  final String genre;

  @override
  State<FilterMovies> createState() => _FilterMoviesState();
}

class _FilterMoviesState extends State<FilterMovies> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movies: ${widget.genre}'),
        backgroundColor: Colors.grey.shade200,
      ),
      body: FutureBuilder<List<Movie>>(
        future: filterByGenre(widget.genre),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading movies'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No movies found for ${widget.genre}'));
          } else {
            return _buildMovieGrid(snapshot.data!);
          }
        },
      ),
    );
  }

  Widget _buildMovieGrid(List<Movie> movies) {
    final List<Color> cardColors = [
      Colors.blue.shade100,
      Colors.green.shade100,
      Colors.pink.shade100,
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
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
                  ],
                ),
              ),
            ));
      },
    );
  }
}
