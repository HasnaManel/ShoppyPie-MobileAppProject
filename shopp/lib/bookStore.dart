import 'package:flutter/material.dart';
import 'book_data.dart';
import 'cart.dart';
import 'bookDetail.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> updateLikeInDatabase(int id, bool isLiked) async {
   String phpurl = "http://192.168.43.73/projetmobdev/updateLikeBooks.php";

//  const String phpurl = "http://192.168.1.10/projetmobdev/updateLikeBooks.php";

  await http.post(
    Uri.parse(phpurl),
    body: {
      'id': id.toString(),
      'isLiked': isLiked ? "1" : "0",
    },
  );
}

Future<List<Book>> searching(String search) async {
   String phpurl = "http://192.168.43.73/projetmobdev/searchBooks.php";

 // String phpurl = "http://192.168.1.10/projetmobdev/searchBooks.php";

  final response = await http.post(
    Uri.parse(phpurl),
    body: {
      "search": search,
    },
  );
  if (response.statusCode == 200) {
    List searchResult = jsonDecode(response.body);

    return searchResult
        .where((book) =>
            book['title'].toLowerCase().contains(search.toLowerCase()) ||
            book['author'].toLowerCase().contains(search.toLowerCase()))
        .map<Book>((json) => Book.fromJson(json))
        .toList();
  } else {
    return [];
  }
}

class BookStore extends StatefulWidget {
  BookStore({super.key});

  @override
  BookStoreState createState() => BookStoreState();
}

class BookStoreState extends State<BookStore> {
  int likeCounter = 0;
  bool isClicked = false;
  List<Book> searchResults = [];
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red[200],
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
                    List<Book> result = await searching(value.trim());

                    if (result.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Not found')),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetailPage(book: result[0]),
                        ),
                      );
                    }

                    searchController.clear();
                  },
                )
              : const Text('Book Store'),
          actions: [
            //   SizedBox(width: 20),
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
              Tab(icon: Icon(Icons.person_pin), text: "Classics"),
              Tab(
                  icon: Icon(Icons.pie_chart_outline_outlined),
                  text: "Fantasy"),
              Tab(icon: Icon(Icons.draw), text: "Mangas"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAlbumFuture("Classic"),
            _buildAlbumFuture("Fantasy"),
            _buildAlbumFuture("Manga"),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumFuture(String genre) {
    return FutureBuilder<List<Book>>(
      future: fetchBooksByGenre(genre),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading $genre books'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No books found in $genre'));
        } else {
          return _buildAlbumGrid(context, snapshot.data!);
        }
      },
    );
  }

  Widget _buildAlbumGrid(BuildContext context, List<Book> books) {
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
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return StatefulBuilder(builder: (context, setState) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookDetailPage(book: book),
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
                            book.image,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          book.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          book.author,
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
                              Text("${book.numberOfLikes}"),
                              const SizedBox(width: 4),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  book.isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      book.isLiked ? Colors.red : Colors.grey,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  setState(() {
                                    book.isLiked = !book.isLiked;
                                    book.isLiked
                                        ? book.numberOfLikes++
                                        : book.numberOfLikes--;
                                  });
                                  await updateLikeInDatabase(
                                      book.id!, book.isLiked);
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
