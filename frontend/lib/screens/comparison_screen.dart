import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/review_provider.dart';
import '../models/review_model.dart';

class ComparisonScreen extends StatefulWidget {
  @override
  _ComparisonScreenState createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  String? compareLocation1;
  String? compareLocation2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparison Tool'),
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
                // Introduction
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Compare Locations',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select two locations to compare their sentiment analysis side by side.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Comparison Selection
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Locations',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Location 1',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 16),
                                ),
                                value: compareLocation1,
                                isExpanded:
                                    true, // This ensures the dropdown expands to full width
                                icon: const Icon(Icons.arrow_drop_down,
                                    size: 24), // Smaller icon
                                items: provider.placeTitles.map((title) {
                                  return DropdownMenuItem<String>(
                                    value: title,
                                    child: Text(
                                      title,
                                      overflow: TextOverflow
                                          .ellipsis, // Add ellipsis for overflow
                                      maxLines: 1, // Limit to one line
                                      style: const TextStyle(
                                          fontSize:
                                              13), // Slightly smaller font
                                    ),
                                  );
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
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 16),
                                ),
                                value: compareLocation2,
                                isExpanded:
                                    true, // This ensures the dropdown expands to full width
                                icon: const Icon(Icons.arrow_drop_down,
                                    size: 24), // Smaller icon
                                items: provider.placeTitles.map((title) {
                                  return DropdownMenuItem<String>(
                                    value: title,
                                    child: Text(
                                      title,
                                      overflow: TextOverflow
                                          .ellipsis, // Add ellipsis for overflow
                                      maxLines: 1, // Limit to one line
                                      style: const TextStyle(
                                          fontSize:
                                              13), // Slightly smaller font
                                    ),
                                  );
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
                      ],
                    ),
                  ),
                ),

                // Comparison Chart
                if (compareLocation1 != null && compareLocation2 != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sentiment Comparison',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          _buildComparisonChart(provider),

                          const SizedBox(height: 24),

                          // Metrics comparison
                          _buildMetricsComparison(provider),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
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

    // For legend
    final location1ShortName = compareLocation1!.length > 10
        ? '${compareLocation1!.substring(0, 10)}...'
        : compareLocation1;
    final location2ShortName = compareLocation2!.length > 10
        ? '${compareLocation2!.substring(0, 10)}...'
        : compareLocation2;

    // Calculate max value for better interval calculation
    final maxValue = [
      location1Sentiment.values.fold(0, (p, c) => p > c ? p : c),
      location2Sentiment.values.fold(0, (p, c) => p > c ? p : c),
    ].reduce((max, value) => max > value ? max : value).toDouble();

    // Calculate appropriate interval based on max value
    double interval;
    if (maxValue <= 10) {
      interval = 1;
    } else if (maxValue <= 50) {
      interval = 5;
    } else if (maxValue <= 100) {
      interval = 10;
    } else {
      interval = (maxValue / 10).ceil().toDouble();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(location1ShortName!, Colors.blue),
            const SizedBox(width: 20),
            _buildLegendItem(location2ShortName!, Colors.orange),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxValue + interval, // Add one interval for padding
              gridData: FlGridData(
                horizontalInterval: interval, // Use calculated interval
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
                  bottom:
                      BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
                  left:
                      BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
                ),
              ),
              groupsSpace: 30, // Increased space between groups
              barGroups: [
                // Positive sentiment comparison
                BarChartGroupData(
                  x: 0,
                  groupVertically: false, // Don't stack vertically
                  barsSpace: 10, // Space between bars within a group
                  barRods: [
                    BarChartRodData(
                      toY: (location1Sentiment['Positive'] ?? 0).toDouble(),
                      color: Colors.blue,
                      width: 16, // Reduced width
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(3),
                        topRight: Radius.circular(3),
                      ),
                    ),
                    BarChartRodData(
                      toY: (location2Sentiment['Positive'] ?? 0).toDouble(),
                      color: Colors.orange,
                      width: 16, // Reduced width
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(3),
                        topRight: Radius.circular(3),
                      ),
                    ),
                  ],
                ),
                // Neutral sentiment comparison
                BarChartGroupData(
                  x: 1,
                  groupVertically: false,
                  barsSpace: 10, // Space between bars within a group
                  barRods: [
                    BarChartRodData(
                      toY: (location1Sentiment['Neutral'] ?? 0).toDouble(),
                      color: Colors.blue,
                      width: 16, // Reduced width
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(3),
                        topRight: Radius.circular(3),
                      ),
                    ),
                    BarChartRodData(
                      toY: (location2Sentiment['Neutral'] ?? 0).toDouble(),
                      color: Colors.orange,
                      width: 16, // Reduced width
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(3),
                        topRight: Radius.circular(3),
                      ),
                    ),
                  ],
                ),
                // Negative sentiment comparison
                BarChartGroupData(
                  x: 2,
                  groupVertically: false,
                  barsSpace: 10, // Space between bars within a group
                  barRods: [
                    BarChartRodData(
                      toY: (location1Sentiment['Negative'] ?? 0).toDouble(),
                      color: Colors.blue,
                      width: 16, // Reduced width
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(3),
                        topRight: Radius.circular(3),
                      ),
                    ),
                    BarChartRodData(
                      toY: (location2Sentiment['Negative'] ?? 0).toDouble(),
                      color: Colors.orange,
                      width: 16, // Reduced width
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(3),
                        topRight: Radius.circular(3),
                      ),
                    ),
                  ],
                ),
              ],
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
                    reservedSize: 50, // Increased from 35 to 50 for more space
                    interval: interval, // Use calculated interval
                    getTitlesWidget: (value, meta) {
                      // Don't show 0 value label
                      if (value == 0) return const SizedBox();

                      // Only show labels at proper intervals to avoid crowding
                      if (value % interval != 0) return const SizedBox();

                      return Padding(
                        padding: const EdgeInsets.only(
                            right: 8), // Increased padding
                        child: Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 11, // Slightly larger font
                            color: Colors.black87,
                          ),
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
                    String location =
                        rodIndex == 0 ? compareLocation1! : compareLocation2!;
                    return BarTooltipItem(
                      '$location\n$sentiment: ${rod.toY.toInt()}',
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsComparison(ReviewProvider provider) {
    final location1Reviews =
        provider.reviews.where((r) => r.title == compareLocation1).toList();
    final location2Reviews =
        provider.reviews.where((r) => r.title == compareLocation2).toList();

    final avgRating1 = location1Reviews.isEmpty
        ? 0.0
        : location1Reviews.map((r) => r.averageRating).reduce((a, b) => a + b) /
            location1Reviews.length;

    final avgRating2 = location2Reviews.isEmpty
        ? 0.0
        : location2Reviews.map((r) => r.averageRating).reduce((a, b) => a + b) /
            location2Reviews.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comparison Metrics',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),

        // Comparison table
        Table(
          border: TableBorder.all(
            color: Colors.grey.withOpacity(0.3),
            width: 1,
          ),
          columnWidths: const {
            0: FlexColumnWidth(1.5),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
          },
          children: [
            // Header row
            TableRow(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              children: [
                _buildTableCell('Metric', isHeader: true),
                _buildTableCell(
                    compareLocation1!.length > 15
                        ? '${compareLocation1!.substring(0, 15)}...'
                        : compareLocation1!,
                    isHeader: true),
                _buildTableCell(
                    compareLocation2!.length > 15
                        ? '${compareLocation2!.substring(0, 15)}...'
                        : compareLocation2!,
                    isHeader: true),
              ],
            ),
            // Total reviews
            TableRow(
              children: [
                _buildTableCell('Total Reviews'),
                _buildTableCell('${location1Reviews.length}'),
                _buildTableCell('${location2Reviews.length}'),
              ],
            ),
            // Average rating
            TableRow(
              children: [
                _buildTableCell('Average Rating'),
                _buildTableCell('${avgRating1.toStringAsFixed(1)} ⭐'),
                _buildTableCell('${avgRating2.toStringAsFixed(1)} ⭐'),
              ],
            ),
            // Positive %
            TableRow(
              children: [
                _buildTableCell('Positive %'),
                _buildTableCell(
                    _calculatePercentage(location1Reviews, 'Positive')),
                _buildTableCell(
                    _calculatePercentage(location2Reviews, 'Positive')),
              ],
            ),
            // Neutral %
            TableRow(
              children: [
                _buildTableCell('Neutral %'),
                _buildTableCell(
                    _calculatePercentage(location1Reviews, 'Neutral')),
                _buildTableCell(
                    _calculatePercentage(location2Reviews, 'Neutral')),
              ],
            ),
            // Negative %
            TableRow(
              children: [
                _buildTableCell('Negative %'),
                _buildTableCell(
                    _calculatePercentage(location1Reviews, 'Negative')),
                _buildTableCell(
                    _calculatePercentage(location2Reviews, 'Negative')),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
        textAlign: isHeader ? TextAlign.center : TextAlign.center,
      ),
    );
  }

  String _calculatePercentage(List<Review> reviews, String sentiment) {
    if (reviews.isEmpty) return '0%';

    final count = reviews.where((r) => r.sentiment == sentiment).length;
    final percentage = (count / reviews.length * 100).round();
    return '$percentage%';
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Map<String, int> _getSentimentCounts(List<Review> reviews) {
    final counts = <String, int>{'Positive': 0, 'Neutral': 0, 'Negative': 0};
    for (final review in reviews) {
      counts[review.sentiment] = (counts[review.sentiment] ?? 0) + 1;
    }
    return counts;
  }
}
