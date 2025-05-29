class Review {
  final String id;
  final String categoryName;
  final double latitude;
  final double longitude;
  final String title;
  final double stars;
  final double averageRating;
  final String cleanedText;
  final String sentiment;

  Review({
    required this.id,
    required this.categoryName,
    required this.latitude,
    required this.longitude,
    required this.title,
    required this.stars,
    required this.averageRating,
    required this.cleanedText,
    required this.sentiment,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      categoryName: json['categoryName'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      title: json['title'] ?? '',
      stars: (json['stars'] ?? 0.0).toDouble(),
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      cleanedText: json['cleanedText'] ?? '',
      sentiment: json['sentiment'] ?? 'Neutral',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryName': categoryName,
      'latitude': latitude,
      'longitude': longitude,
      'title': title,
      'stars': stars,
      'averageRating': averageRating,
      'cleanedText': cleanedText,
      'sentiment': sentiment,
    };
  }
}

class UserReview {
  final String placeTitle;
  final String reviewText;

  UserReview({
    required this.placeTitle,
    required this.reviewText,
  });

  Map<String, dynamic> toJson() {
    return {
      'placeTitle': placeTitle,
      'reviewText': reviewText,
    };
  }
}
