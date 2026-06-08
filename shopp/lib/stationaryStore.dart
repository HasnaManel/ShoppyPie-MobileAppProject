import 'package:flutter/material.dart';
import 'stationary_data.dart';
import 'cart.dart';
import 'stationary_detail.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'filterStationary.dart';

Future<void> updateLikeInDatabase(int id, bool isLiked) async {
  String phpurl = "http://192.168.43.73/projetmobdev/updateLikeStationary.php";

  // String phpurl = "http://192.168.1.10/projetmobdev/updateLikeStationary.php";

  await http.post(
    Uri.parse(phpurl),
    body: {
      'id': id.toString(),
      'isLiked': isLiked ? "1" : "0",
    },
  );
}

Future<List<Stationary>> searching(String search) async {
  String phpurl = "http://192.168.43.73/projetmobdev/searchStationary.php";

//  String phpurl = "http://192.168.1.10/projetmobdev/searchStationary.php";

  final response = await http.post(
    Uri.parse(phpurl),
    body: {
      "search": search,
    },
  );
  if (response.statusCode == 200) {
    List searchResult = jsonDecode(response.body);

    return searchResult
        .where((stationary) =>
            stationary['title'].toLowerCase().contains(search.toLowerCase()) ||
            stationary['brand'].toLowerCase().contains(search.toLowerCase()))
        .map<Stationary>((json) => Stationary.fromJson(json))
        .toList();
  } else {
    return [];
  }
}

class StationaryStore extends StatefulWidget {
  StationaryStore({super.key});

  @override
  StationaryStoreState createState() => StationaryStoreState();
}

class StationaryStoreState extends State<StationaryStore> {
  int likeCounter = 0;

  bool isClicked = false;
  List<Stationary> searchResults = [];
  final TextEditingController searchController = TextEditingController();

  List<String> colors = ['All colors', 'Black', 'Pink', 'Blue'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 224, 172, 214),
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
                    List<Stationary> result = await searching(value.trim());

                    if (result.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Not found')),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StationaryDetailPage(stationary: result[0]),
                        ),
                      );
                    }

                    searchController.clear();
                  },
                )
              : const Text('Stationary Store'),
          actions: [
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
            //SizedBox(width: 20),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.attachment_rounded), text: "Everyday items"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildStationaryFuture(),
          ],
        ),
      ),
    );
  }

  Widget _buildStationaryFuture() {
    return FutureBuilder<List<Stationary>>(
      future: fetchStationary(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading stationary'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No stationary found '));
        } else {
          return _buildAlbumGrid(context, snapshot.data!);
        }
      },
    );
  }

  Widget _buildAlbumGrid(BuildContext context, List<Stationary> stationaries) {
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
          itemCount: colors.length,
          itemBuilder: (context, index) {
            String color = colors[index];
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 234, 209, 237),
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FilterStationary(color: color),
                  ),
                );
              },
              child: Text(color),
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
          itemCount: stationaries.length,
          itemBuilder: (context, index) {
            final stationary = stationaries[index];
            return StatefulBuilder(builder: (context, setState) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StationaryDetailPage(stationary: stationary),
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
                            stationary.image,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          stationary.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          stationary.brand,
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
                              Text("${stationary.numberOfLikes}"),
                              const SizedBox(width: 4),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  stationary.isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: stationary.isLiked
                                      ? Colors.red
                                      : Colors.grey,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  setState(() {
                                    stationary.isLiked = !stationary.isLiked;
                                    stationary.isLiked
                                        ? stationary.numberOfLikes++
                                        : stationary.numberOfLikes--;
                                  });
                                  await updateLikeInDatabase(
                                      stationary.id, stationary.isLiked);
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
