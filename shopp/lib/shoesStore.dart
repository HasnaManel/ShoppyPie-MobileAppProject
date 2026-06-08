import 'package:flutter/material.dart';
import 'shoes_data.dart';
import 'cart.dart';
import 'shoes_detail.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'filterShoes.dart';

Future<void> updateLikeInDatabase(int id, bool isLiked) async {
   String phpurl = "http://192.168.43.73/projetmobdev/updateLikeShoes.php";

//  String phpurl = "http://192.168.1.10/projetmobdev/updateLikeShoes.php";

  await http.post(
    Uri.parse(phpurl),
    body: {
      'id': id.toString(),
      'isLiked': isLiked ? "1" : "0",
    },
  );
}

Future<List<Shoes>> searching(String search) async {
  String phpurl = "http://192.168.43.73/projetmobdev/searchShoes.php";

//  String phpurl = "http://192.168.1.10/projetmobdev/searchShoes.php";

  final response = await http.post(
    Uri.parse(phpurl),
    body: {
      "search": search,
    },
  );
  if (response.statusCode == 200) {
    List searchResult = jsonDecode(response.body);

    return searchResult
        .where((shoe) =>
            shoe['title'].toLowerCase().contains(search.toLowerCase()) ||
            shoe['brand'].toLowerCase().contains(search.toLowerCase()))
        .map<Shoes>((json) => Shoes.fromJson(json))
        .toList();
  } else {
    return [];
  }
}

class ShoesStore extends StatefulWidget {
  ShoesStore({super.key});

  @override
  ShoesStoreState createState() => ShoesStoreState();
}

class ShoesStoreState extends State<ShoesStore> {
  int likeCounter = 0;

  bool isClicked = false;
  List<Shoes> searchResults = [];
  final TextEditingController searchController = TextEditingController();

  List<String> colors = ['Blue', 'Black', 'Green', 'White'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 228, 226, 153),
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
                    List<Shoes> result = await searching(value.trim());

                    if (result.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Not found')),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ShoesDetailPage(shoes: result[0]),
                        ),
                      );
                    }

                    searchController.clear();
                  },
                )
              : const Text('Shoes Store'),
          actions: [
            //SizedBox(width: 20),
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
              Tab(
                  icon: Icon(Icons.sports_basketball_rounded),
                  text: "Snickers"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildShoesFuture(),
          ],
        ),
      ),
    );
  }

  Widget _buildShoesFuture() {
    return FutureBuilder<List<Shoes>>(
      future: fetchShoes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading shoes'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No shoes found '));
        } else {
          return _buildAlbumGrid(context, snapshot.data!);
        }
      },
    );
  }

  Widget _buildAlbumGrid(BuildContext context, List<Shoes> shoes) {
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
                backgroundColor: const Color.fromARGB(255, 238, 236, 212),
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FilterShoes(color: color),
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
          itemCount: shoes.length,
          itemBuilder: (context, index) {
            final shoe = shoes[index];
            return StatefulBuilder(builder: (context, setState) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShoesDetailPage(shoes: shoe),
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
                            shoe.image,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          shoe.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          shoe.brand,
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
                              Text("${shoe.numberOfLikes}"),
                              const SizedBox(width: 4),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  shoe.isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      shoe.isLiked ? Colors.red : Colors.grey,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  setState(() {
                                    shoe.isLiked = !shoe.isLiked;
                                    shoe.isLiked
                                        ? shoe.numberOfLikes++
                                        : shoe.numberOfLikes--;
                                  });
                                  await updateLikeInDatabase(
                                      shoe.id, shoe.isLiked);
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
