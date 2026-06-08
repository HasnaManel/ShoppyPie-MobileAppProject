import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Album>> fetchAlbumsByGenre(String genre) async {
  String phpurl = "http://192.168.43.73/projetmobdev/albums.php";

 // String phpurl = "http://192.168.1.10/projetmobdev/albums.php";



  final response = await http.get(Uri.parse(phpurl));
  //print("Raw response: ${response.body}");

  if (response.statusCode == 200) {
    List allAlbums = jsonDecode(response.body);
    // print(allAlbums);
    List filtered = allAlbums
        .where((album) => album['genre'].trim() == genre.trim())
        .toList();
    return filtered.map<Album>((json) => Album.fromJson(json)).toList();
  }
  return [];
}

class Album {
  final int? id;
  final String title;
  final String artist;
  final String genre;
  final double price;
  final String? image;
  final int year;
  final String description;
  int rating;
  List<int> ratings;
  bool isLiked;
  int numberOfLikes;
  int quantityInStock;
  List<String> commentList;

  Album({
    this.id,
    required this.title,
    required this.artist,
    required this.genre,
    required this.price,
    this.image,
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

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: int.parse(json['id']),
      title: json['title'],
      artist: json['artist'],
      genre: json['genre'],
      price: double.parse(json['price'].toString()),
      image: '${json['image'].replaceAll(r'\/', '/')}',
      year: int.parse(json['year'].toString()),
      description: json['description'],
      rating: int.parse(json['rating'].toString()),
      numberOfLikes: int.parse(json['number_of_likes'].toString()),
      quantityInStock: int.parse(json['quantity_in_stock'].toString()),
    );
  }

  Album copyWith({
    int? id,
    String? title,
    String? artist,
    String? genre,
    double? price,
    String? image,
    int? year,
    String? description,
    int? rating,
    int? numberOfLikes,
    int? quantityInStock,
  }) {
    return Album(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      genre: genre ?? this.genre,
      price: price ?? this.price,
      image: image ?? this.image,
      year: year ?? this.year,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      numberOfLikes: numberOfLikes ?? this.numberOfLikes,
      quantityInStock: quantityInStock ?? this.quantityInStock,
    );
  }

  Map<String, dynamic> toJson({bool forInsert = false}) {
    final data = {
      'id': id,
      'title': title,
      'artist': artist,
      'genre': genre,
      'price': price,
      'image': image,
      'year': year,
      'description': description,
      'rating': rating,
      'number_of_likes': numberOfLikes,
      'quantity_in_stock': quantityInStock,
    };

    if (!forInsert && id != null) {
      data['id'] = id.toString();
    }

    return data;
  }

  double get avgRating {
    if (ratings.isEmpty) return 0;
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  void addRating(int rating) {
    ratings.add(rating);
  }
}
