import 'package:equatable/equatable.dart';

class MovieModel extends Equatable {
  final String title;
  final String posterPath;
  final double rating;
  final String comment;
  final DateTime dateTime;
  final int runtime;

  MovieModel({
    required this.title,
    required this.posterPath,
    required this.rating,
    required this.comment,
    required this.dateTime,
    required this.runtime,
  });

  @override
  List<Object> get props => [title, posterPath, rating, comment, dateTime, runtime];
}