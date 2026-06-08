import 'package:flutter/material.dart';
import 'book_data.dart';
import 'bookDetail.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl = 'http://192.168.43.73/projetmobdev';

//const String baseUrl = 'http://192.168.1.10/projetmobdev';

int _currentTabIndex = 0;

class AdminBookStore extends StatefulWidget {
  AdminBookStore({super.key});
  @override
  AdminBookStoreState createState() => AdminBookStoreState();
}

class AdminBookStoreState extends State<AdminBookStore> {
  final Map<String, List<Book>> _localbooks = {
    'Classic': [],
    'Fantasy': [],
    'Manga': [],
  };

  Future<void> insertBook(Book book) async {
    print(book.author);
    final response = await http.post(
      Uri.parse('$baseUrl/addBook.php'),
      body: jsonEncode(book.toJson(forInsert: true)),
    );

    print("Insert response: ${response.body}");
  }

  Future<void> deleteBook(Book book) async {
    final response = await http.post(
      Uri.parse('$baseUrl/deleteBook.php'),
      body: jsonEncode({'id': book.id}),
    );

    if (response.statusCode == 200) {
      print("Delete response: ${response.body}");
      setState(() {
        _localbooks[book.genre]?.remove(book);
      });
    } else {
      print("Failed to delete book: ${response.body}");
    }
  }

  Future<void> modifyBook(Book book) async {
    final response = await http.post(
      Uri.parse('$baseUrl/modifyBook.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(book.toJson(forInsert: false)),
    );

    print("Modify response: ${response.body}");

    if (response.statusCode == 200) {
      setState(() {
        final genrebooks = _localbooks[book.genre];
        if (genrebooks != null) {
          final index = genrebooks.indexWhere((a) => a.id == book.id);
          if (index != -1) {
            genrebooks[index] = book;
          }
        }
      });
    } else {
      print("Failed to modify book");
    }
  }

  void _addNewBook(String title, String author, String price, String? img,
      String year, String stock, String descritption) {
    print(author);
    final currentCategory = _localbooks.keys.elementAt(_currentTabIndex);
    final book = Book(
      title: title,
      author: author,
      genre: currentCategory,
      price: double.tryParse(price) ?? 0.0,
      image: 'assets/img/${img ?? 'default_book.jpg'}',
      year: int.tryParse(year) ?? 0,
      description: descritption,
      rating: 0,
      numberOfLikes: 5,
      quantityInStock: int.tryParse(stock) ?? 24,
    );
    setState(() {});
    insertBook(book);
    print('book insert called');
  }

  void _showEditBookDialog(BuildContext context, Book book) {
    final titleController = TextEditingController(text: book.title);
    final authorController = TextEditingController(text: book.author);
    final priceController = TextEditingController(text: book.price.toString());
    final imgController =
        TextEditingController(text: book.image?.split('/').last ?? '');
    final yearController = TextEditingController(text: book.year.toString());
    final stockController =
        TextEditingController(text: book.quantityInStock.toString());
    final descriptionController = TextEditingController(text: book.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit book'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'book title')),
            TextField(
                controller: authorController,
                decoration: const InputDecoration(hintText: 'author name')),
            TextField(
                controller: priceController,
                decoration: const InputDecoration(hintText: 'Price')),
            TextField(
                controller: imgController,
                decoration: const InputDecoration(hintText: 'Image filename')),
            TextField(
                controller: yearController,
                decoration: const InputDecoration(hintText: 'Year')),
            TextField(
                controller: stockController,
                decoration: const InputDecoration(hintText: 'Stock qty')),
            TextField(
                controller: descriptionController,
                decoration: const InputDecoration(hintText: 'Description')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            child: const Text('Update'),
            onPressed: () {
              final updatedbook = book.copyWith(
                title: titleController.text,
                author: authorController.text,
                price: double.tryParse(priceController.text) ?? 0.0,
                image: 'assets/img/${imgController.text}',
                year: int.tryParse(yearController.text) ?? 0,
                quantityInStock: int.tryParse(stockController.text) ?? 0,
                description: descriptionController.text,
              );
              modifyBook(updatedbook);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAddBookDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController authorController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController imgController = TextEditingController();
    final TextEditingController yearController = TextEditingController();
    final TextEditingController stockController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New book'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'book title'),
              ),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(hintText: 'author name'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(hintText: 'Price '),
              ),
              TextField(
                controller: imgController,
                decoration: const InputDecoration(hintText: 'Image link'),
              ),
              TextField(
                controller: yearController,
                decoration: const InputDecoration(hintText: 'Year'),
              ),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(hintText: 'Stock qtt'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(hintText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    authorController.text.isNotEmpty) {
                  if (imgController.text.isEmpty) {
                    imgController.text = 'default_book.jpg';
                  }
                  _addNewBook(
                      titleController.text,
                      authorController.text,
                      priceController.text,
                      imgController.text,
                      yearController.text,
                      stockController.text,
                      descriptionController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          automaticallyImplyLeading: false,
          title: TabBar(
            isScrollable: true,
            onTap: (index) {
              setState(() {
                _currentTabIndex = index;
              });
            },
            tabs: const [
              Tab(icon: Icon(Icons.mic_external_on), text: "Classic"),
              Tab(icon: Icon(Icons.electric_bolt), text: "Fantasy"),
              Tab(icon: Icon(Icons.mic), text: "Manga"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildbookGridForGenre("Classic"),
            _buildbookGridForGenre("Fantasy"),
            _buildbookGridForGenre("Manga"),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddBookDialog(context),
          tooltip: 'Add book',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildbookGridForGenre(String genre) {
    return FutureBuilder<List<Book>>(
        future: fetchBooksByGenre(genre),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading $genre books'));
          } else {
            final List<Book> remotebooks = snapshot.data ?? [];
            final List<Book> localbooks = _localbooks[genre] ?? [];
            final allbooks = [...remotebooks, ...localbooks];

            return allbooks.isEmpty
                ? Center(child: Text('No books found in $genre'))
                : _buildbookGrid(allbooks);
          }

          //return _buildbookGrid(allbooks);
        });
  }

  Widget _buildbookGrid(List<Book> books) {
    final List<Color> cardColors = [
      Colors.blue.shade100,
      Colors.green.shade100,
      Colors.pink.shade100,
      Colors.amber.shade100,
      Colors.purple.shade100,
      Colors.teal.shade100,
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return StatefulBuilder(
          builder: (context, setState) {
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
                          book.image!,
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
                            Positioned(
                              bottom: 8,
                              right: 48,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 24),
                                    color: Colors.blue,
                                    onPressed: () =>
                                        _showEditBookDialog(context, book),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 24),
                                    color: Colors.red,
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text("Confirm Deletion"),
                                          content: Text(
                                              "Are you sure you want to delete '${book.title}'?"),
                                          actions: [
                                            TextButton(
                                              child: const Text("Cancel"),
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                            ),
                                            TextButton(
                                              child: const Text("Delete",
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                deleteBook(book);
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
