import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review_model.dart';

class ApiService {
  static const String baseUrl =
      'http://192.168.18.80:8000'; // Change to your backend URL

  static Future<List<Review>> getReviews() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Review.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }

  static Future<Map<String, dynamic>> submitReview(UserReview review) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/submit-review'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(review.toJson()),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to submit review');
      }
    } catch (e) {
      throw Exception('Error submitting review: $e');
    }
  }

  static Future<Map<String, int>> getSentimentDistribution() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sentiment-distribution'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data.map((key, value) => MapEntry(key, value as int));
      } else {
        throw Exception('Failed to load sentiment distribution');
      }
    } catch (e) {
      throw Exception('Error fetching sentiment distribution: $e');
    }
  }

  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      print('API Health check error: $e');
      return false;
    }
  }
}
