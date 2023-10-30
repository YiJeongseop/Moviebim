import 'package:flutter/material.dart';

class StarWidget extends StatelessWidget {
  const StarWidget({Key? key, required this.rating, required this.denominator}) : super(key: key);

  final double rating;
  final double denominator;

  @override
  Widget build(BuildContext context) {
    double value = MediaQuery.of(context).size.width / denominator;
    return SizedBox(
      width: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            (rating == 0.5) ? Icons.star_half : Icons.star,
            color: Colors.amber,
            size: value * 0.18,
          ),
          Icon(
            (rating <= 1) ? Icons.star_border : (rating == 1.5) ? Icons.star_half : Icons.star,
            color: Colors.amber,
            size: value * 0.18,
          ),
          Icon(
            (rating <= 2) ? Icons.star_border : (rating == 2.5) ? Icons.star_half : Icons.star,
            color: Colors.amber,
            size: value * 0.18,
          ),
          Icon(
            (rating <= 3) ? Icons.star_border : (rating == 3.5) ? Icons.star_half : Icons.star,
            color: Colors.amber,
            size: value * 0.18,
          ),
          Icon(
            (rating <= 4) ? Icons.star_border : (rating == 4.5) ? Icons.star_half : Icons.star,
            color: Colors.amber,
            size: value * 0.18,
          ),
        ],
      ),
    );
  }
}
