import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shoppyPie/stationary_detail.dart';

import 'stationary_data.dart';

Future<List<Stationary>> filterByColor(String color) async {
  String phpurl = "http://192.168.43.73/projetmobdev/filterStationary.php";

 // String phpurl = "http://192.168.1.10/projetmobdev/filterStationary.php";

  final response = await http.post(
    Uri.parse(phpurl),
    body: {
      "color": color,
    },
  );

  if (response.statusCode == 200) {
    List searchResult = jsonDecode(response.body);

    return searchResult
        .map<Stationary>((json) => Stationary.fromJson(json))
        .toList();
  } else {
    return [];
  }
}

class FilterStationary extends StatefulWidget {
  const FilterStationary({super.key, required this.color});
  final String color;

  @override
  State<FilterStationary> createState() => _FilterShoesState();
}

class _FilterShoesState extends State<FilterStationary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stationary: ${widget.color}'),
        backgroundColor: Colors.grey.shade200,
      ),
      body: FutureBuilder<List<Stationary>>(
        future: filterByColor(widget.color),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading stationaries'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text('No stationary found for ${widget.color}'));
          } else {
            return _buildMovieGrid(snapshot.data!);
          }
        },
      ),
    );
  }

  Widget _buildMovieGrid(List<Stationary> stationaries) {
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
      itemCount: stationaries.length,
      itemBuilder: (context, index) {
        final stationary = stationaries[index];
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
                  ],
                ),
              ),
            ));
      },
    );
  }
}
