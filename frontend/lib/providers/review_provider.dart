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

  List<String> get placeTitles => _reviews.map((r) => r.title).toSet().toList();

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

  // Get unique places by title for a specific category
  List<Review> getUniquePlacesByCategory(String category) {
    final categoryReviews = getReviewsByCategory(category);
    final uniquePlaces = <String, Review>{};

    // Keep only one review per unique place title
    for (final review in categoryReviews) {
      if (!uniquePlaces.containsKey(review.title)) {
        uniquePlaces[review.title] = review;
      }
    }

    return uniquePlaces.values.toList();
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

  // Get top rated unique places for a category
  List<Review> getTopRatedUniqueByCategory(String category, {int limit = 5}) {
    final uniquePlaces = getUniquePlacesByCategory(category);
    uniquePlaces.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    return uniquePlaces.take(limit).toList();
  }

  // Get bottom rated unique places for a category
  List<Review> getBottomRatedUniqueByCategory(String category,
      {int limit = 5}) {
    final uniquePlaces = getUniquePlacesByCategory(category);
    uniquePlaces.sort((a, b) => a.averageRating.compareTo(b.averageRating));
    return uniquePlaces.take(limit).toList();
  }

  // Get top and bottom rated unique places for each category
  // Returns a map where key is category name and value is a map with 'top' and 'bottom' lists
  Map<String, Map<String, List<Review>>> getTopBottomByCategoryMap() {
    final result = <String, Map<String, List<Review>>>{};

    for (final category in categories) {
      result[category] = {
        'top': getTopRatedUniqueByCategory(category),
        'bottom': getBottomRatedUniqueByCategory(category)
      };
    }

    return result;
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
