import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../providers/review_provider.dart';
import '../models/review_model.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  bool _mapLoaded = false;
  CameraPosition _initialPosition = CameraPosition(
    target: LatLng(33.6844, 73.0479), // Islamabad coordinates
    zoom: 12,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentiment Map'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<ReviewProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Only update markers when map is loaded to prevent crashes
          if (_mapLoaded) {
            _updateMarkers(provider);
          }

          return Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _initialPosition,
                markers: _markers,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  // Mark map as loaded so we can safely add markers
                  setState(() {
                    _mapLoaded = true;
                    _updateMarkers(provider);
                  });
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                compassEnabled: true,
              ),

              // Legend at bottom
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildLegendItem('Positive', Colors.green),
                        _buildLegendItem('Neutral', Colors.orange),
                        _buildLegendItem('Negative', Colors.red),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _centerMap,
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Future<void> _centerMap() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_initialPosition));
  }

  void _updateMarkers(ReviewProvider provider) {
    try {
      Set<Marker> newMarkers = {};

      for (final review in provider.reviews) {
        // Skip if latitude or longitude is invalid
        if (review.latitude == 0 && review.longitude == 0) continue;

        // Create a unique ID for each marker
        final markerId = MarkerId(review.id);

        // Get the appropriate marker color based on sentiment
        BitmapDescriptor markerIcon = _getMarkerIcon(review.sentiment);

        // Create the marker
        final marker = Marker(
          markerId: markerId,
          position: LatLng(review.latitude, review.longitude),
          icon: markerIcon,
          infoWindow: InfoWindow(
            title: review.title,
            snippet:
                '${review.sentiment} • ${review.averageRating.toStringAsFixed(1)}⭐ • ${review.categoryName}',
          ),
          onTap: () => _showReviewInfo(review, provider),
        );

        newMarkers.add(marker);
      }

      // Only update state if widget is still mounted and markers changed
      if (mounted && newMarkers.length != _markers.length) {
        setState(() {
          _markers = newMarkers;
        });
      }
    } catch (e) {
      print('Error updating markers: $e');
    }
  }

  BitmapDescriptor _getMarkerIcon(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'negative':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange);
    }
  }

  void _showReviewInfo(Review review, ReviewProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title, category and sentiment emoji
            Row(
              children: [
                Text(
                  provider.getSentimentEmoji(review.sentiment),
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        review.categoryName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sentiment and rating info
            Row(
              children: [
                // Sentiment pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: provider
                        .getSentimentColor(review.sentiment)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: provider
                          .getSentimentColor(review.sentiment)
                          .withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    review.sentiment,
                    style: TextStyle(
                      color: provider.getSentimentColor(review.sentiment),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                // Star rating
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      review.averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Review text if available
            if (review.cleanedText.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Review:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text(
                review.cleanedText,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 16),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
