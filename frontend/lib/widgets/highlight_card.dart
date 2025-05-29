import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/review_provider.dart';

class HighlightCard extends StatelessWidget {
  final String category;

  const HighlightCard({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewProvider>(
      builder: (context, provider, child) {
        final categoryReviews = provider.getReviewsByCategory(category);
        final topRated = List.from(categoryReviews)
          ..sort((a, b) => b.averageRating.compareTo(a.averageRating));
        final bottomRated = List.from(categoryReviews)
          ..sort((a, b) => a.averageRating.compareTo(b.averageRating));

        return Container(
          width: 300,
          margin: const EdgeInsets.only(right: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Top 5
                  Text(
                    'Top Rated',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...topRated.take(5).map((review) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text(provider.getSentimentEmoji(review.sentiment)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            review.title,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${review.averageRating.toStringAsFixed(1)}⭐',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  )),
                  
                  const SizedBox(height: 16),
                  
                  // Bottom 5
                  Text(
                    'Needs Improvement',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...bottomRated.take(5).map((review) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text(provider.getSentimentEmoji(review.sentiment)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            review.title,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${review.averageRating.toStringAsFixed(1)}⭐',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
