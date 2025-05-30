import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/review_provider.dart';
import '../services/api_service.dart';

class SentimentPredictionScreen extends StatefulWidget {
  const SentimentPredictionScreen({Key? key}) : super(key: key);

  @override
  _SentimentPredictionScreenState createState() =>
      _SentimentPredictionScreenState();
}

class _SentimentPredictionScreenState extends State<SentimentPredictionScreen> {
  final TextEditingController _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _hasResult = false;
  String _sentiment = '';
  double _confidence = 0.0;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _predictSentiment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _hasResult = false;
    });

    try {
      final response = await ApiService.predictSentiment(_textController.text);

      setState(() {
        _sentiment = response['sentiment'] ?? 'Neutral';
        _confidence = (response['confidence'] ?? 0.0).toDouble();
        _hasResult = true;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentiment Predictor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Introduction Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.psychology,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Sentiment Analyzer',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Enter any text to analyze its sentiment. Our machine learning model will predict whether the text expresses a positive, neutral, or negative sentiment.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Text Input
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _textController,
                    decoration: InputDecoration(
                      labelText: 'Enter text to analyze',
                      hintText: 'Type or paste text here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.text_fields),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter some text to analyze';
                      }
                      if (value.trim().length < 5) {
                        return 'Text must be at least 5 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _predictSentiment,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Analyze Sentiment',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              ),
            ),

            // Results
            if (_hasResult) ...[
              const SizedBox(height: 32),
              _buildResultsCard(context),
            ],

            const SizedBox(height: 40),

            // Information card about the model
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About the Model',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This prediction is powered by a Logistic Regression model trained on Google Reviews data. The model uses TF-IDF vectorization to analyze text sentiment.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildModelInfoItem(
                          context,
                          'Algorithm',
                          'Logistic Regression',
                          Icons.auto_graph,
                        ),
                        _buildModelInfoItem(
                          context,
                          'Vectorizer',
                          'TF-IDF',
                          Icons.format_list_numbered,
                        ),
                        _buildModelInfoItem(
                          context,
                          'Training Data',
                          'Google Reviews',
                          Icons.reviews,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard(BuildContext context) {
    final ReviewProvider provider =
        Provider.of<ReviewProvider>(context, listen: false);
    final String emoji = provider.getSentimentEmoji(_sentiment);
    final Color sentimentColor = provider.getSentimentColor(_sentiment);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              sentimentColor.withOpacity(0.1),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Analysis Results',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              emoji,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              _sentiment,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: sentimentColor,
              ),
            ),
            const SizedBox(height: 24),
            _buildConfidenceMeter(context, _confidence, sentimentColor),
            const SizedBox(height: 8),
            Text(
              'Confidence: ${(_confidence * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceMeter(
      BuildContext context, double confidence, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: confidence,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModelInfoItem(
      BuildContext context, String title, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
