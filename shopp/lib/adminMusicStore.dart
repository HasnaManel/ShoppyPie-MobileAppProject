import 'package:flutter/material.dart';
import 'album_data.dart';
import 'albumDetail.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl = 'http://192.168.43.73/projetmobdev';
//const String baseUrl = 'http://192.168.1.10/projetmobdev';
int _currentTabIndex = 0;

class AdminMusicStore extends StatefulWidget {
  AdminMusicStore({super.key});
  @override
  AdminMusicStoreState createState() => AdminMusicStoreState();
}

class AdminMusicStoreState extends State<AdminMusicStore> {
  final Map<String, List<Album>> _localAlbums = {
    'Pop': [],
    'Rock': [],
    'Rap': [],
    'KPop': [],
  };

  Future<void> insertAlbum(Album album) async {
    final response = await http.post(
      Uri.parse('$baseUrl/addAlbum.php'),
      body: jsonEncode(album.toJson(forInsert: true)),
    );

    print("Insert response: ${response.body}");
  }

  Future<void> deleteAlbum(Album album) async {
    final response = await http.post(
      Uri.parse('$baseUrl/deleteAlbum.php'),
      body: jsonEncode({'id': album.id}),
    );

    if (response.statusCode == 200) {
      print("Delete response: ${response.body}");
      setState(() {
        _localAlbums[album.genre]?.remove(album);
      });
    } else {
      print("Failed to delete album: ${response.body}");
    }
  }

  Future<void> modifyAlbum(Album album) async {
    final response = await http.post(
      Uri.parse('$baseUrl/modifyAlbum.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(album.toJson(forInsert: false)),
    );

    print("Modify response: ${response.body}");

    if (response.statusCode == 200) {
      setState(() {
        final genreAlbums = _localAlbums[album.genre];
        if (genreAlbums != null) {
          final index = genreAlbums.indexWhere((a) => a.id == album.id);
          if (index != -1) {
            genreAlbums[index] = album;
          }
        }
      });
    } else {
      print("Failed to modify album");
    }
  }

  void _addNewAlbum(String title, String artist, String price, String? img,
      String year, String stock, String descritption) {
    final currentCategory = _localAlbums.keys.elementAt(_currentTabIndex);
    final album = Album(
      title: title,
      artist: artist,
      genre: currentCategory,
      price: double.tryParse(price) ?? 0.0,
      image: 'assets/img/${img ?? 'default_album.jpg'}',
      year: int.tryParse(year) ?? 0,
      description: descritption,
      rating: 0,
      numberOfLikes: 5,
      quantityInStock: int.tryParse(stock) ?? 24,
    );
    setState(() {});
    insertAlbum(album);
    print('Album insert called');
  }

  void _showEditAlbumDialog(BuildContext context, Album album) {
    final titleController = TextEditingController(text: album.title);
    final artistController = TextEditingController(text: album.artist);
    final priceController = TextEditingController(text: album.price.toString());
    final imgController =
        TextEditingController(text: album.image?.split('/').last ?? '');
    final yearController = TextEditingController(text: album.year.toString());
    final stockController =
        TextEditingController(text: album.quantityInStock.toString());
    final descriptionController =
        TextEditingController(text: album.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Album'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Album title')),
            TextField(
                controller: artistController,
                decoration: const InputDecoration(hintText: 'Artist name')),
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
              final updatedAlbum = album.copyWith(
                title: titleController.text,
                artist: artistController.text,
                price: double.tryParse(priceController.text) ?? 0.0,
                image: 'assets/img/${imgController.text}',
                year: int.tryParse(yearController.text) ?? 0,
                quantityInStock: int.tryParse(stockController.text) ?? 0,
                description: descriptionController.text,
              );
              modifyAlbum(updatedAlbum);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAddAlbumDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController artistController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController imgController = TextEditingController();
    final TextEditingController yearController = TextEditingController();
    final TextEditingController stockController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Album'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Album title'),
              ),
              TextField(
                controller: artistController,
                decoration: const InputDecoration(hintText: 'Artist name'),
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
                    artistController.text.isNotEmpty) {
                  if (imgController.text.isEmpty) {
                    imgController.text = 'default_album.jpg';
                  }
                  _addNewAlbum(
                      titleController.text,
                      artistController.text,
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
      length: 4,
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
              Tab(icon: Icon(Icons.mic_external_on), text: "Pop"),
              Tab(icon: Icon(Icons.electric_bolt), text: "Rock&Roll"),
              Tab(icon: Icon(Icons.mic), text: "Rap"),
              Tab(icon: Icon(Icons.groups), text: "Kpop"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAlbumGridForGenre("Pop"),
            _buildAlbumGridForGenre("Rock"),
            _buildAlbumGridForGenre("Rap"),
            _buildAlbumGridForGenre("KPop"),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddAlbumDialog(context),
          tooltip: 'Add Album',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildAlbumGridForGenre(String genre) {
    return FutureBuilder<List<Album>>(
        future: fetchAlbumsByGenre(genre),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading $genre albums'));
          } else {
            final List<Album> remoteAlbums = snapshot.data ?? [];
            final List<Album> localAlbums = _localAlbums[genre] ?? [];
            final allAlbums = [...remoteAlbums, ...localAlbums];

            return allAlbums.isEmpty
                ? Center(child: Text('No albums found in $genre'))
                : _buildAlbumGrid(allAlbums);
          }

          //return _buildAlbumGrid(allAlbums);
        });
  }

  Widget _buildAlbumGrid(List<Album> albums) {
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
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        return StatefulBuilder(
          builder: (context, setState) {
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
                            Positioned(
                              bottom: 8,
                              right: 48,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 24),
                                    color: Colors.blue,
                                    onPressed: () =>
                                        _showEditAlbumDialog(context, album),
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
                                              "Are you sure you want to delete '${album.title}'?"),
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
                                                deleteAlbum(album);
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
