import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App logo and name
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.sentiment_satisfied_alt,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Islamabad Sentiment Analysis',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'v1.0.0',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Project description
            _buildSectionTitle(context, 'Project Description'),
            const SizedBox(height: 8),
            const Text(
              'Islamabad Sentiment Analysis is a machine learning-powered mobile application that analyzes and visualizes public sentiments extracted from Google reviews of key public service categories — Hospitals, Malls, Restaurants, and Public Transport. The system provides users with an intuitive interface to explore the best and worst-rated locations based on real-world customer feedback.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Tech stack
            _buildSectionTitle(context, 'Technology Stack'),
            const SizedBox(height: 8),
            _buildTechItem(context, 'Frontend', 'Flutter (Material 3)'),
            _buildTechItem(context, 'Backend', 'Flask (Python)'),
            _buildTechItem(
                context, 'ML Model', 'Logistic Regression with scikit-learn'),
            _buildTechItem(
                context, 'Data Source', 'Google Reviews (scraped and labeled)'),
            _buildTechItem(context, 'Storage', 'CSV Dataset'),
            _buildTechItem(context, 'Mapping', 'Google Maps API'),
            _buildTechItem(context, 'Charts', 'Flutter chart libraries'),
            const SizedBox(height: 24),

            // Features
            _buildSectionTitle(context, 'Key Features'),
            const SizedBox(height: 8),
            _buildFeatureItem(
              context,
              'Dashboard',
              'View sentiment distribution and highlights of top/bottom rated places for each category',
              Icons.dashboard,
            ),
            _buildFeatureItem(
              context,
              'Categories',
              'Explore detailed sentiment analysis for Hospitals, Malls, Restaurants, and Public Transport',
              Icons.category,
            ),
            _buildFeatureItem(
              context,
              'Sentiment Map',
              'Interactive map with color-coded pins representing sentiment at each location',
              Icons.map,
            ),
            _buildFeatureItem(
              context,
              'Review Submission',
              'Submit your own reviews and see real-time sentiment predictions',
              Icons.rate_review,
            ),
            const SizedBox(height: 24),

            // Dataset information
            _buildSectionTitle(context, 'Dataset Information'),
            const SizedBox(height: 8),
            const Text(
              'The app analyzes reviews based on the following data points:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            _buildDataItem(context, 'Category Name',
                'Type of place (Hospitals, Malls, etc.)'),
            _buildDataItem(context, 'Location', 'Geographical coordinates'),
            _buildDataItem(context, 'Title', 'Name of the place'),
            _buildDataItem(context, 'Star Rating', 'Google rating (1-5 stars)'),
            _buildDataItem(
                context, 'Average Rating', 'Mean rating from all reviews'),
            _buildDataItem(context, 'Cleaned Text', 'Preprocessed user review'),
            _buildDataItem(context, 'Sentiment',
                'Derived sentiment label (Positive, Neutral, Negative)'),
            const SizedBox(height: 32),

            // Credits/footer
            const Center(
              child: Text(
                '© 2025 Islamabad Sentiment Analysis',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  Widget _buildTechItem(
      BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
      BuildContext context, String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataItem(
      BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
