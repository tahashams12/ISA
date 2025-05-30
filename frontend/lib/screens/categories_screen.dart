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
                // _buildComparisonTool(provider),
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
            // Update the category card's column children
            children: [
              Text(
                category,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                '${categoryReviews.length} reviews',
                style: const TextStyle(fontSize: 12),
              ),
              const Spacer(),
              // Wrap sentiment indicators in a flexible layout
              Wrap(
                spacing: 4, // Horizontal space between items
                runSpacing: 4, // Vertical space between lines
                children: [
                  _buildSentimentIndicator(
                      '😊', sentimentCounts['Positive'] ?? 0, Colors.green),
                  _buildSentimentIndicator(
                      '😐', sentimentCounts['Neutral'] ?? 0, Colors.orange),
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
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: categoryReviews.length.toDouble(),
                  gridData: FlGridData(
                    horizontalInterval: categoryReviews.length / 5,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.2), width: 1),
                      left: BorderSide(
                          color: Colors.grey.withOpacity(0.2), width: 1),
                    ),
                  ),
                  barGroups: _buildBarGroups(categoryReviews),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          );
                          String text;
                          switch (value.toInt()) {
                            case 0:
                              text = 'Positive';
                              break;
                            case 1:
                              text = 'Neutral';
                              break;
                            case 2:
                              text = 'Negative';
                              break;
                            default:
                              text = '';
                              break;
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(text, style: style),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        interval: categoryReviews.length / 5,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10),
                              textAlign: TextAlign.right,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String sentiment;
                        switch (group.x.toInt()) {
                          case 0:
                            sentiment = 'Positive';
                            break;
                          case 1:
                            sentiment = 'Neutral';
                            break;
                          case 2:
                            sentiment = 'Negative';
                            break;
                          default:
                            sentiment = '';
                        }
                        return BarTooltipItem(
                          '$sentiment: ${rod.toY.toInt()}',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
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
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3),
              topRight: Radius.circular(3),
            ),
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
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3),
              topRight: Radius.circular(3),
            ),
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
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3),
              topRight: Radius.circular(3),
            ),
          ),
        ],
      ),
    ];
  }
}
