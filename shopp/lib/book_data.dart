import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Book>> fetchBooksByGenre(String genre) async {
   String phpurl = "http://192.168.43.73/projetmobdev/books.php";

 // String phpurl = "http://192.168.1.10/projetmobdev/books.php";

  final response = await http.get(Uri.parse(phpurl));

  if (response.statusCode == 200) {
    List allBooks = jsonDecode(response.body);

    List filtered =
        allBooks.where((book) => book['genre'].trim() == genre.trim()).toList();

    return filtered.map<Book>((json) => Book.fromJson(json)).toList();
  }
  return [];
}

class Book {
  final int? id;
  final String title;
  final String author;
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

  Book({
    this.id,
    required this.title,
    required this.author,
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

  Book copyWith({
    int? id,
    String? title,
    String? author,
    String? genre,
    double? price,
    String? image,
    int? year,
    String? description,
    int? rating,
    int? numberOfLikes,
    int? quantityInStock,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
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

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: int.parse(json['id']),
      title: json['title'],
      author: json['author'],
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
  Map<String, dynamic> toJson({bool forInsert = false}) {
    final data = {
      'id': id,
      'title': title,
      'author': author,
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
