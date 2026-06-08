import 'package:flutter/material.dart';
import 'movie_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoppyPie/cart.dart';

class MovieDetailPage extends ConsumerStatefulWidget {
  final Movie movie;

  const MovieDetailPage({super.key, required this.movie});
  @override
  MovieDetailPageState createState() => MovieDetailPageState();
}

class MovieDetailPageState extends ConsumerState<MovieDetailPage> {
  double _size = 20;
  bool _isAdded = false;

  void _setRatingAsOne() {
    setState(() {
      widget.movie.rating = 1;
      widget.movie.addRating(1);
    });
  }

  void _setRatingAsTwo() {
    setState(() {
      widget.movie.rating = 2;
      widget.movie.addRating(2);
    });
  }

  void _setRatingAsThree() {
    setState(() {
      widget.movie.rating = 3;
      widget.movie.addRating(3);
    });
  }

  void _setRatingAsFour() {
    setState(() {
      widget.movie.rating = 4;
      widget.movie.addRating(4);
    });
  }

  void _setRatingAsFive() {
    setState(() {
      widget.movie.rating = 5;
      widget.movie.addRating(5);
    });
  }

  void addComment(String commentController) {
    setState(() {
      widget.movie.commentList.add(commentController);
    });
  }

  TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
          backgroundColor: Colors.blue.shade50,
          title: Text(widget.movie.title)),
      body: Center(
        child: ListView(
          children: [
            Center(
              child: Column(children: [
                Image.asset(widget.movie.image, height: 250, width: 250),
                SizedBox(height: 10),
                Text(
                  'Director: ${widget.movie.director}',
                  style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                Text(
                  'Price: \$${widget.movie.price.toString()}',
                  style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                Text(
                  'Year : ${widget.movie.year}',
                  style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                Text(
                  'Description : ${widget.movie.description}',
                  style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                SizedBox(height: 10),
                Text(
                  'Quantity in stock : ${widget.movie.quantityInStock}',
                  style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                //   SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(0),
                      child: IconButton(
                        icon: (widget.movie.rating >= 1
                            ? Icon(
                                Icons.star,
                                size: _size,
                              )
                            : Icon(
                                Icons.star_border,
                                size: _size,
                              )),
                        color: Colors.amber[500],
                        onPressed: _setRatingAsOne,
                        iconSize: _size,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(0),
                      child: IconButton(
                        icon: (widget.movie.rating >= 2
                            ? Icon(
                                Icons.star,
                                size: _size,
                              )
                            : Icon(
                                Icons.star_border,
                                size: _size,
                              )),
                        color: Colors.amber[500],
                        onPressed: _setRatingAsTwo,
                        iconSize: _size,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(0),
                      child: IconButton(
                        icon: (widget.movie.rating >= 3
                            ? Icon(
                                Icons.star,
                                size: _size,
                              )
                            : Icon(
                                Icons.star_border,
                                size: _size,
                              )),
                        color: Colors.amber[500],
                        onPressed: _setRatingAsThree,
                        iconSize: _size,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(0),
                      child: IconButton(
                        icon: (widget.movie.rating >= 4
                            ? Icon(
                                Icons.star,
                                size: _size,
                              )
                            : Icon(
                                Icons.star_border,
                                size: _size,
                              )),
                        color: Colors.amber[500],
                        onPressed: _setRatingAsFour,
                        iconSize: _size,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(0),
                      child: IconButton(
                        icon: (widget.movie.rating >= 5
                            ? Icon(
                                Icons.star,
                                size: _size,
                              )
                            : Icon(
                                Icons.star_border,
                                size: _size,
                              )),
                        color: Colors.amber[500],
                        onPressed: _setRatingAsFive,
                        iconSize: _size,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),
                Text(
                  'Average Rating : ${widget.movie.avgRating}',
                  style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),

                SizedBox(height: 10),
                _buildAddToCartButton(),
                SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  width: 300,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter you comment  ',
                    ),
                    controller: commentController,
                  ),
                ),

                SizedBox(height: 10),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isAdded ? Colors.green : Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                      shadowColor: Colors.blue.withOpacity(0.3),
                    ),
                    onPressed: () {
                      if (commentController.text.isNotEmpty) {
                        addComment(commentController.text);
                        commentController.clear();
                      }
                    },
                    child: Text(
                      "Add a comment",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    )),
                SizedBox(height: 10),
                Text("Comments",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    )),
                SizedBox(
                    width: 400,
                    height: 150,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.movie.commentList.length,
                        itemBuilder: (context, index) {
                          return Text(
                            widget.movie.commentList[index],
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          );
                        }))
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 200,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _isAdded ? Colors.green : Colors.blue.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
          shadowColor: Colors.blue.withOpacity(0.3),
        ),
        onPressed: () {
          setState(() {
            _isAdded = !_isAdded;
          });
          CartItem movieItem = CartItem(
            id: widget.movie.id,
            title: widget.movie.title,
            type: 'movie',
            price: widget.movie.price,
            image: widget.movie.image,
          );

          ref.read(cartListProvider.notifier).state = [
            ...ref.read(cartListProvider.notifier).state,
            movieItem
          ];

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isAdded ? 'Added to cart! ' : 'Removed from cart',
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isAdded ? Icons.check : Icons.shopping_cart,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _isAdded ? 'Added to Cart' : 'Add to Cart',
              style: const TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
