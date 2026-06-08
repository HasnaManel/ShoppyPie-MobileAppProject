import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Movie>> fetchMovies() async {
  String phpurl = "http://192.168.43.73/projetmobdev/movies.php";

//   String phpurl = "http://192.168.1.10/projetmobdev/movies.php";

  final response = await http.get(Uri.parse(phpurl));

  if (response.statusCode == 200) {
    List allAlbums = jsonDecode(response.body);
    return allAlbums.map<Movie>((json) => Movie.fromJson(json)).toList();
  }
  return [];
}

class Movie {
  final int id;
  final String title;
  final String director;
  final String genre;
  final double price;
  final String image;
  final int year;
  final String description;
  int rating;
  List<int> ratings;
  bool isLiked;
  int numberOfLikes;
  int quantityInStock;
  List<String> commentList;

  Movie({
    required this.id,
    required this.title,
    required this.director,
    required this.genre,
    required this.price,
    required this.image,
    required this.year,
    required this.description,
    required this.rating,
    List<int>? ratings,
    this.isLiked = false,
    this.numberOfLikes = 0,
    required this.quantityInStock,
    List<String>? commentList,
  })  : ratings = ratings ?? [],
        commentList = commentList ?? [];

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: int.parse(json['id']),
      title: json['title'],
      director: json['director'],
      genre: json['genre'],
      price: double.parse(json['price'].toString()),
      image: 'assets/${json['image'].replaceAll(r'\/', '/')}',
      year: int.parse(json['year'].toString()),
      description: json['description'],
      rating: int.parse(json['rating'].toString()),
      numberOfLikes: int.parse(json['number_of_likes'].toString()),
      quantityInStock: int.parse(json['quantity_in_stock'].toString()),
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'director': director,
        'genre': genre,
        'price': price,
        'image': image,
        'year': year,
        'description': description,
        'rating': rating,
        'number_of_likes': numberOfLikes,
        'quantity_in_stock': quantityInStock,
      };

  double get avgRating {
    if (ratings.isEmpty) return 0;
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  void addRating(int rating) {
    ratings.add(rating);
  }
}
