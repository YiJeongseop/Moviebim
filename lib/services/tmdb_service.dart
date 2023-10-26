import 'dart:convert';
import 'package:http/http.dart' as http;

import '../main.dart';
import '../api_key.dart';

class TmdbService {
  final language = englishTest ? 'en-US' : ((defaultLocale == 'ko_KR') ? 'ko-KR' : 'en-US');

  Future<Map<String, dynamic>> searchMovies(String query) async {
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$query&language=$language'));

    if (response.statusCode == 200) {
      if(!httpResponseTest){
        return json.decode(response.body);
      } else {
        throw Exception('Failed to search movies'); // for Test
      }
    } else {
      throw Exception('Failed to search movies');
    }
  }
}