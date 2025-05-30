import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/review_provider.dart';
import '../models/review_model.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String? selectedCategory;
  String? compareLocation1;
  String? compareLocation2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<ReviewProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Cards
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: provider.categories.length,
                  itemBuilder: (context, index) {
                    final category = provider.categories[index];
                    return _buildCategoryCard(context, category, provider);
                  },
                ),

                if (selectedCategory != null) ...[
                  const SizedBox(height: 24),
                  _buildCategoryDetails(provider),
                ],

                const SizedBox(height: 24),
                _buildComparisonTool(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, String category, ReviewProvider provider) {
    final categoryReviews = provider.getReviewsByCategory(category);
    final sentimentCounts = _getSentimentCounts(categoryReviews);

    return Card(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedCategory = selectedCategory == category ? null : category;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text('${categoryReviews.length} reviews'),
              const Spacer(),
              Row(
                children: [
                  _buildSentimentIndicator(
                      '😊', sentimentCounts['Positive'] ?? 0, Colors.green),
                  const SizedBox(width: 8),
                  _buildSentimentIndicator(
                      '😐', sentimentCounts['Neutral'] ?? 0, Colors.orange),
                  const SizedBox(width: 8),
                  _buildSentimentIndicator(
                      '😞', sentimentCounts['Negative'] ?? 0, Colors.red),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSentimentIndicator(String emoji, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$emoji $count',
        style: TextStyle(fontSize: 12, color: color),
      ),
    );
  }

  Widget _buildCategoryDetails(ReviewProvider provider) {
    final categoryReviews = provider.getReviewsByCategory(selectedCategory!);
    final topRated =
        provider.getTopRatedUniqueByCategory(selectedCategory!, limit: 5);
    final bottomRated =
        provider.getBottomRatedUniqueByCategory(selectedCategory!, limit: 5);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$selectedCategory Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Sentiment Bar Chart
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: categoryReviews.length.toDouble(),
                  barGroups: _buildBarGroups(categoryReviews),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('Positive');
                            case 1:
                              return const Text('Neutral');
                            case 2:
                              return const Text('Negative');
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Top and Bottom Rated
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Top 5 Rated',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      ...topRated
                          .map((review) => _buildReviewTile(review, provider)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bottom 5 Rated',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      // Display items directly without scrolling, same as Top 5
                      ...bottomRated
                          .map((review) => _buildReviewTile(review, provider)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTool(ReviewProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comparison Tool',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Location 1',
                      border: OutlineInputBorder(),
                    ),
                    value: compareLocation1,
                    items: provider.placeTitles.map((title) {
                      return DropdownMenuItem(value: title, child: Text(title));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        compareLocation1 = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Location 2',
                      border: OutlineInputBorder(),
                    ),
                    value: compareLocation2,
                    items: provider.placeTitles.map((title) {
                      return DropdownMenuItem(value: title, child: Text(title));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        compareLocation2 = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            if (compareLocation1 != null && compareLocation2 != null) ...[
              const SizedBox(height: 16),
              _buildComparisonChart(provider),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonChart(ReviewProvider provider) {
    final location1Reviews =
        provider.reviews.where((r) => r.title == compareLocation1).toList();
    final location2Reviews =
        provider.reviews.where((r) => r.title == compareLocation2).toList();

    final location1Sentiment = _getSentimentCounts(location1Reviews);
    final location2Sentiment = _getSentimentCounts(location2Reviews);

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: (location1Sentiment['Positive'] ?? 0).toDouble(),
                  color: Colors.green,
                  width: 20,
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: (location2Sentiment['Positive'] ?? 0).toDouble(),
                  color: Colors.green.withOpacity(0.7),
                  width: 20,
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: (location1Sentiment['Neutral'] ?? 0).toDouble(),
                  color: Colors.orange,
                  width: 20,
                ),
              ],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(
                  toY: (location2Sentiment['Neutral'] ?? 0).toDouble(),
                  color: Colors.orange.withOpacity(0.7),
                  width: 20,
                ),
              ],
            ),
            BarChartGroupData(
              x: 4,
              barRods: [
                BarChartRodData(
                  toY: (location1Sentiment['Negative'] ?? 0).toDouble(),
                  color: Colors.red,
                  width: 20,
                ),
              ],
            ),
            BarChartGroupData(
              x: 5,
              barRods: [
                BarChartRodData(
                  toY: (location2Sentiment['Negative'] ?? 0).toDouble(),
                  color: Colors.red.withOpacity(0.7),
                  width: 20,
                ),
              ],
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                    case 1:
                      return const Text('Positive');
                    case 2:
                    case 3:
                      return const Text('Neutral');
                    case 4:
                    case 5:
                      return const Text('Negative');
                    default:
                      return const Text('');
                  }
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewTile(Review review, ReviewProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(provider.getSentimentEmoji(review.sentiment)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${review.averageRating.toStringAsFixed(1)} ⭐',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _getSentimentCounts(List<Review> reviews) {
    final counts = <String, int>{'Positive': 0, 'Neutral': 0, 'Negative': 0};
    for (final review in reviews) {
      counts[review.sentiment] = (counts[review.sentiment] ?? 0) + 1;
    }
    return counts;
  }

  List<BarChartGroupData> _buildBarGroups(List<Review> reviews) {
    final sentimentCounts = _getSentimentCounts(reviews);

    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: (sentimentCounts['Positive'] ?? 0).toDouble(),
            color: Colors.green,
            width: 40,
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: (sentimentCounts['Neutral'] ?? 0).toDouble(),
            color: Colors.orange,
            width: 40,
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            toY: (sentimentCounts['Negative'] ?? 0).toDouble(),
            color: Colors.red,
            width: 40,
          ),
        ],
      ),
    ];
  }
}
