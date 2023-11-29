import 'dart:convert';
import 'package:http/http.dart' as http;

import '../api_key.dart';
import '../main.dart';

class TMDbService {
  final language = englishTest ? 'en-US' : ((defaultLocale == 'ko_KR') ? 'ko-KR' : 'en-US');

  Future<Map<String, dynamic>> searchMovies(String query) async {
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$query&language=$language'));
    // apiKey is in hidden api_key.dart.

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to search movies');
    }
  }

  Future<int> fetchRuntime(int movieId) async {
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/movie/$movieId?api_key=$apiKey'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final int runtime;
      try{
        runtime = data['runtime'];
      } catch (e) {
        return 0;
      }
      return runtime;
    } else {
      throw Exception('Failed to fetch runtime');
    }
  }
}