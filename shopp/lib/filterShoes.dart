import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shoppyPie/shoes_detail.dart';
import 'shoes_data.dart';

Future<List<Shoes>> filterByColor(String color) async {
   String phpurl = "http://192.168.43.73/projetmobdev/filterShoes.php";

  //String phpurl = "http://192.168.1.10/projetmobdev/filterShoes.php";

  final response = await http.post(
    Uri.parse(phpurl),
    body: {
      "color": color,
    },
  );

  if (response.statusCode == 200) {
    List searchResult = jsonDecode(response.body);

    return searchResult.map<Shoes>((json) => Shoes.fromJson(json)).toList();
  } else {
    return [];
  }
}

class FilterShoes extends StatefulWidget {
  const FilterShoes({super.key, required this.color});
  final String color;

  @override
  State<FilterShoes> createState() => _FilterShoesState();
}

class _FilterShoesState extends State<FilterShoes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shoes: ${widget.color}'),
        backgroundColor: Colors.grey.shade200,
      ),
      body: FutureBuilder<List<Shoes>>(
        future: filterByColor(widget.color),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading shoes'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No shoes found for ${widget.color}'));
          } else {
            return _buildMovieGrid(snapshot.data!);
          }
        },
      ),
    );
  }

  Widget _buildMovieGrid(List<Shoes> shoes) {
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
      itemCount: shoes.length,
      itemBuilder: (context, index) {
        final shoe = shoes[index];
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
                  ],
                ),
              ),
            ));
      },
    );
  }
}
