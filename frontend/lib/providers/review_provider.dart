import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../services/api_service.dart';

class ReviewProvider with ChangeNotifier {
  List<Review> _reviews = [];
  Map<String, int> _sentimentDistribution = {};
  bool _isLoading = false;
  String _error = '';

  List<Review> get reviews => _reviews;
  Map<String, int> get sentimentDistribution => _sentimentDistribution;
  bool get isLoading => _isLoading;
  String get error => _error;

  List<String> get categories => 
      _reviews.map((r) => r.categoryName).toSet().toList();

  List<String> get placeTitles => 
      _reviews.map((r) => r.title).toSet().toList();

  Future<void> loadReviews() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _reviews = await ApiService.getReviews();
      _sentimentDistribution = await ApiService.getSentimentDistribution();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitReview(UserReview review) async {
    try {
      await ApiService.submitReview(review);
      // Reload data after submission
      await loadReviews();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  List<Review> getReviewsByCategory(String category) {
    return _reviews.where((r) => r.categoryName == category).toList();
  }

  List<Review> getTopRatedPlaces({int limit = 5}) {
    final sorted = List<Review>.from(_reviews);
    sorted.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    return sorted.take(limit).toList();
  }

  List<Review> getBottomRatedPlaces({int limit = 5}) {
    final sorted = List<Review>.from(_reviews);
    sorted.sort((a, b) => a.averageRating.compareTo(b.averageRating));
    return sorted.take(limit).toList();
  }

  String getSentimentEmoji(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return '😊';
      case 'negative':
        return '😞';
      default:
        return '😐';
    }
  }

  Color getSentimentColor(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return Colors.green;
      case 'negative':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
