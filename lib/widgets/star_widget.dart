import 'package:flutter/material.dart';

class StarWidget extends StatelessWidget {
  const StarWidget({Key? key, required this.rating}) : super(key: key);

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, top: 5),
      width: MediaQuery.of(context).size.width / 3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            (rating == 0.5) ? Icons.star_half : Icons.star,
            color: Colors.yellow[600],
          ),
          Icon(
            (rating <= 1) ? Icons.star_border : (rating == 1.5) ? Icons.star_half : Icons.star,
            color: Colors.yellow[600],
          ),
          Icon(
            (rating <= 2) ? Icons.star_border : (rating == 2.5) ? Icons.star_half : Icons.star,
            color: Colors.yellow[600],
          ),
          Icon(
            (rating <= 3) ? Icons.star_border : (rating == 3.5) ? Icons.star_half : Icons.star,
            color: Colors.yellow[600],
          ),
          Icon(
            (rating <= 4) ? Icons.star_border : (rating == 4.5) ? Icons.star_half : Icons.star,
            color: Colors.yellow[600],
          ),
        ],
      ),
    );
  }
}
